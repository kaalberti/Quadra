"""Supervised FW-001 console. No port enumeration, auto-arm or auto-recovery."""
import argparse
import queue
import re
import threading
import time
import json
from datetime import datetime, timezone

STATUS = re.compile(r"state=(DISARMED|ARMED|FAULT) fault=(NONE|I2C|TIMEOUT|COMMAND) channel=([0-2]) pulse_us=(\d+)")
TIMING = re.compile(r"TIMING result=(PASS|CONFIG_FAILED|WRITE_FAILED|NO_SIGNAL|OUT_OF_RANGE|CLEANUP_FAILED) high_us=(\d+) period_us=(\d+) samples=([0-3])")


class ProtocolError(RuntimeError):
    pass


class Session:
    def __init__(self, transport, clock=time.monotonic, reply_timeout=0.35):
        self.transport, self.clock = transport, clock
        self.reply_timeout = reply_timeout
        self.state = None
        self.channel = 0
        self.pulse = 1500
        self.fault = "NONE"
        self.stopped = False
        self.last_poll = 0.0
        self.last_keepalive = 0.0
        self.last_timing = None

    def timing(self):
        self.exchange("status", "DISARMED", self.channel, self.pulse)
        try:
            self.transport.write(b"timing rail-off no-servos\n")
            deadline = self.clock() + 1.0  # Disarmed diagnostic only; normal deadline unchanged.
            capture = None
            while self.clock() < deadline:
                raw = self.transport.readline()
                if not raw:
                    continue
                line = raw.decode("ascii", errors="strict").strip()
                if capture is None:
                    match = TIMING.fullmatch(line)
                    if not match:
                        raise ProtocolError("Malformed timing response: " + line)
                    result, high, period, samples = match.groups()
                    high, period, samples = int(high), int(period), int(samples)
                    if high > 50000 or period > 100000 or period < high:
                        raise ProtocolError("Invalid timing measurements")
                    if samples == 0 and (high != 0 or period != 0):
                        raise ProtocolError("Measurements reported without samples")
                    if samples > 0 and not 0 < high < period:
                        raise ProtocolError("Invalid completed timing sample")
                    if result == "PASS" and not (samples == 3 and 1400 <= high <= 1600 and 19000 <= period <= 21000):
                        raise ProtocolError("Inconsistent timing PASS")
                    if result in ("CONFIG_FAILED", "WRITE_FAILED") and samples != 0:
                        raise ProtocolError("Samples reported before pulse setup")
                    if result == "NO_SIGNAL" and samples == 3:
                        raise ProtocolError("Inconsistent missing-signal sample count")
                    capture = dict(result=result, high_us=high, period_us=period, samples=samples)
                    continue
                match = STATUS.fullmatch(line)
                if not match:
                    raise ProtocolError("Missing timing cleanup status: " + line)
                state, fault, channel, pulse = match.groups()
                expected_fault = capture['result'] in ('CONFIG_FAILED', 'WRITE_FAILED', 'CLEANUP_FAILED')
                if (state, fault) != (('FAULT', 'I2C') if expected_fault else ('DISARMED', 'NONE')):
                    raise ProtocolError("Inconsistent timing cleanup state")
                if int(channel) != self.channel or int(pulse) != self.pulse:
                    raise ProtocolError("Timing changed actuator channel/pulse")
                capture.update(state=state, fault=fault, captured_at_utc=datetime.now(timezone.utc).isoformat(),
                               diagnostic_channel=15, loopback_gpio=7,
                               servo_rail_off_acknowledged=True, servos_disconnected_acknowledged=True,
                               servo_rail_voltage_measured=None)
                self.last_timing = capture
                self.state, self.fault, self.last_poll = state, fault, self.clock()
                if expected_fault:
                    raise ProtocolError("Timing bus/cleanup fault; diagnose before reconnecting")
                return json.dumps(capture)
            raise ProtocolError("Timing reply deadline exceeded")
        except (OSError, UnicodeError, ProtocolError) as error:
            self.stop()
            raise ProtocolError(str(error)) from error

    def stop(self):
        self.stopped = True
        self.state = None
        try:
            self.transport.write(b"disarm\n")
        except (OSError, RuntimeError):
            pass  # MCU timeout is the fallback; physical cutoff remains required.

    def exchange(self, command, expected_state=None, expected_channel=None, expected_pulse=None):
        if self.stopped:
            raise ProtocolError("Session stopped; diagnose and reconnect with servo rail OFF")
        try:
            self.transport.write((command + "\n").encode("ascii"))
            deadline = self.clock() + self.reply_timeout
            acknowledged = command == "status"
            while self.clock() < deadline:
                raw = self.transport.readline()
                if not raw:
                    continue
                line = raw.decode("ascii", errors="strict").strip()
                if line == "OK":
                    acknowledged = True
                    continue
                match = STATUS.fullmatch(line)
                if not match or not acknowledged:
                    raise ProtocolError("Unexpected response or device reboot: " + line)
                state, fault, channel, pulse = match.groups()
                channel, pulse = int(channel), int(pulse)
                if not 1450 <= pulse <= 1550:
                    raise ProtocolError("Unexpected pulse window")
                if (state == "FAULT") != (fault != "NONE"):
                    raise ProtocolError("Inconsistent fault state")
                if expected_state is not None and state != expected_state:
                    raise ProtocolError("Unexpected state: " + state + "/" + fault)
                if expected_channel is not None and channel != expected_channel:
                    raise ProtocolError("Unexpected channel")
                if expected_pulse is not None and pulse != expected_pulse:
                    raise ProtocolError("Unexpected pulse")
                self.state, self.fault, self.channel, self.pulse = state, fault, channel, pulse
                self.last_poll = self.clock()
                if command == "keepalive" or command.startswith(("arm ", "pulse ")):
                    self.last_keepalive = self.last_poll
                return line
            raise ProtocolError("Reply deadline exceeded")
        except (OSError, UnicodeError, ProtocolError) as error:
            self.stop()
            raise ProtocolError(str(error)) from error

    def connect(self):
        result = self.exchange("status")
        if self.state == "ARMED":
            self.stop()
            raise ProtocolError("Device already armed; use physical cutoff and reconnect")
        return result

    def command(self, text):
        if self.stopped:
            raise ProtocolError("Session stopped; diagnose and reconnect with servo rail OFF")
        if text == "status":
            return self.exchange("status", self.state, self.channel, self.pulse)
        if text == "disarm":
            # A fault remains latched after successful signal disable.
            return self.exchange("disarm", "FAULT" if self.state == "FAULT" else "DISARMED")
        if text == "reset rail-off":
            return self.exchange("reset", "DISARMED")
        if text == "timing rail-off no-servos" and self.state == "DISARMED":
            return self.timing()
        match = re.fullmatch(r"arm ([0-2])", text)
        if match and self.state == "DISARMED":
            channel = int(match.group(1))
            return self.exchange(text, "ARMED", channel, 1500)
        match = re.fullmatch(r"pulse (\d{4})", text)
        if match and self.state == "ARMED" and 1450 <= int(match.group(1)) <= 1550:
            return self.exchange(text, "ARMED", self.channel, int(match.group(1)))
        # Do not keep an armed servo alive after a mistaken operator command.
        if self.state == "ARMED":
            self.stop()
            raise ProtocolError("Invalid command while armed; signals disabled, reconnect after diagnosis")
        raise ValueError("Use status, arm 0..2, pulse 1450..1550, disarm, reset rail-off, timing rail-off no-servos or quit")

    def poll(self):
        reference = self.last_keepalive if self.state == "ARMED" else self.last_poll
        if self.clock() - reference < 0.4:
            return
        if self.state == "ARMED":
            self.exchange("keepalive", "ARMED", self.channel, self.pulse)
        else:
            self.exchange("status", self.state, self.channel, self.pulse)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--port", required=True, help="Explicit Windows COM port; servo rail OFF before connecting")
    parser.add_argument("--timing-log", help="New JSONL file for complete diagnostic replies; never overwritten")
    parser.add_argument("--allow-legacy-pwm", action="store_true", help="Explicitly acknowledge MG996R/PCA9685 legacy operation; incompatible with ST3215")
    args = parser.parse_args()
    if not args.allow_legacy_pwm:
        parser.error("Legacy PWM console cannot control ST3215. Use --allow-legacy-pwm only for intentional legacy work.")
    import serial  # Already bundled with the existing PlatformIO Python environment.
    transport = serial.Serial(port=None, baudrate=115200, timeout=0.1, write_timeout=0.1)
    transport.dtr = False
    transport.rts = False
    transport.port = args.port
    session = Session(transport)
    commands = queue.Queue()
    timing_log = None
    last_saved = None

    def operator_input():
        try:
            while True:
                text = input().strip()
                commands.put(text)
                if text == "quit":
                    return
        except EOFError:
            commands.put("quit")

    try:
        if args.timing_log:
            timing_log = open(args.timing_log, 'x', encoding='utf-8')
        transport.open()
        # USB/serial opening can reset a board. Startup is allowed only before
        # this session, with the operator instructed to keep servo power off.
        time.sleep(1)
        transport.reset_input_buffer()
        print(session.connect())
        print("Rail OFF for wiring/reset. One unmounted servo, horn removed. Explicit arm moves to unknown centre.")
        print("status | arm 0..2 | pulse 1450..1550 | disarm | reset rail-off | timing rail-off no-servos | quit")
        threading.Thread(target=operator_input, daemon=True).start()
        while True:
            session.poll()
            try:
                text = commands.get(timeout=0.05)
            except queue.Empty:
                continue
            if text == "quit":
                break
            try:
                print(session.command(text))
            except ValueError as error:
                print(error)
            finally:
                if timing_log and session.last_timing is not None and session.last_timing is not last_saved:
                    timing_log.write(json.dumps(session.last_timing) + '\n')
                    timing_log.flush()
                    last_saved = session.last_timing
    except (ProtocolError, OSError, KeyboardInterrupt) as error:
        print("STOP:", error, "Use the physical servo-power cutoff.")
    finally:
        session.stop()
        if transport.is_open:
            transport.close()
        if timing_log:
            timing_log.close()


if __name__ == "__main__":
    main()
