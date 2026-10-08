"""Synthetic fixtures only; never measurements or hardware calibration."""
import copy
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from contextlib import contextmanager

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('calibration_profiles', ROOT / 'calibration_profiles.py')
profiles = importlib.util.module_from_spec(spec)
spec.loader.exec_module(profiles)


@contextmanager
def workspace_case_dir():
    # Retain generated test artifacts in the ignored repository output folder.
    yield Path(tempfile.mkdtemp(dir=ROOT / 'test-output'))


def fixture():
    return {'angle_units': 'degrees', 'pulse_units': 'microseconds', 'joints': [
        {'joint': f'J{i+1}', 'channel': i, 'measured': True,
         'angleA': 10, 'angleB': 20, 'pulseA': 1550 if i == 1 else 1450,
         'pulseB': 1450 if i == 1 else 1550, 'minimumAngle': 10,
         'maximumAngle': 20, 'minimumPulse': 1450, 'maximumPulse': 1550}
        for i in range(3)]}


class CalibrationProfiles(unittest.TestCase):
    def test_known_mapping_both_directions_and_limits(self):
        p = profiles.validate(fixture())
        self.assertEqual(profiles.pulses(p, [12.5, 12.5, 20]), [1475, 1525, 1550])
        self.assertEqual(profiles.pulses(p, [10, 20, 10]), [1450, 1450, 1450])
        with self.assertRaises(ValueError):
            profiles.pulses(p, [15, 15, 20.01])
        with self.assertRaises(ValueError):
            profiles.pulses(p, [15, float('nan'), 15])

    def test_bad_measurements_and_schema(self):
        mutations = [('measured', False), ('measured', 1), ('angleA', None),
                     ('angleA', float('inf')), ('angleA', 20), ('pulseA', True),
                     ('pulseA', 1450.5), ('pulseA', 1449), ('pulseB', 1551),
                     ('pulseB', 1450), ('minimumAngle', 9), ('maximumAngle', 21),
                     ('minimumAngle', 21), ('minimumPulse', 1500),
                     ('maximumPulse', 1450), ('channel', 2)]
        for key, value in mutations:
            with self.subTest(key=key, value=value):
                r = fixture(); r['joints'][0][key] = value
                with self.assertRaises(ValueError):
                    profiles.validate(r)
        for r in [None, {}, {'joints': []}]:
            with self.assertRaises(ValueError):
                profiles.validate(r)
        r = fixture(); r['joints'].reverse()
        with self.assertRaises(ValueError): profiles.validate(r)
        r = fixture(); r['pulse_units'] = 'milliseconds'
        with self.assertRaises(ValueError): profiles.validate(r)
        r = fixture(); r['joints'][0]['angleA'] = 20 - 1e-9
        with self.assertRaises(ValueError): profiles.validate(r)

    def test_real_template_stays_unmeasured(self):
        r = json.loads((ROOT / 'joint-calibration.json').read_text())
        self.assertTrue(all(j['measured'] is False for j in r['joints']))
        with self.assertRaises(ValueError): profiles.validate(r)

    def test_export_is_atomic_on_validation_failure_and_preserves_existing(self):
        (ROOT / 'test-output').mkdir(exist_ok=True)
        with workspace_case_dir() as folder:
            folder = Path(folder); record = folder / 'record.json'; output = folder / 'profile.h'
            record.write_text(json.dumps(fixture()))
            command = [sys.executable, str(ROOT / 'calibration_profiles.py'), str(record), '--header', str(output)]
            bad = subprocess.run(command + ['--angles', '15', '15', '21'], capture_output=True)
            self.assertEqual(bad.returncode, 2); self.assertFalse(output.exists())
            good = subprocess.run(command, capture_output=True)
            self.assertEqual(good.returncode, 0, good.stderr)
            original = output.read_bytes()
            repeated = subprocess.run(command, capture_output=True)
            self.assertEqual(repeated.returncode, 2); self.assertEqual(output.read_bytes(), original)

    def test_exported_header_against_actual_cpp_mapper(self):
        out = ROOT / 'test-output'; out.mkdir(exist_ok=True)
        with workspace_case_dir() as folder:
            folder = Path(folder)
            (folder / 'profile.h').write_text(profiles.header(profiles.validate(fixture())))
            (folder / 'probe.cpp').write_text('''#include "profile.h"
#include <cstdio>
int main(){float a[3]={12.5f,12.5f,20.0f};
for(int i=0;i<3;i++){uint16_t pulse=42;
if(bench::angleToPulse(offline_calibration::joints[i],a[i],pulse)!=bench::MappingResult::Ok)return 1;
std::printf("%u ",unsigned(pulse));}return 0;}
''')
            compiler = ROOT / 'tools/zig-windows-x86_64-0.13.0/zig.exe'
            env = os.environ.copy()
            env['ZIG_GLOBAL_CACHE_DIR'] = str(out / 'zig-global-cache')
            env['ZIG_LOCAL_CACHE_DIR'] = str(out / 'zig-local-cache')
            exe = folder / 'probe.exe'
            compiled = subprocess.run([str(compiler), 'c++', '-std=c++17', '-Wall', '-Wextra', '-Werror', '-I', str(ROOT / 'include'), str(folder / 'probe.cpp'), '-o', str(exe)], capture_output=True, env=env)
            self.assertEqual(compiled.returncode, 0, compiled.stderr.decode())
            checked = subprocess.run([str(exe)], capture_output=True, text=True)
            self.assertEqual(checked.returncode, 0)
            self.assertEqual(checked.stdout.split(), ['1475', '1525', '1550'])


if __name__ == '__main__':
    unittest.main()
