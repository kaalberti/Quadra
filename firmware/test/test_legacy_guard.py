"""Check the legacy console refuses before serial imports or opening a port."""
import pathlib
import subprocess
import sys
import unittest


class LegacyGuardTests(unittest.TestCase):
    def test_cli_refuses_without_explicit_legacy_override(self):
        script = pathlib.Path(__file__).resolve().parents[1] / 'bench_console.py'
        # -S excludes installed serial packages: refusal must occur before import.
        result = subprocess.run([sys.executable, '-S', str(script), '--port', 'DO_NOT_OPEN'],
                                capture_output=True, text=True, timeout=10)
        self.assertEqual(result.returncode, 2)
        self.assertIn('Legacy PWM console cannot control ST3215', result.stderr)
        self.assertNotIn('ModuleNotFoundError', result.stderr)


if __name__ == '__main__':
    unittest.main()
