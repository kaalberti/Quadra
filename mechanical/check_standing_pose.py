"""Offline checks for the single KIN-003 pose; not a motion/IK implementation."""

import json
import math
from pathlib import Path
import unittest
import xml.etree.ElementTree as element_tree

from check_leg_frames import skeleton


DIRECTORY = Path(__file__).resolve().parent
POSE = json.loads((DIRECTORY / 'standing-pose.json').read_text(encoding='utf-8'))
BASE = json.loads((DIRECTORY / POSE['skeleton_source']).read_text(encoding='utf-8'))
DRAWING = element_tree.parse(DIRECTORY / 'standing-pose.svg').getroot()
ELEMENTS = {element.get('id'): element for element in DRAWING.iter() if element.get('id')}
ANGLES = tuple(math.radians(value) for value in POSE['joint_angles_degrees_all_legs'])


def distance(first, second):
    return math.sqrt(sum((left - right)**2 for left, right in zip(first, second)))


def project(view, point):
    forward, left, up = point
    if view == 'side':
        return (390 - 3 * (forward - 75), 180 - 3 * up)
    if view == 'top':
        return (960 - 2 * left, 345 - 2 * forward)
    raise ValueError(view)


class StandingPoseChecks(unittest.TestCase):
    def assert_vector(self, actual, expected):
        self.assertEqual(len(actual), len(expected))
        for actual_value, expected_value in zip(actual, expected):
            self.assertAlmostEqual(actual_value, expected_value,
                                   delta=POSE['coordinate_rounding_tolerance_mm'])

    def test_pose_contract_and_unchanged_candidate(self):
        self.assertEqual(POSE['position_units'], 'mm')
        self.assertEqual(POSE['angle_units'], 'degrees')
        self.assertEqual(POSE['body_datum_height'], 120)
        self.assertEqual(POSE['body_rpy_degrees'], [0, 0, 0])
        self.assertEqual(BASE['parameters'], dict(half_length=75, half_width=55, height=0,
                                                forward=0, outward=25, vertical=0,
                                                upper=70, lower=85))
        self.assertEqual(set(POSE['legs']), set(BASE['legs']))
        for name, points in POSE['legs'].items():
            self.assertEqual(points['O'], BASE['legs'][name]['points']['O'])
            self.assertEqual(points['H'], BASE['legs'][name]['points']['H'])

    def test_independent_triangle_and_angles(self):
        upper, lower = BASE['parameters']['upper'], BASE['parameters']['lower']
        height = POSE['body_datum_height']
        knee_up = (lower**2 - upper**2 - height**2) / (2 * height)
        knee_forward = math.sqrt(upper**2 - knee_up**2)
        hip = math.atan2(knee_forward, -knee_up)
        lower_lean = math.atan2(-knee_forward, height + knee_up)
        self.assert_vector(ANGLES, (0, hip, hip - lower_lean))
        knee_from_cosine = math.acos((height**2 - upper**2 - lower**2) / (2 * upper * lower))
        self.assertAlmostEqual(ANGLES[2], knee_from_cosine, delta=1e-12)
        for points in POSE['legs'].values():
            self.assert_vector(points['K'], (points['H'][0] + knee_forward,
                                             points['H'][1], points['H'][2] + knee_up))

    def test_forward_chain_closure_and_link_lengths(self):
        for name, expected in POSE['legs'].items():
            leg = BASE['legs'][name]
            calculated, _, axes = skeleton(leg['front'], leg['side'], ANGLES, BASE['parameters'])
            for label, point in zip(('O', 'H', 'K', 'P'), calculated):
                self.assert_vector(point, expected[label])
            for first, second, target in (('O', 'H', 25), ('H', 'K', 70), ('K', 'P', 85)):
                self.assertAlmostEqual(distance(expected[first], expected[second]), target, delta=1e-6)
            self.assert_vector(axes[0], (leg['side'], 0, 0))
            self.assert_vector(axes[1], (0, -1, 0))
            self.assert_vector(axes[2], (0, 1, 0))

    def test_ground_frame_symmetry_and_stance(self):
        self.assertEqual(POSE['ground_z_body'], -POSE['body_datum_height'])
        self.assertEqual(POSE['body_origin_ground'], [0, 0, POSE['body_datum_height']])
        reference = POSE['legs']['FL']
        for name, points in POSE['legs'].items():
            leg = BASE['legs'][name]
            for label, original in reference.items():
                expected = (original[0] - (150 if leg['front'] == -1 else 0),
                            original[1] * leg['side'], original[2])
                self.assert_vector(points[label], expected)
            self.assertEqual(points['P'][:2], points['H'][:2])
            self.assertEqual(points['P'][2], POSE['ground_z_body'])
            self.assertAlmostEqual(points['P'][2] + POSE['body_origin_ground'][2], 0)
            self.assertAlmostEqual(points['K'][2] + POSE['body_origin_ground'][2], 69.6875)
        feet = [points['P'] for points in POSE['legs'].values()]
        self.assertEqual(max(point[0] for point in feet) - min(point[0] for point in feet),
                         POSE['stance_length'])
        self.assertEqual(max(point[1] for point in feet) - min(point[1] for point in feet),
                         POSE['stance_width'])
        self.assertEqual((POSE['stance_length'], POSE['stance_width']), (150, 160))

    def test_pitch_pose_is_not_straight_or_folded(self):
        upper, lower = BASE['parameters']['upper'], BASE['parameters']['lower']
        height = POSE['body_datum_height']
        self.assertLess(abs(upper - lower), height)
        self.assertLess(height, upper + lower)
        self.assertGreater(ANGLES[2], 0)
        self.assertLess(ANGLES[2], math.pi)
        self.assertGreater(upper * lower * abs(math.sin(ANGLES[2])), 1e-9)

    def test_svg_projected_points_and_links(self):
        for view, names, labels in (('side', ('FL',), ('H', 'K', 'P')),
                                    ('top', tuple(POSE['legs']), ('P',))):
            for name in names:
                for label in labels:
                    marker = ELEMENTS[f'{view}-{name}-{label}']
                    self.assert_vector((float(marker.get('cx')), float(marker.get('cy'))),
                                       project(view, POSE['legs'][name][label]))
        for segment, start, end in (('upper', 'H', 'K'), ('lower', 'K', 'P')):
            line = ELEMENTS[f'side-FL-{segment}']
            for endpoint, label in enumerate((start, end), start=1):
                self.assert_vector((float(line.get(f'x{endpoint}')), float(line.get(f'y{endpoint}'))),
                                   project('side', POSE['legs']['FL'][label]))
        ground = ELEMENTS['ground-line']
        for attribute in ('y1', 'y2'):
            self.assertAlmostEqual(float(ground.get(attribute)),
                                   project('side', (75, 80, POSE['ground_z_body']))[1])
        body = ELEMENTS['body-plan']
        self.assert_vector((float(body.get('x')), float(body.get('y'))), project('top', (90, 55, 0)))
        self.assertEqual(float(body.get('width')), BASE['body']['width'] * 2)
        self.assertEqual(float(body.get('height')), BASE['body']['length'] * 2)
        rectangle = ELEMENTS['foot-rectangle']
        self.assert_vector((float(rectangle.get('x')), float(rectangle.get('y'))),
                           project('top', POSE['legs']['FL']['P']))
        self.assertEqual(float(rectangle.get('width')), POSE['stance_width'] * 2)
        self.assertEqual(float(rectangle.get('height')), POSE['stance_length'] * 2)

    def test_svg_dimensions_and_labels(self):
        forward = POSE['legs']['FL']['K'][0] - POSE['legs']['FL']['H'][0]
        dimensions = (('height', 120, 3, '120'), ('knee-forward', forward, 3, '48.668803'),
                      ('stance-width', 160, 2, '160'), ('stance-length', 150, 2, '150'))
        for name, value, drawing_scale, label in dimensions:
            line = ELEMENTS[f'dim-{name}']
            start = (float(line.get('x1')), float(line.get('y1')))
            end = (float(line.get('x2')), float(line.get('y2')))
            self.assertAlmostEqual(distance(start, end), drawing_scale * value, delta=1e-6)
            self.assertTrue(''.join(ELEMENTS[f'label-{name}'].itertext()).startswith(label + ' mm'))
        for name, length in (('upper', 70), ('lower', 85)):
            line = ELEMENTS[f'side-FL-{name}']
            start = (float(line.get('x1')), float(line.get('y1')))
            end = (float(line.get('x2')), float(line.get('y2')))
            self.assertAlmostEqual(distance(start, end), 3 * length, delta=1e-6)
            self.assertEqual(ELEMENTS[f'label-{name}'].text, f'{length} mm')
        self.assertEqual(float(ELEMENTS['side-view'].get('data-scale')), 3)
        self.assertEqual(float(ELEMENTS['top-view'].get('data-scale')), 2)

    def test_documented_coordinates_and_scope(self):
        document = (DIRECTORY.parent / 'docs' / 'standing-pose.md').read_text(encoding='utf-8')
        for name, points in POSE['legs'].items():
            coordinates = ['(' + ', '.join(f'{value:.6f}'.rstrip('0').rstrip('.')
                                           for value in points[label]) + ')'
                           for label in ('O', 'H', 'K', 'P')]
            self.assertIn('| ' + name + ' | ' + ' | '.join(coordinates) + ' |', document)
        drawing_text = ' '.join(DRAWING.itertext())
        self.assertIn('Physical standing remains unverified', drawing_text)
        self.assertIn('No chassis thickness is defined', drawing_text)
        self.assertIn('not a stability approval', drawing_text)


if __name__ == '__main__':
    unittest.main(verbosity=2)
