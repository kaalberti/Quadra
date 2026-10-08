import pathlib
import sys
import unittest
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))
from bench_console import Session, ProtocolError


class Clock:
    now = 0.0
    def __call__(self):
        return self.now


class Transport:
    def __init__(self, clock):
        self.clock = clock
        self.sent = []
        self.replies = []
        self.state, self.channel, self.pulse = "DISARMED", 0, 1500
        self.fault = "NONE"
        self.drop = False
        self.inject = None
    def write(self, raw):
        text = raw.decode().strip()
        self.sent.append(text)
        if text.startswith("arm "):
            self.state, self.channel, self.pulse = "ARMED", int(text[-1]), 1500
        elif text.startswith("pulse "):
            self.pulse = int(text[6:])
        elif text == "reset":
            self.state = "DISARMED"
            self.fault = "NONE"
        elif text == "disarm" and self.state != "FAULT":
            self.state = "DISARMED"
        if self.drop:
            return
        if self.inject:
            self.replies.extend(self.inject)
            self.inject = None
            return
        if text != "status":
            self.replies.append(b"OK\n")
        self.replies.append(f"state={self.state} fault={self.fault} channel={self.channel} pulse_us={self.pulse}\n".encode())
    def readline(self):
        self.clock.now += 0.01
        return self.replies.pop(0) if self.replies else b""


class Tests(unittest.TestCase):
    def setUp(self):
        self.clock = Clock()
        self.transport = Transport(self.clock)
        self.session = Session(self.transport, self.clock)
        self.session.connect()

    def test_connection_never_arms(self):
        self.assertEqual(self.transport.sent, ["status"])
        self.assertEqual(self.session.state, "DISARMED")

    def test_explicit_arm_and_keepalive(self):
        self.session.command("arm 2")
        self.session.command("pulse 1450")
        self.clock.now += 0.5
        self.session.poll()
        self.assertEqual(self.transport.sent[-1], "keepalive")
        self.session.command("disarm")
        self.clock.now += 0.5
        self.session.poll()
        self.assertEqual(self.transport.sent[-1], "status")

    def test_bad_operator_command_stops(self):
        self.session.command("arm 0")
        with self.assertRaises(ProtocolError):
            self.session.command("pulse 1800")
        self.assertEqual(self.transport.sent[-1], "disarm")
        self.assertTrue(self.session.stopped)

    def test_missing_reply_no_recovery_or_heartbeat(self):
        self.session.command("arm 0")
        self.transport.drop = True
        with self.assertRaises(ProtocolError):
            self.session.command("pulse 1501")
        self.assertTrue(self.session.stopped)
        self.clock.now += 1
        with self.assertRaises(ProtocolError):
            self.session.poll()
        self.assertNotIn("reset", self.transport.sent)
        self.assertEqual(self.transport.sent[-1], "disarm")

    def test_reboot_stops(self):
        self.session.command("arm 0")
        self.transport.inject = [b"Quadra bench only: startup\n"]
        with self.assertRaises(ProtocolError):
            self.session.command("status")
        self.assertTrue(self.session.stopped)

    def test_wrong_channel_or_pulse_stops(self):
        for status in (b"state=ARMED fault=NONE channel=2 pulse_us=1500\n",
                       b"state=ARMED fault=NONE channel=0 pulse_us=1510\n"):
            self.setUp()
            self.session.command("arm 0")
            self.transport.inject = [b"OK\n", status]
            self.clock.now += 0.5
            with self.assertRaises(ProtocolError):
                self.session.poll()

    def test_fault_and_rejected_commands_stop(self):
        for reply in (b"state=FAULT fault=I2C channel=0 pulse_us=1500\n", b"REJECTED\n"):
            self.setUp()
            self.session.command("arm 0")
            self.transport.inject = [b"OK\n", reply]
            with self.assertRaises(ProtocolError):
                self.session.command("pulse 1501")
            self.assertTrue(self.session.stopped)

    def test_status_is_not_keepalive(self):
        self.session.command("arm 0")
        previous = self.session.last_keepalive
        self.session.command("status")
        self.assertEqual(self.transport.sent[-1], "status")
        self.assertEqual(self.session.last_keepalive, previous)
        self.clock.now += 0.5
        self.session.poll()
        self.assertEqual(self.transport.sent[-1], "keepalive")

    def test_reset_requires_operator_rail_off_text(self):
        with self.assertRaises(ValueError):
            self.session.command("reset")
        self.assertNotIn("reset", self.transport.sent)
        self.session.command("reset rail-off")
        self.assertEqual(self.session.state, "DISARMED")

    def test_connect_rejects_already_armed_device(self):
        clock = Clock()
        transport = Transport(clock)
        transport.state = "ARMED"
        session = Session(transport, clock)
        with self.assertRaises(ProtocolError):
            session.connect()
        self.assertEqual(transport.sent, ["status", "disarm"])

    def test_fault_can_only_be_reset_explicitly(self):
        clock = Clock()
        transport = Transport(clock)
        transport.state, transport.fault = "FAULT", "TIMEOUT"
        session = Session(transport, clock)
        session.connect()
        self.assertEqual(transport.sent, ["status"])
        with self.assertRaises(ValueError):
            session.command("arm 0")
        session.command("disarm")
        self.assertEqual(session.state, "FAULT")
        session.command("reset rail-off")
        self.assertEqual(session.state, "DISARMED")
        self.assertNotIn("arm 0", transport.sent)

    def test_shutdown_is_best_effort_and_never_rearms(self):
        self.session.command("arm 0")
        self.session.stop()
        self.assertEqual(self.transport.sent[-1], "disarm")
        with self.assertRaises(ProtocolError):
            self.session.command("arm 0")


if __name__ == "__main__":
    unittest.main()
