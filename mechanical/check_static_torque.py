"""Independent checks of nominal static torque and MG90S source/comparison arithmetic."""

import hashlib
import json
import math
import unittest

import static_torque as analysis
from check_leg_frames import skeleton


REPORT = json.loads((analysis.DIRECTORY / 'static-torque.json').read_text(encoding='utf-8'))
DOCUMENT = (analysis.DIRECTORY.parent / 'docs' / 'static-servo-torque.md').read_text(encoding='utf-8')


class StaticTorqueChecks(unittest.TestCase):
    def test_inputs_units_and_source_freshness(self):
        self.assertEqual(analysis.INPUTS['robot_mass_kg'], 1.2)
        self.assertEqual(analysis.INPUTS['gravity_m_s2'], 9.80665)
        self.assertEqual(analysis.INPUTS['contact_force_direction_body'], [0, 0, 1])
        self.assertEqual(analysis.INPUTS['servo_to_joint_ratio'], 1)
        self.assertEqual(analysis.INPUTS['transmission_efficiency'], 1)
        self.assertFalse(analysis.INPUTS['moving_link_gravity_included'])
        self.assertEqual(analysis.NM_PER_KGF_CM, 9.80665 * 0.01)
        for name, digest in REPORT['source_sha256'].items():
            self.assertEqual(hashlib.sha256((analysis.DIRECTORY / name).read_bytes()).hexdigest(), digest)
        self.assertEqual(analysis.build_report(), REPORT)

    def test_independent_triangle_lever_arms_and_all_leg_signs(self):
        upper, lower, height = 70, 85, 120
        knee_z = (lower**2 - upper**2 - height**2) / (2 * height)
        knee_x_m = math.sqrt(upper**2 - knee_z**2) / 1000
        for case in REPORT['cases'].values():
            force = 1.2 * 9.80665 * case['weight_share']
            self.assertAlmostEqual(case['foot_force_body_n'][2], force)
            expected = (-0.025 * force, 0, -knee_x_m * force)
            for torques in case['balancing_torque_nm_by_leg'].values():
                for actual, target in zip(torques, expected):
                    self.assertAlmostEqual(actual, target, delta=1e-10)
            expected_kgf_cm = (1.2 * case['weight_share'] * 2.5, 0,
                               1.2 * case['weight_share'] * knee_x_m * 100)
            for actual, target in zip(case['magnitude_kgf_cm'], expected_kgf_cm):
                self.assertAlmostEqual(actual, target, delta=1e-10)

    def test_finite_difference_virtual_work(self):
        step = 1e-6
        angles = tuple(map(math.radians, analysis.POSE['joint_angles_degrees_all_legs']))
        for name, leg in analysis.BASE['legs'].items():
            for case in REPORT['cases'].values():
                for joint in range(3):
                    positive, negative = list(angles), list(angles)
                    positive[joint] += step
                    negative[joint] -= step
                    positive_points, _, _ = skeleton(leg['front'], leg['side'], positive, analysis.BASE['parameters'])
                    negative_points, _, _ = skeleton(leg['front'], leg['side'], negative, analysis.BASE['parameters'])
                    derivative_m = (positive_points[-1][2] - negative_points[-1][2]) / (2 * step * 1000)
                    balancing = -derivative_m * case['foot_force_body_n'][2]
                    self.assertAlmostEqual(case['balancing_torque_nm_by_leg'][name][joint], balancing, delta=1e-8)

    def test_source_voltage_discrepancy_and_unknown_continuous_rating(self):
        servo = analysis.INPUTS['servo_candidate']
        self.assertIsNone(servo['continuous_holding_torque_nm'])
        self.assertIsNone(servo['voltage_selected'])
        current, sheet = servo['sources']
        self.assertEqual(current['stall_ratings'][0], sheet['stall_ratings'][0])
        self.assertEqual(current['stall_ratings'][0], {'kgf_cm': 1.8, 'voltage_v': 4.8})
        self.assertEqual(current['stall_ratings'][1], {'kgf_cm': 2.2, 'voltage_v': 6.6})
        self.assertEqual(sheet['stall_ratings'][1], {'kgf_cm': 2.2, 'voltage_v': 6.0})
        for source in servo['sources']:
            self.assertIn(source['url'], DOCUMENT)

    def test_comparison_ratios_and_feasibility_flags(self):
        for case in REPORT['cases'].values():
            for name, rating in REPORT['stall_comparison_nm'].items():
                for magnitude, ratio in zip(case['magnitude_nm'], case['fraction_of_published_stall'][name]):
                    self.assertAlmostEqual(ratio, magnitude / rating)
        quarter, third, half = (REPORT['cases'][name] for name in ('quarter_weight', 'third_weight', 'half_weight'))
        for rating in REPORT['stall_comparison_nm'].values():
            self.assertLess(quarter['magnitude_nm'][2], rating)
            self.assertGreater(half['magnitude_nm'][2], rating)
        self.assertGreater(third['magnitude_nm'][2], REPORT['stall_comparison_nm']['baseline_4v8'])
        self.assertLess(third['magnitude_nm'][2], REPORT['stall_comparison_nm']['optimistic_published'])
        for quarter_value, half_value in zip(quarter['magnitude_nm'], half['magnitude_nm']):
            self.assertAlmostEqual(2 * quarter_value, half_value)

    def test_load_distribution_equilibrium_examples(self):
        feet = analysis.POSE['legs']
        centroid = tuple(sum(feet[name]['P'][axis] for name in ('FR', 'RL', 'RR')) / 3 for axis in (0, 1))
        self.assertAlmostEqual(centroid[0], -25)
        self.assertAlmostEqual(centroid[1], -80 / 3)
        for axis in (0, 1):
            self.assertEqual(0.5 * feet['FR']['P'][axis] + 0.5 * feet['RL']['P'][axis], 0)
            self.assertEqual(sum(points['P'][axis] / 4 for points in feet.values()), 0)

    def test_documented_result_tables(self):
        for name, case in REPORT['cases'].items():
            values = [case['foot_force_body_n'][2], *case['magnitude_nm']]
            self.assertIn('| ' + name + ' | ' + ' | '.join(f'{value:.6f}' for value in values) + ' |', DOCUMENT)
            self.assertIn('| ' + name + ' | ' + ' | '.join(f'{value:.6f}' for value in case['magnitude_kgf_cm']) + ' |', DOCUMENT)
            ratios = [case['fraction_of_published_stall'][rating][2] * 100
                      for rating in ('baseline_4v8', 'optimistic_published')]
            self.assertIn('| ' + name + ' | ' + ' | '.join(f'{value:.1f}%' for value in ratios) + ' |', DOCUMENT)
        self.assertIn('not a valid\ncontinuous holding specification', DOCUMENT)
        self.assertIn('neither guaranteed upper nor lower bounds', DOCUMENT)


if __name__ == '__main__':
    unittest.main(verbosity=2)
