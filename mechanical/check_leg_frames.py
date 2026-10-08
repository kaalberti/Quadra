"""Offline verification of docs/leg-frames.md; fixtures are not design choices."""

import math
import random
import unittest


def add(first, second):
    return tuple(left + right for left, right in zip(first, second))


def subtract(first, second):
    return tuple(left - right for left, right in zip(first, second))


def scale(vector, factor):
    return tuple(value * factor for value in vector)


def dot(first, second):
    return sum(left * right for left, right in zip(first, second))


def cross(first, second):
    return (
        first[1] * second[2] - first[2] * second[1],
        first[2] * second[0] - first[0] * second[2],
        first[0] * second[1] - first[1] * second[0],
    )


def columns(matrix):
    return tuple(zip(*matrix))


def apply(matrix, vector):
    return tuple(dot(row, vector) for row in matrix)


def multiply(first, second):
    return tuple(tuple(dot(row, column) for column in columns(second)) for row in first)


def rotation_x(angle):
    cosine, sine = math.cos(angle), math.sin(angle)
    return ((1, 0, 0), (0, cosine, -sine), (0, sine, cosine))


def rotation_y(angle):
    cosine, sine = math.cos(angle), math.sin(angle)
    return ((cosine, 0, sine), (0, 1, 0), (-sine, 0, cosine))


FIXTURE = dict(half_length=73, half_width=54, height=-8,
               forward=6, outward=23, vertical=-4, upper=70, lower=85)
LEGS = ((1, 1), (1, -1), (-1, 1), (-1, -1))


def skeleton(front, side, angles, parameters=FIXTURE):
    abduction, hip, knee = angles
    root = (front * parameters['half_length'], side * parameters['half_width'],
            parameters['height'])
    abducted = rotation_x(side * abduction)
    upper = multiply(abducted, rotation_y(-hip))
    lower = multiply(upper, rotation_y(knee))
    hip_origin = add(root, apply(abducted, (parameters['forward'],
                                          side * parameters['outward'],
                                          parameters['vertical'])))
    knee_origin = add(hip_origin, apply(upper, (0, 0, -parameters['upper'])))
    foot = add(knee_origin, apply(lower, (0, 0, -parameters['lower'])))
    axes = ((side, 0, 0), apply(abducted, (0, -1, 0)), apply(upper, (0, 1, 0)))
    return (root, hip_origin, knee_origin, foot), (abducted, upper, lower), axes


