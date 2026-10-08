"""Independent checks of KIN-005 extrema, mapping, projections, and source freshness."""

import hashlib
import itertools
import json
import math
import random
import unittest
import xml.etree.ElementTree as element_tree

import foot_workspace as workspace
from check_leg_frames import skeleton


REPORT = json.loads((workspace.DIRECTORY / 'foot-workspace.json').read_text(encoding='utf-8'))
DOCUMENT = (workspace.DIRECTORY.parent / 'docs' / 'foot-workspace.md').read_text(encoding='utf-8')


class WorkspaceChecks(unittest.TestCase):
    def assert_vector(self, actual, expected):
        self.assertEqual(len(actual), len(expected))
        for actual_value, expected_value in zip(actual, expected):
            self.assertAlmostEqual(actual_value, expected_value, delta=1e-6)

    def test_source_hashes_and_reproducible_artifacts(self):
        for name, digest in REPORT['source_sha256'].items():
            self.assertEqual(hashlib.sha256((workspace.DIRECTORY / name).read_bytes()).hexdigest(), digest)
        generated, bins = workspace.build_report()
        self.assertEqual(json.loads(json.dumps(generated)), REPORT)
        self.assertEqual(workspace.render_svg(generated, bins),
                         (workspace.DIRECTORY / 'foot-workspace.svg').read_text(encoding='utf-8'))

    def test_extremum_witnesses_against_matrix_chain(self):
        root = workspace.BASE['legs']['FL']['points']['O']
        for axis, extremes in REPORT['continuous_extrema'].items():
            for record in extremes.values():
                angles = record['angles_degrees']
                for angle, (lower, upper) in zip(angles, workspace.BOUNDS):
                    self.assertGreaterEqual(angle, lower - 1e-9)
                    self.assertLessEqual(angle, upper + 1e-9)
                points, _, _ = skeleton(1, 1, tuple(map(math.radians, angles)), workspace.PARAMETERS)
                local = tuple(value - origin for value, origin in zip(points[-1], root))
                self.assertAlmostEqual(local[workspace.AXES.index(axis)], record['value_mm'], delta=1e-6)
                self.assert_vector(local, workspace.foot_local(angles))

    def test_dense_one_degree_grid_is_enclosed(self):
        bounds = REPORT['local_enclosing_box_mm']
        count = 0
        for angles in itertools.product(*(workspace.angle_grid(*interval, 1) for interval in workspace.BOUNDS)):
            for axis, coordinate in zip(workspace.AXES, workspace.foot_local(angles)):
                self.assertGreaterEqual(coordinate, bounds[axis][0] - 1e-9)
                self.assertLessEqual(coordinate, bounds[axis][1] + 1e-9)
            count += 1
        self.assertEqual(count, 783216)

    def test_independent_radius_identity_and_unreachable_box_point(self):
        parameters = workspace.PARAMETERS
        outer = math.sqrt(parameters['outward']**2 + parameters['upper']**2 + parameters['lower']**2
                          + 2 * parameters['upper'] * parameters['lower'] * math.cos(math.radians(20)))
        inner = math.sqrt(parameters['outward']**2 + parameters['upper']**2 + parameters['lower']**2
                          + 2 * parameters['upper'] * parameters['lower'] * math.cos(math.radians(130)))
        self.assertAlmostEqual(-REPORT['local_enclosing_box_mm']['z'][0], outer, delta=1e-6)
        self.assertGreater(inner, 0)
        for lower, upper in REPORT['local_enclosing_box_mm'].values():
            self.assertLess(lower, 0)
            self.assertGreater(upper, 0)
        generator = random.Random(12005)
        for _ in range(100):
            angles = [generator.uniform(*interval) for interval in workspace.BOUNDS]
            point = workspace.foot_local(angles)
            expected_squared = (parameters['outward']**2 + parameters['upper']**2 + parameters['lower']**2
                                + 2 * parameters['upper'] * parameters['lower'] * math.cos(math.radians(angles[2])))
            self.assertAlmostEqual(sum(value**2 for value in point), expected_squared, delta=1e-7)

    def test_all_leg_mapping_and_nominal_against_matrix_chain(self):
        generator = random.Random(12006)
        samples = [workspace.POSE['joint_angles_degrees_all_legs']]
        samples.extend(tuple(generator.uniform(*interval) for interval in workspace.BOUNDS) for _ in range(100))
        for angles in samples:
            local = workspace.foot_local(angles)
            for name, leg in workspace.BASE['legs'].items():
                points, _, _ = skeleton(leg['front'], leg['side'], tuple(map(math.radians, angles)), workspace.PARAMETERS)
                expected = (leg['front'] * 75 + local[0], leg['side'] * (55 + local[1]), local[2])
                self.assert_vector(points[-1], expected)
                for axis, value in zip(workspace.AXES, points[-1]):
                    self.assertGreaterEqual(value, REPORT['body_enclosing_boxes_mm'][name][axis][0] - 1e-9)
                    self.assertLessEqual(value, REPORT['body_enclosing_boxes_mm'][name][axis][1] + 1e-9)
        self.assert_vector(REPORT['nominal_local_mm'], (0, 25, -120))

    def test_sampling_endpoints_metadata_and_projection_elements(self):
        lengths = []
        for lower, upper in workspace.BOUNDS:
            grid = workspace.angle_grid(lower, upper, 2)
            self.assertEqual((grid[0], grid[-1]), (lower, upper))
            self.assertTrue(all(0 < second - first <= 2 for first, second in zip(grid, grid[1:])))
            lengths.append(len(grid))
        self.assertEqual(math.prod(lengths), REPORT['sampling']['point_count'])
        self.assertEqual(REPORT['sampling']['point_count'], 103936)
        drawing = element_tree.parse(workspace.DIRECTORY / 'foot-workspace.svg').getroot()
        elements = {element.get('id'): element for element in drawing.iter() if element.get('id')}
        for plane, left in workspace.PANELS:
            nominal = elements[f'nominal-{plane}']
            expected = workspace.projection(plane, left, tuple(REPORT['nominal_local_mm'][workspace.AXES.index(axis)]
                                                               for axis in plane))
            self.assert_vector((float(nominal.get('cx')), float(nominal.get('cy'))), expected)
            cell_count = elements[f'cells-{plane}'].get('d').count('M')
            self.assertEqual(cell_count, REPORT['sampling']['occupied_projection_cells'][plane])
            if plane[1] == 'z':
                expected_height = workspace.projection(plane, left, (0, -120))[1]
                self.assertEqual(float(elements[f'ground-{plane}'].get('y1')), expected_height)
            box = elements[f'bounds-{plane}']
            bounds = REPORT['local_enclosing_box_mm']
            self.assertAlmostEqual(float(box.get('width')), (bounds[plane[0]][1] - bounds[plane[0]][0]) * 1.2, delta=1e-6)
            self.assertAlmostEqual(float(box.get('height')), (bounds[plane[1]][1] - bounds[plane[1]][0]) * 1.2, delta=1e-6)

    def test_documented_bounds_and_sample_difference(self):
        labels = {'x': 'forward', 'y': 'robot-left', 'z': 'up'}
        for axis, (lower, upper) in REPORT['local_enclosing_box_mm'].items():
            self.assertIn(f'| {axis}, {labels[axis]} | {lower:.3f} | {upper:.3f} |', DOCUMENT)
            sampled = REPORT['sampling']['bounds_mm'][axis]
            self.assertGreaterEqual(sampled[0], lower - 1e-9)
            self.assertLessEqual(sampled[1], upper + 1e-9)
            self.assertLessEqual(max(abs(sampled[0] - lower), abs(sampled[1] - upper)), 0.0241)
        for name, bounds in REPORT['body_enclosing_boxes_mm'].items():
            values = bounds['x'] + bounds['y']
            self.assertIn('| ' + name + ' | ' + ' | '.join(f'{value:.3f}' for value in values) + ' |', DOCUMENT)
        self.assertIn('not a rectangular operating', DOCUMENT)
        self.assertIn('not slices at a fixed', DOCUMENT)


if __name__ == '__main__':
    unittest.main(verbosity=2)
