"""Prepare a measured, bounded first-leg plan offline; no hardware connection."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import tempfile
from calibration_profiles import validate, header

ROOT = Path(__file__).resolve().parent


def build(profiles):
    output = ROOT / 'test-output'
    output.mkdir(exist_ok=True)
    folder = Path(tempfile.mkdtemp(prefix='offline-plan-', dir=output))
    (folder / 'offline-profile.h').write_text(header(profiles), encoding='utf-8')
    exe = folder / 'offline-plan.exe'
    env = os.environ.copy()
    env['ZIG_GLOBAL_CACHE_DIR'] = str(output / 'zig-global-cache')
    env['ZIG_LOCAL_CACHE_DIR'] = str(output / 'zig-local-cache')
    result = subprocess.run([str(ROOT / 'tools/zig-windows-x86_64-0.13.0/zig.exe'),
                             'c++', '-std=c++17', '-Wall', '-Wextra', '-Werror',
                             '-I', str(ROOT / 'include'), '-I', str(folder),
                             str(ROOT / 'offline_leg_plan.cpp'), '-o', str(exe)],
                            capture_output=True, text=True, env=env)
    if result.returncode:
        raise ValueError('Offline planner compilation failed: ' + result.stderr)
    return exe


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('profile', type=Path)
    parser.add_argument('--target', nargs=3, type=float, required=True,
                        metavar=('X_MM', 'Y_MM', 'Z_MM'))
    parser.add_argument('--branch', choices=['auto', '0', '1', '2', '3'], required=True,
                        help='auto requires a unique nonsingular solution')
    args = parser.parse_args(argv)
    try:
        profiles = validate(json.loads(args.profile.read_text(encoding='utf-8-sig')))
        exe = build(profiles)
        result = subprocess.run([str(exe), *map(str, args.target),
                                 '-1' if args.branch == 'auto' else args.branch],
                                capture_output=True, text=True)
        print(result.stdout.strip())
        return result.returncode
    except (OSError, ValueError, OverflowError) as error:
        print(json.dumps({'ok': False, 'status': 'ProfileOrBuildRejected', 'reason': str(error)}))
        return 2


if __name__ == '__main__':
    raise SystemExit(main())