class FrameChecks(unittest.TestCase):
    def setUp(self):
        generator = random.Random(12003)
        self.poses = [(0, 0, 0), (0.2, 0.4, 0.8), (-0.3, -0.5, -0.7)]
        self.poses.extend(tuple(generator.uniform(-1.5, 1.5) for _ in range(3))
                          for _ in range(40))

    def assert_vector(self, actual, expected, tolerance=1e-9):
        self.assertEqual(len(actual), len(expected))
        for actual_value, expected_value in zip(actual, expected):
            self.assertAlmostEqual(actual_value, expected_value, delta=tolerance)

    def test_frames_are_right_handed_and_orthonormal(self):
        for front, side in LEGS:
            for angles in self.poses:
                _, frames, _ = skeleton(front, side, angles)
                for frame in frames:
                    basis = columns(frame)
                    self.assert_vector(cross(basis[0], basis[1]), basis[2])
                    self.assertAlmostEqual(dot(basis[0], cross(basis[1], basis[2])), 1)
                    for row_index in range(3):
                        for column_index in range(3):
                            self.assertAlmostEqual(dot(basis[row_index], basis[column_index]),
                                                   float(row_index == column_index))

    def test_zero_geometry_and_axis_signs(self):
        for front, side in LEGS:
            points, _, axes = skeleton(front, side, (0, 0, 0))
            self.assert_vector(points[0], (front * 73, side * 54, -8))
            self.assert_vector(points[1], (front * 73 + 6, side * 77, -12))
            self.assert_vector(points[2], (front * 73 + 6, side * 77, -82))
            self.assert_vector(points[3], (front * 73 + 6, side * 77, -167))
            for actual, expected in zip(axes, ((side, 0, 0), (0, -1, 0), (0, 1, 0))):
                self.assert_vector(actual, expected)

    def test_positive_motion(self):
        for front, side in LEGS:
            neutral, _, _ = skeleton(front, side, (0, 0, 0))
            abducted, _, _ = skeleton(front, side, (0.001, 0, 0))
            pitched, _, _ = skeleton(front, side, (0, 0.001, 0))
            flexed, _, _ = skeleton(front, side, (0, 0, 0.001))
            self.assertGreater(side * (abducted[3][1] - neutral[3][1]), 0)
            self.assertGreater(pitched[2][0] - neutral[2][0], 0)
            self.assertLess(flexed[3][0] - neutral[3][0], 0)

    def test_axis_relationships_and_link_lengths(self):
        for front, side in LEGS:
            for angles in self.poses:
                points, _, axes = skeleton(front, side, angles)
                self.assert_vector(axes[1], scale(axes[2], -1))
                self.assertAlmostEqual(dot(axes[0], axes[1]), 0)
                for axis in axes:
                    self.assertAlmostEqual(dot(axis, axis), 1)
                for start, end, length in ((points[1], points[2], 70),
                                           (points[2], points[3], 85)):
                    link = subtract(end, start)
                    self.assertAlmostEqual(math.sqrt(dot(link, link)), length)
                    self.assertAlmostEqual(dot(link, axes[1]), 0)
                offset = subtract(points[1], points[0])
                self.assertAlmostEqual(dot(offset, offset), 6**2 + 23**2 + 4**2)

    def test_left_right_reflection_and_axial_vector_mapping(self):
        for front in (1, -1):
            for angles in self.poses:
                left, _, left_axes = skeleton(front, 1, angles)
                right, _, right_axes = skeleton(front, -1, angles)
                for original, mirrored in zip(left, right):
                    self.assert_vector(mirrored, (original[0], -original[1], original[2]))
                for original, mirrored in zip(left_axes, right_axes):
                    self.assert_vector(mirrored, (-original[0], original[1], -original[2]))

    def test_front_rear_translation(self):
        for side in (1, -1):
            for angles in self.poses:
                front_points, front_frames, front_axes = skeleton(1, side, angles)
                rear_points, rear_frames, rear_axes = skeleton(-1, side, angles)
                for front_point, rear_point in zip(front_points, rear_points):
                    self.assert_vector(subtract(rear_point, front_point), (-146, 0, 0))
                self.assertEqual(front_frames, rear_frames)
                self.assertEqual(front_axes, rear_axes)

    def test_scalar_equation_matches_matrix_chain(self):
        for parameters in (FIXTURE, dict(FIXTURE, forward=-9, outward=0, vertical=12,
                                         upper=61, lower=93)):
            for front, side in LEGS:
                for abduction, hip, knee in self.poses:
                    points, _, _ = skeleton(front, side, (abduction, hip, knee), parameters)
                    forward = (parameters['forward'] + parameters['upper'] * math.sin(hip)
                               + parameters['lower'] * math.sin(hip - knee))
                    lateral = side * parameters['outward']
                    vertical = (parameters['vertical'] - parameters['upper'] * math.cos(hip)
                                - parameters['lower'] * math.cos(hip - knee))
                    expected = (forward,
                                lateral * math.cos(abduction) - side * vertical * math.sin(abduction),
                                side * lateral * math.sin(abduction) + vertical * math.cos(abduction))
                    self.assert_vector(subtract(points[3], points[0]), expected)

    def test_joint_derivatives_match_axis_cross_lever_arm(self):
        step = 1e-6
        for front, side in LEGS:
            for angles in self.poses:
                points, _, axes = skeleton(front, side, angles)
                for joint in range(3):
                    plus, minus = list(angles), list(angles)
                    plus[joint] += step
                    minus[joint] -= step
                    plus_points, _, _ = skeleton(front, side, plus)
                    minus_points, _, _ = skeleton(front, side, minus)
                    measured = scale(subtract(plus_points[3], minus_points[3]), 1 / (2 * step))
                    expected = cross(axes[joint], subtract(points[3], points[joint]))
                    self.assert_vector(measured, expected, tolerance=1e-6)


if __name__ == '__main__':
    unittest.main(verbosity=2)
