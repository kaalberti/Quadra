"""Check KIN-002 candidate dimensions and editable SVG against KIN-001."""

import json
import math
from pathlib import Path
import re
import unittest
import xml.etree.ElementTree as element_tree

from check_leg_frames import skeleton


DIRECTORY = Path(__file__).resolve().parent
DATA = json.loads((DIRECTORY / 'leg-skeleton.json').read_text(encoding='utf-8'))
DRAWING = element_tree.parse(DIRECTORY / 'leg-skeleton.svg').getroot()
ELEMENTS = {element.get('id'): element for element in DRAWING.iter() if element.get('id')}


def project(view, point):
    forward, left, up = point
    if view == 'top':
        return (320 - 2 * left, 330 - 2 * forward)
    if view == 'front':
        return (800 + 2 * left, 210 - 2 * up)
    if view == 'side':
        return (1220 - 2 * (forward - 75), 210 - 2 * up)
    raise ValueError(view)


def distance(first, second):
    return math.sqrt(sum((left - right)**2 for left, right in zip(first, second)))


class SkeletonChecks(unittest.TestCase):
    def assert_vector(self, actual, expected):
        self.assertEqual(len(actual), len(expected))
        for actual_value, expected_value in zip(actual, expected):
            self.assertAlmostEqual(actual_value, expected_value, delta=1e-9)

    def test_candidate_values_and_units(self):
        self.assertEqual(DATA['units'], 'mm')
        self.assertEqual(DATA['body'], {'length': 180, 'width': 110})
        self.assertEqual(DATA['parameters'], dict(half_length=75, half_width=55, height=0,
                                                forward=0, outward=25, vertical=0,
                                                upper=70, lower=85))
        self.assertEqual(DATA['reference_angles_rad'], [0, 0, 0])
        self.assertEqual(set(DATA['legs']), {'FL', 'FR', 'RL', 'RR'})

    def test_coordinate_table_matches_frame_contract(self):
        for name, leg in DATA['legs'].items():
            self.assertEqual(leg['front'], 1 if name.startswith('F') else -1)
            self.assertEqual(leg['side'], 1 if name.endswith('L') else -1)
            points, _, _ = skeleton(leg['front'], leg['side'], DATA['reference_angles_rad'],
                                    DATA['parameters'])
            for label, calculated in zip(('O', 'H', 'K', 'P'), points):
                self.assert_vector(leg['points'][label], calculated)

    def test_distances_and_chassis_relationships(self):
        half_length = DATA['body']['length'] / 2
        half_width = DATA['body']['width'] / 2
        for leg in DATA['legs'].values():
            points = leg['points']
            self.assertEqual(half_length - abs(points['O'][0]), 15)
            self.assertEqual(abs(points['O'][1]), half_width)
            self.assertEqual(points['O'][2], 0)
            for label in ('H', 'K', 'P'):
                self.assertEqual(abs(points[label][1]) - half_width, 25)
                self.assertEqual(points[label][0], points['O'][0])
            for first, second, expected in (('O', 'H', 25), ('H', 'K', 70),
                                            ('K', 'P', 85), ('H', 'P', 155)):
                self.assertAlmostEqual(distance(points[first], points[second]), expected)
        left = DATA['legs']['FL']['points']
        right = DATA['legs']['FR']['points']
        rear = DATA['legs']['RL']['points']
        self.assertEqual(distance(left['O'], right['O']), 110)
        self.assertEqual(distance(left['H'], right['H']), 160)
        self.assertEqual(distance(left['O'], rear['O']), 150)

    def test_candidate_mapping_at_zero_and_perturbed_angles(self):
        for angles in ((0, 0, 0), (0.19, 0.47, 0.81), (-0.23, -0.31, 0.68)):
            front_left, _, _ = skeleton(1, 1, angles, DATA['parameters'])
            for name, leg in DATA['legs'].items():
                points, _, _ = skeleton(leg['front'], leg['side'], angles, DATA['parameters'])
                for original, mapped in zip(front_left, points):
                    self.assert_vector(mapped, (original[0] - (150 if name.startswith('R') else 0),
                                                original[1] * leg['side'], original[2]))

    def test_svg_markers_and_link_projections(self):
        marker_count = 0
        line_count = 0
        segments = {'offset': ('O', 'H'), 'upper': ('H', 'K'), 'lower': ('K', 'P')}
        for identifier, element in ELEMENTS.items():
            match = re.fullmatch(r'(top|front|side)-(FL|FR|RL|RR)-(O|H|K|P)', identifier)
            if match:
                view, name, point = match.groups()
                self.assert_vector((float(element.get('cx')), float(element.get('cy'))),
                                   project(view, DATA['legs'][name]['points'][point]))
                marker_count += 1
            match = re.fullmatch(r'(top|front|side)-(FL|FR|RL|RR)-(offset|upper|lower)', identifier)
            if match:
                view, name, segment = match.groups()
                for endpoint, point in enumerate(segments[segment], start=1):
                    self.assert_vector((float(element.get(f'x{endpoint}')),
                                        float(element.get(f'y{endpoint}'))),
                                       project(view, DATA['legs'][name]['points'][point]))
                line_count += 1
        self.assertEqual(marker_count, 19)
        self.assertEqual(line_count, 12)
        body = ELEMENTS['body-plan']
        self.assert_vector((float(body.get('x')), float(body.get('y'))),
                           project('top', (90, 55, 0)))
        self.assertEqual(float(body.get('width')), 2 * DATA['body']['width'])
        self.assertEqual(float(body.get('height')), 2 * DATA['body']['length'])
        for view in ('top', 'front', 'side'):
            self.assertEqual(float(ELEMENTS[f'{view}-view'].get('data-scale')), 2)

    def test_svg_dimension_lengths_and_labels(self):
        dimensions = {'body-width': 110, 'body-length': 180, 'root-length': 150,
                      'end-inset': 15, 'offset': 25, 'pitch-width': 160,
                      'upper': 70, 'lower': 85, 'straight': 155}
        for name, value in dimensions.items():
            line = ELEMENTS[f'dim-{name}']
            start = (float(line.get('x1')), float(line.get('y1')))
            end = (float(line.get('x2')), float(line.get('y2')))
            self.assertAlmostEqual(distance(start, end), 2 * value)
            text = ''.join(ELEMENTS[f'label-{name}'].itertext())
            self.assertRegex(text, rf'^{value} mm(?: |$)')

    def test_coordinate_documentation_and_scope_labels(self):
        document = (DIRECTORY.parent / 'docs' / 'leg-skeleton.md').read_text(encoding='utf-8')
        for name, leg in DATA['legs'].items():
            coordinates = ['(' + ', '.join(str(value) for value in leg['points'][label]) + ')'
                           for label in ('O', 'H', 'K', 'P')]
            self.assertIn('| ' + name + ' | ' + ' | '.join(coordinates) + ' |', document)
        svg_text = ' '.join(DRAWING.itertext())
        self.assertIn('NOT a standing pose', svg_text)
        self.assertIn('clearance unverified', svg_text)
        self.assertIn('body thickness and underside height remain undefined', svg_text)


if __name__ == '__main__':
    unittest.main(verbosity=2)
