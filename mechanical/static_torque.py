"""TOR-001 nominal-pose contact-load screen; --write regenerates the result JSON."""

import argparse
import hashlib
import json
import math
from pathlib import Path

from check_leg_frames import cross, dot, scale, skeleton, subtract


DIRECTORY = Path(__file__).resolve().parent
INPUTS = json.loads((DIRECTORY / 'static-torque-inputs.json').read_text(encoding='utf-8'))
POSE = json.loads((DIRECTORY / INPUTS['pose_source']).read_text(encoding='utf-8'))
BASE = json.loads((DIRECTORY / INPUTS['skeleton_source']).read_text(encoding='utf-8'))
NM_PER_KGF_CM = 0.0980665


def balancing_torques(leg, force):
    points, _, axes = skeleton(leg['front'], leg['side'],
                              tuple(map(math.radians, POSE['joint_angles_degrees_all_legs'])),
                              BASE['parameters'])
    return tuple(-dot(axis, cross(scale(subtract(points[-1], origin), 0.001), force))
                 for origin, axis in zip(points[:3], axes))


def build_report():
    if INPUTS['servo_to_joint_ratio'] != 1 or INPUTS['transmission_efficiency'] != 1:
        raise ValueError('This screen only compares an ideal 1:1 drive.')
    if INPUTS['moving_link_gravity_included']:
        raise ValueError('No moving-mass distribution has been specified.')
    ratings = {rating['id']: rating['stall_kgf_cm'] * NM_PER_KGF_CM
               for rating in INPUTS['servo_candidate']['comparison_ratings']}
    cases = {}
    for case in INPUTS['load_cases']:
        force_z = INPUTS['robot_mass_kg'] * INPUTS['gravity_m_s2'] * case['weight_share']
        force = scale(INPUTS['contact_force_direction_body'], force_z)
        torques = {name: list(balancing_torques(leg, force)) for name, leg in BASE['legs'].items()}
        magnitudes = [abs(value) for value in torques['FL']]
        cases[case['id']] = {
            'weight_share': case['weight_share'], 'foot_force_body_n': list(force),
            'balancing_torque_nm_by_leg': torques,
            'magnitude_nm': magnitudes,
            'magnitude_kgf_cm': [value / NM_PER_KGF_CM for value in magnitudes],
            'fraction_of_published_stall': {name: [value / rating for value in magnitudes]
                                            for name, rating in ratings.items()}}
    source_names = ('static-torque-inputs.json', INPUTS['pose_source'], INPUTS['skeleton_source'])
    return {'decision': 'TOR-001',
            'scope': 'nominal vertical contact-load screen; no link gravity or dynamics',
            'source_sha256': {name: hashlib.sha256((DIRECTORY / name).read_bytes()).hexdigest()
                              for name in source_names},
            'joint_order': ['q1', 'q2', 'q3'], 'nm_per_kgf_cm': NM_PER_KGF_CM,
            'stall_comparison_nm': ratings, 'cases': cases,
            'decision_summary': 'Do not approve MG90S direct drive at the 1.2 kg ceiling: half-weight knee demand exceeds both cited stall figures; continuous capability is unspecified.'}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true')
    options = parser.parse_args()
    result = build_report()
    if options.write:
        (DIRECTORY / 'static-torque.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(result, indent=2))
