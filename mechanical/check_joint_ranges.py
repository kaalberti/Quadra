"""Check candidate angle bounds and orientation mapping, without foot-workspace analysis."""

import itertools
import json
import math
from pathlib import Path
import unittest

from check_leg_frames import multiply, rotation_x, rotation_y


DIRECTORY = Path(__file__).resolve().parent
RANGES = json.loads((DIRECTORY / 'joint-ranges.json').read_text(encoding='utf-8'))
POSE = json.loads((DIRECTORY / RANGES['pose_source']).read_text(encoding='utf-8'))
DOCUMENT = (DIRECTORY.parent / 'docs' / 'joint-ranges.md').read_text(encoding='utf-8')
REFLECTION = ((1, 0, 0), (0, -1, 0), (0, 0, 1))


def mapped_interval(joint, sign):
    return tuple(sorted((sign * joint['lower'], sign * joint['upper'])))


def frames(angles, signs):
    rotations = tuple(math.radians(angle * sign) for angle, sign in zip(angles, signs))
    abducted = rotation_x(rotations[0])
    upper = multiply(abducted, rotation_y(rotations[1]))
    lower = multiply(upper, rotation_y(rotations[2]))
    return abducted, upper, lower


class JointRangeChecks(unittest.TestCase):
    def test_contract_and_ordered_finite_bounds(self):
        self.assertEqual(RANGES['units'], 'degrees')
        self.assertEqual(RANGES['interval_convention'], 'closed for geometric analysis only')
        self.assertFalse(RANGES['hardware_limits_validated'])
        self.assertFalse(RANGES['coupled_feasibility_validated'])
        self.assertEqual([joint['id'] for joint in RANGES['joints']], ['q1', 'q2', 'q3'])
        self.assertEqual([(joint['lower'], joint['upper']) for joint in RANGES['joints']],
                         [(-25, 30), (-40, 85), (20, 130)])
        self.assertEqual(RANGES['coordinate_rotation_axes'],
                         ['body +x', 'abducted +y', 'upper-frame +y'])
        for joint in RANGES['joints']:
            self.assertTrue(math.isfinite(joint['lower']))
            self.assertTrue(math.isfinite(joint['upper']))
            self.assertLess(joint['lower'], joint['upper'])

    def test_nominal_containment_spans_and_reserves(self):
        nominal = POSE['joint_angles_degrees_all_legs']
        expected = ((55, 25, 30), (125, 84.04862567408432, 40.95137432591568),
                    (110, 58.97855036448314, 51.02144963551686))
        self.assertEqual(POSE['angle_units'], 'degrees')
        for joint, angle, (span, lower_reserve, upper_reserve) in zip(RANGES['joints'], nominal, expected):
            self.assertLess(joint['lower'], angle)
            self.assertLess(angle, joint['upper'])
            self.assertEqual(joint['upper'] - joint['lower'], span)
            self.assertAlmostEqual(angle - joint['lower'], lower_reserve)
            self.assertAlmostEqual(joint['upper'] - angle, upper_reserve)
            self.assertAlmostEqual(lower_reserve + upper_reserve, span)

    def test_all_leg_coordinate_endpoint_mapping(self):
        self.assertEqual(set(RANGES['coordinate_rotation_signs']), set(POSE['legs']))
        for name, signs in RANGES['coordinate_rotation_signs'].items():
            side = 1 if name.endswith('L') else -1
            self.assertEqual(signs, [side, -1, 1])
            expected = ((-25, 30) if side == 1 else (-30, 25), (-85, 40), (20, 130))
            for joint, sign, target, angle in zip(RANGES['joints'], signs, expected,
                                                 POSE['joint_angles_degrees_all_legs']):
                self.assertEqual(mapped_interval(joint, sign), target)
                self.assertLess(target[0], sign * angle)
                self.assertLess(sign * angle, target[1])
                recovered = sorted((sign * target[0], sign * target[1]))
                self.assertEqual(recovered, [joint['lower'], joint['upper']])

    def test_frame_reflection_and_front_rear_consistency(self):
        corners = list(itertools.product(*[(joint['lower'], joint['upper'])
                                          for joint in RANGES['joints']]))
        samples = corners + [tuple(POSE['joint_angles_degrees_all_legs'])]
        self.assertEqual(len(corners), 8)
        for angles in samples:
            orientations = {name: frames(angles, signs)
                            for name, signs in RANGES['coordinate_rotation_signs'].items()}
            self.assertEqual(orientations['FL'], orientations['RL'])
            self.assertEqual(orientations['FR'], orientations['RR'])
            for left_frame, right_frame in zip(orientations['FL'], orientations['FR']):
                reflected = multiply(multiply(REFLECTION, left_frame), REFLECTION)
                for expected_row, actual_row in zip(reflected, right_frame):
                    for expected, actual in zip(expected_row, actual_row):
                        self.assertAlmostEqual(expected, actual, delta=1e-12)

    def test_knee_excludes_straight_and_folded_references(self):
        knee = RANGES['joints'][2]
        self.assertGreater(knee['lower'], 0)
        self.assertLess(knee['upper'], 180)
        self.assertEqual((knee['lower'], 180 - knee['upper']), (20, 50))
        self.assertEqual((180 - knee['upper'], 180 - knee['lower']), (50, 160))

    def test_documented_tables_match_source(self):
        for joint, angle in zip(RANGES['joints'], POSE['joint_angles_degrees_all_legs']):
            expected_row = (f"| {joint['id']}: {joint['name']} | {joint['lower']} | {joint['upper']} | "
                            f"{joint['upper'] - joint['lower']} | {angle:.6f} | "
                            f"{angle - joint['lower']:.6f} | {joint['upper'] - angle:.6f} |")
            self.assertIn(expected_row, DOCUMENT)
        for name, signs in RANGES['coordinate_rotation_signs'].items():
            intervals = [f'[{lower}, {upper}]' for lower, upper in
                         (mapped_interval(joint, sign) for joint, sign in zip(RANGES['joints'], signs))]
            self.assertIn('| ' + name + ' | ' + ' | '.join(intervals) + ' |', DOCUMENT)
        self.assertIn('not measured servo travel, collision-free bounds, physical stops, or', DOCUMENT)
        self.assertIn('not servo angles', DOCUMENT)


if __name__ == '__main__':
    unittest.main(verbosity=2)
