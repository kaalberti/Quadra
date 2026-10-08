"""TOR-003 nominal rigid-component gravity accounting; no contact-force sizing."""
import argparse
import json
import math
from pathlib import Path

from check_leg_frames import add, apply, cross, dot, scale, skeleton, subtract
from static_torque import BASE, POSE, INPUTS

DIRECTORY = Path(__file__).resolve().parent
DEPTH = {'body': 0, 'hip_carrier': 1, 'upper': 2, 'lower': 3}
ANGLES = tuple(map(math.radians, POSE['joint_angles_degrees_all_legs']))
G = INPUTS['gravity_m_s2']


def number(value):
    return type(value) in (int, float) and math.isfinite(value)


def validate(inventory):
    if type(inventory.get('coverage_complete')) is not bool:
        raise ValueError('coverage_complete must be an explicit boolean')
    rows = inventory.get('components')
    if not isinstance(rows, list) or not rows:
        raise ValueError('components must be a nonempty list')
    seen = set()
    for row in rows:
        identifier = row.get('id')
        if not isinstance(identifier, str) or not identifier or identifier in seen:
            raise ValueError('Each physical instance/group needs a unique nonempty ID')
        seen.add(identifier)
        for field in ('leg', 'attachment', 'mass_kg', 'com_local_mm', 'evidence'):
            if field not in row:
                raise ValueError(f'{identifier}: missing {field}')
        if row['leg'] not in (None, *BASE['legs']):
            raise ValueError('Unknown leg')
        attachment = row['attachment']
        if attachment is not None and attachment not in DEPTH:
            raise ValueError('Unknown attachment')
        if attachment not in (None, 'body') and row['leg'] is None:
            raise ValueError('Moving attachment requires a leg')
        mass = row['mass_kg']
        if mass is not None and (not number(mass) or mass < 0):
            raise ValueError('Mass must be finite, nonnegative kg or null')
        com = row['com_local_mm']
        if com is not None and (not isinstance(com, list) or len(com) != 3
                                or not all(number(x) for x in com)):
            raise ValueError('COM must be three finite mm values or null')
        if com is not None and attachment is None:
            raise ValueError('COM frame requires a known attachment')
        if not isinstance(row['evidence'], str) or not row['evidence'].strip():
            raise ValueError('Evidence or explicit unknown explanation required')


def position(row, angles=ANGLES):
    """COM in B, mm; right-side local coordinates must be supplied explicitly."""
    if row['attachment'] is None or row['com_local_mm'] is None:
        return None
    if row['attachment'] == 'body':
        return tuple(row['com_local_mm'])
    leg = BASE['legs'][row['leg']]
    points, frames, _ = skeleton(leg['front'], leg['side'], angles, BASE['parameters'])
    index = DEPTH[row['attachment']] - 1
    return add(points[index], apply(frames[index], row['com_local_mm']))


def correction(row, leg_name, angles=ANGLES):
    """Three signed balancing gravity torques; null means unresolved, not zero."""
    if row['attachment'] == 'body' or (row['leg'] is not None and row['leg'] != leg_name):
        return [0.0] * 3
    if row['mass_kg'] == 0:
        return [0.0] * 3
    if row['attachment'] is None:
        return [None] * 3
    depth = DEPTH[row['attachment']]
    com = position(row, angles)
    if row['mass_kg'] is None or com is None:
        return [None if j < depth else 0.0 for j in range(3)]
    leg = BASE['legs'][leg_name]
    points, _, axes = skeleton(leg['front'], leg['side'], angles, BASE['parameters'])
    force = (0, 0, -row['mass_kg'] * G)
    return [-dot(axes[j], cross(scale(subtract(com, points[j]), .001), force))
            if j < depth else 0.0 for j in range(3)]


def build_report(inventory):
    validate(inventory)
    rows = inventory['components']
    mass_complete = inventory['coverage_complete'] and all(r['mass_kg'] is not None for r in rows)
    subtotal = math.fsum(r['mass_kg'] for r in rows if r['mass_kg'] is not None)
    total = subtotal if mass_complete else None
    result = {'decision': 'TOR-003', 'scope': 'nominal gravity corrections only; not actuator approval',
              'coverage_complete': inventory['coverage_complete'],
              'known_mass_subtotal_kg': subtotal, 'total_mass_kg': total,
              'below_1_2_kg': None if total is None else total < 1.2,
              'unknown_mass_ids': [r['id'] for r in rows if r['mass_kg'] is None],
              'gravity_hold_nm_by_leg': {}, 'unresolved_by_leg_joint': {}}
    for leg in BASE['legs']:
        contributions = [(r['id'], correction(r, leg)) for r in rows]
        unresolved = [[identifier for identifier, v in contributions if v[j] is None]
                      for j in range(3)]
        if not inventory['coverage_complete']:
            for items in unresolved:
                items.append('<inventory coverage incomplete>')
        result['unresolved_by_leg_joint'][leg] = unresolved
        result['gravity_hold_nm_by_leg'][leg] = [
            None if unresolved[j] else math.fsum(v[j] for _, v in contributions)
            for j in range(3)]
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('inventory', nargs='?', type=Path, default=DIRECTORY / 'mass-inventory.json')
    args = parser.parse_args()
    print(json.dumps(build_report(json.loads(args.inventory.read_text(encoding='utf-8'))), indent=2))
