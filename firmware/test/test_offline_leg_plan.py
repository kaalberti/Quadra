"""Synthetic profiles only. CAD reference target is independent of planner output."""
import contextlib
import io
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
import offline_leg_plan as tool
from calibration_profiles import validate


def fixture():
    limits = [(-25, 30), (20, 55), (60, 90)]
    return {'angle_units': 'degrees', 'pulse_units': 'microseconds', 'joints': [
        {'joint': f'J{i+1}', 'channel': i, 'measured': True, 'angleA': a, 'angleB': b,
         'pulseA': 1550 if i == 1 else 1450, 'pulseB': 1450 if i == 1 else 1550,
         'minimumAngle': a, 'maximumAngle': b, 'minimumPulse': 1450, 'maximumPulse': 1550}
        for i, (a, b) in enumerate(limits)]}


class OfflineLegPlan(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.exe = tool.build(validate(fixture()))

    def run_plan(self, target, branch='-1', exe=None):
        result = subprocess.run([str(exe or self.exe), *map(str, target), branch], capture_output=True, text=True)
        return result.returncode, json.loads(result.stdout)

    def test_independent_cad_target_and_reversed_servo(self):
        code, result = self.run_plan([84.999885858, 32, -119.999957838])
        self.assertEqual(code, 0); self.assertTrue(result['offline_only'])
        for actual, expected in zip(result['angles_deg'], [0, 44.0486, 78.9786]):
            self.assertAlmostEqual(actual, expected, places=5)
        self.assertEqual(result['pulses_us'], [1495, 1481, 1513])

    def test_unreachable_geometric_limits_invalid_target_and_branch(self):
        cases = [([1000, 32, -120], '-1', 'Unreachable'),
                 ([85, 32, -155], '-1', 'OutsideBounds'),
                 ([85, 32, -120], '3', 'InvalidBranch'),
                 ([float('nan'), 32, -120], '-1', 'InvalidRequest')]
        for target, branch, expected in cases:
            with self.subTest(status=expected):
                code, result = self.run_plan(target, branch)
                self.assertEqual(code, 2); self.assertEqual(result['status'], expected)
                self.assertNotIn('pulses_us', result); self.assertNotIn('angles_deg', result)

    def test_calibration_limit_rejects_whole_plan(self):
        record = fixture(); record['joints'][1]['minimumAngle'] = 45
        exe = tool.build(validate(record))
        code, result = self.run_plan([85, 32, -120], exe=exe)
        self.assertEqual(code, 2); self.assertEqual(result['status'], 'AngleOutsideCalibration')
        self.assertNotIn('pulses_us', result)

    def test_real_unmeasured_record_rejected_before_build(self):
        output = io.StringIO()
        with patch.object(tool, 'build') as build, contextlib.redirect_stdout(output):
            code = tool.main([str(ROOT / 'joint-calibration.json'), '--target', '85', '32', '-120', '--branch', 'auto'])
        self.assertEqual(code, 2); build.assert_not_called()
        self.assertFalse(json.loads(output.getvalue())['ok'])

    def test_operator_wrapper_explicit_branch(self):
        folder = Path(tempfile.mkdtemp(prefix='offline-cli-test-', dir=ROOT / 'test-output'))
        record = folder / 'synthetic-only.json'; record.write_text(json.dumps(fixture()))
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            code = tool.main([str(record), '--target', '85', '32', '-120', '--branch', '0'])
        self.assertEqual(code, 0); self.assertEqual(json.loads(output.getvalue())['branch'], 0)


if __name__ == '__main__': unittest.main()
