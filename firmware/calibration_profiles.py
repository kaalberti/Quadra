"""Offline measured-profile validation; never opens a board or changes firmware."""
import argparse
import json
import math
from pathlib import Path
import struct

FIELDS = ('angleA', 'angleB', 'pulseA', 'pulseB', 'minimumAngle',
          'maximumAngle', 'minimumPulse', 'maximumPulse')
PULSE_MIN, PULSE_MAX = 1450, 1550


def float32(value):
    if type(value) not in (int, float) or not math.isfinite(value):
        raise ValueError('angles must be finite numbers')
    try:
        result = struct.unpack('f', struct.pack('f', value))[0]
    except (OverflowError, struct.error) as error:
        raise ValueError('angle cannot be represented by the C++ mapper') from error
    if not math.isfinite(result):
        raise ValueError('angle cannot be represented by the C++ mapper')
    return result


def validate(record):
    if not isinstance(record, dict):
        raise ValueError('expected a calibration object')
    if record.get('angle_units') != 'degrees' or record.get('pulse_units') != 'microseconds':
        raise ValueError('units must be degrees and microseconds')
    joints = record.get('joints')
    if not isinstance(joints, list) or len(joints) != 3:
        raise ValueError('exactly three measured joints are required')
    profiles = []
    for index, source in enumerate(joints):
        if not isinstance(source, dict) or source.get('joint') != f'J{index + 1}':
            raise ValueError('joints must be ordered J1, J2, J3')
        if type(source.get('channel')) is not int or source['channel'] != index:
            raise ValueError('first-leg channels must be 0, 1, 2')
        if source.get('measured') is not True:
            raise ValueError(f'J{index + 1} is unmeasured; export refused')
        p = {'joint': source['joint'], 'channel': index, 'measured': True}
        for field in FIELDS:
            value = source.get(field)
            if 'Pulse' in field or field.startswith('pulse'):
                if type(value) is not int or not PULSE_MIN <= value <= PULSE_MAX:
                    raise ValueError(f'{field} must be an integer within1450..1550us')
                p[field] = value
            else:
                p[field] = float32(value)
        if not p['angleA'] < p['angleB']:
            raise ValueError('angle anchors must increase and remain distinct in float32')
        if not p['angleA'] <= p['minimumAngle'] <= p['maximumAngle'] <= p['angleB']:
            raise ValueError('usable angles must lie inside measured anchors')
        if not p['minimumPulse'] < p['maximumPulse']:
            raise ValueError('pulse limits must increase')
        if p['pulseA'] == p['pulseB'] or any(not p['minimumPulse'] <= p[k] <= p['maximumPulse'] for k in ('pulseA', 'pulseB')):
            raise ValueError('distinct pulse anchors must lie inside pulse limits')
        profiles.append(p)
    return profiles


def pulses(profiles, angles):
    if len(angles) != 3:
        raise ValueError('three joint angles are required')
    result = []
    for p, raw in zip(profiles, angles):
        angle = float32(raw)
        if not p['minimumAngle'] <= angle <= p['maximumAngle']:
            raise ValueError(f"{p['joint']} angle outside measured limits")
        pulse = p['pulseA'] + (angle - p['angleA']) * (p['pulseB'] - p['pulseA']) / (p['angleB'] - p['angleA'])
        if not p['minimumPulse'] <= pulse <= p['maximumPulse']:
            raise ValueError('mapped pulse outside measured limits')
        result.append(math.floor(pulse + 0.5))  # Positive pulse: C++ lround.
    return result


def header(profiles):
    lines = ['// Offline measured profiles only; not included by bench firmware.',
             '#pragma once', '#include "joint_calibration.h"',
             'namespace offline_calibration {',
             'constexpr bench::JointCalibration joints[3] = {']
    for p in profiles:
        values = ['true']
        for field in FIELDS:
            value = p[field]
            values.append(str(value) if type(value) is int else f'{value:.9e}f')
        lines.append('  {' + ', '.join(values) + '}, // ' + p['joint'])
    lines.extend(['};', 'constexpr unsigned channels[3] = {0, 1, 2};', '}', ''])
    return '\n'.join(lines)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('input', type=Path)
    parser.add_argument('--angles', nargs=3, type=float, metavar=('J1', 'J2', 'J3'))
    parser.add_argument('--header', type=Path, help='New offline C++ header; existing files are never overwritten')
    args = parser.parse_args(argv)
    try:
        record = json.loads(args.input.read_text(encoding='utf-8-sig'))
        profiles = validate(record)
        mapped = pulses(profiles, args.angles) if args.angles is not None else None
        if args.header:
            with args.header.open('x', encoding='utf-8', newline='\n') as output:
                output.write(header(profiles))
        print(json.dumps({'validated': True, 'offline_only': True,
                          'profiles': profiles, 'pulses_us': mapped}, allow_nan=False, indent=2))
        return 0
    except (ValueError, OSError, OverflowError) as error:
        parser.exit(2, f'Calibration rejected: {error}\n')


if __name__ == '__main__':
    raise SystemExit(main())
