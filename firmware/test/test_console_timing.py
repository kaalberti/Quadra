import json
from pathlib import Path
import sys
import tempfile
import types
import unittest
from unittest.mock import patch
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
import bench_console
from test_console import Clock, Transport

PASS = b'TIMING result=PASS high_us=1498 period_us=19988 samples=3\n'
DISARMED = b'state=DISARMED fault=NONE channel=0 pulse_us=1500\n'
FAULT = b'state=FAULT fault=I2C channel=0 pulse_us=1500\n'


class TimingTransport(Transport):
    def __init__(self, clock):
        super().__init__(clock)
        self.timing_lines = [PASS, DISARMED]
        self.is_open = False
        self.opened = False
    def write(self, raw):
        if raw == b'timing rail-off no-servos\n':
            if not self.timing_lines:
                self.drop = True
            else:
                self.inject = self.timing_lines.copy()
                if self.timing_lines[-1] == FAULT:
                    self.state, self.fault = 'FAULT', 'I2C'
        super().write(raw)
    def open(self): self.is_open = self.opened = True
    def close(self): self.is_open = False
    def reset_input_buffer(self): self.replies.clear()


class TimingConsole(unittest.TestCase):
    def setUp(self):
        self.clock = Clock(); self.transport = TimingTransport(self.clock)
        self.session = bench_console.Session(self.transport, self.clock)
        self.session.connect()

    def test_pass_retains_disarmed_state_and_explicit_acknowledgements(self):
        result = json.loads(self.session.command('timing rail-off no-servos'))
        self.assertEqual(result['result'], 'PASS'); self.assertEqual(result['samples'], 3)
        self.assertIsNone(result['servo_rail_voltage_measured'])
        self.assertEqual(self.session.state, 'DISARMED')
        self.assertNotIn('arm 0', self.transport.sent)
        self.assertEqual(self.session.reply_timeout, .35)

    def test_refusal_armed_and_missing_acknowledgement(self):
        with self.assertRaises(ValueError): self.session.command('timing')
        self.session.command('arm 0')
        with self.assertRaises(bench_console.ProtocolError): self.session.command('timing rail-off no-servos')
        self.assertNotIn('timing rail-off no-servos', self.transport.sent)
        self.assertTrue(self.session.stopped)

    def test_no_signal_is_a_reported_failure_without_retry(self):
        self.transport.timing_lines = [b'TIMING result=NO_SIGNAL high_us=0 period_us=0 samples=0\n', DISARMED]
        result = json.loads(self.session.command('timing rail-off no-servos'))
        self.assertEqual(result['result'], 'NO_SIGNAL'); self.assertFalse(self.session.stopped)
        self.assertEqual(self.transport.sent.count('timing rail-off no-servos'), 1)

    def test_out_of_range_retains_actual_failure_values(self):
        self.transport.timing_lines = [b'TIMING result=OUT_OF_RANGE high_us=1700 period_us=20000 samples=1\n', DISARMED]
        result = json.loads(self.session.command('timing rail-off no-servos'))
        self.assertEqual(result['result'], 'OUT_OF_RANGE'); self.assertEqual(result['high_us'], 1700)
        self.assertEqual(result['samples'], 1); self.assertFalse(self.session.stopped)

    def test_console_logs_complete_cleanup_fault_before_stopping(self):
        output = ROOT / 'test-output'; output.mkdir(exist_ok=True)
        folder = Path(tempfile.mkdtemp(prefix='timing-fault-test-', dir=output)); log = folder / 'capture.jsonl'
        self.transport.timing_lines = [b'TIMING result=CLEANUP_FAILED high_us=1498 period_us=19988 samples=3\n', FAULT]
        serial = types.SimpleNamespace(Serial=lambda **kwargs: self.transport)
        argv = ['bench_console.py', '--port', 'FAKE-NO-HARDWARE', '--timing-log', str(log)]
        with patch.dict(sys.modules, {'serial': serial}), patch.object(sys, 'argv', argv), patch('builtins.input', side_effect=['timing rail-off no-servos', 'quit']), patch('builtins.print'), patch.object(bench_console.time, 'sleep'):
            bench_console.main()
        result = json.loads(log.read_text())
        self.assertEqual(result['result'], 'CLEANUP_FAILED'); self.assertEqual(result['state'], 'FAULT')
        self.assertFalse(self.transport.is_open); self.assertNotIn('reset', self.transport.sent)

    def test_bus_cleanup_failures_stop_and_retain_fault_capture(self):
        for status in ['CONFIG_FAILED', 'WRITE_FAILED', 'CLEANUP_FAILED']:
            with self.subTest(status=status):
                self.setUp(); self.transport.timing_lines = [f'TIMING result={status} high_us=0 period_us=0 samples=0\n'.encode(), FAULT]
                with self.assertRaises(bench_console.ProtocolError): self.session.command('timing rail-off no-servos')
                self.assertTrue(self.session.stopped)
                self.assertEqual(self.session.last_timing['state'], 'FAULT')
                self.assertNotIn('reset', self.transport.sent)

    def test_malformed_or_inconsistent_capture_never_published(self):
        cases = [[b'OK\n', DISARMED], [PASS, FAULT],
                 [b'TIMING result=PASS high_us=1300 period_us=19988 samples=3\n', DISARMED],
                 [b'TIMING result=PASS high_us=1498 period_us=19988 samples=2\n', DISARMED],
                 [b'TIMING result=NO_SIGNAL high_us=100 period_us=200 samples=0\n', DISARMED],
                 [PASS, b'Quadra startup\n']]
        for lines in cases:
            with self.subTest(lines=lines):
                self.setUp(); self.transport.timing_lines = lines
                with self.assertRaises(bench_console.ProtocolError): self.session.command('timing rail-off no-servos')
                self.assertTrue(self.session.stopped); self.assertIsNone(self.session.last_timing)

    def test_missing_diagnostic_or_cleanup_reply_stops(self):
        for lines in [[], [PASS]]:
            self.setUp(); self.transport.timing_lines = lines
            with self.assertRaises(bench_console.ProtocolError): self.session.command('timing rail-off no-servos')
            self.assertTrue(self.session.stopped); self.assertIsNone(self.session.last_timing)

    def test_console_log_preserves_capture_and_never_overwrites(self):
        output = ROOT / 'test-output'; output.mkdir(exist_ok=True)
        folder = Path(tempfile.mkdtemp(prefix='timing-log-test-', dir=output)); log = folder / 'capture.jsonl'
        serial = types.SimpleNamespace(Serial=lambda **kwargs: self.transport)
        argv = ['bench_console.py', '--port', 'FAKE-NO-HARDWARE', '--timing-log', str(log)]
        with patch.dict(sys.modules, {'serial': serial}), patch.object(sys, 'argv', argv), patch('builtins.input', side_effect=['timing rail-off no-servos', 'quit']), patch('builtins.print'), patch.object(bench_console.time, 'sleep'):
            bench_console.main()
        lines = log.read_text().splitlines(); self.assertEqual(len(lines), 1)
        self.assertEqual(json.loads(lines[0])['result'], 'PASS')
        original = log.read_bytes(); self.transport.opened = False
        with patch.dict(sys.modules, {'serial': serial}), patch.object(sys, 'argv', argv), patch('builtins.print'):
            bench_console.main()
        self.assertFalse(self.transport.opened); self.assertEqual(log.read_bytes(), original)


if __name__ == '__main__': unittest.main()
