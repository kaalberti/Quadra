"""Synthetic accounting fixtures only: none are robot mass/placement choices."""
import json
import unittest

from mass_accounting import (ANGLES, BASE, DIRECTORY, G, build_report, correction,
                             position, validate)


def row(identifier='fixture', leg='FL', attachment='lower', mass=.1, com=None):
    return {'id': identifier, 'leg': leg, 'attachment': attachment, 'mass_kg': mass,
            'com_local_mm': [0, 0, -42.5] if com is None else com,
            'evidence': 'SYNTHETIC test fixture; not a component estimate'}


def inventory(*rows):
    return {'coverage_complete': True, 'components': list(rows)}


class MassAccountingChecks(unittest.TestCase):
    def test_nominal_independent_lever_arms(self):
        # Lower-link midpoint is x=half the nominal knee x relative to H.
        knee_x = (70**2 - 50.3125**2)**.5 / 1000
        for leg in BASE['legs']:
            actual = correction(row(leg=leg), leg)
            expected = [.1*G*.025, .1*G*knee_x/2, .1*G*knee_x/2]
            for a, b in zip(actual, expected):
                self.assertAlmostEqual(a, b, places=11)

    def test_potential_energy_gradient_all_attachments_and_legs(self):
        # d(m*g*z)/dq independently verifies sign and upstream membership.
        for leg in BASE['legs']:
            for attachment in ('body', 'hip_carrier', 'upper', 'lower'):
                component = row(leg=leg, attachment=attachment, com=[13, -7, -21])
                actual = correction(component, leg)
                for j in range(3):
                    plus, minus = list(ANGLES), list(ANGLES)
                    plus[j] += 1e-6
                    minus[j] -= 1e-6
                    gradient = .1*G*.001*(position(component, plus)[2]-position(component, minus)[2])/2e-6
                    self.assertAlmostEqual(actual[j], gradient, places=9)

    def test_mass_once_strict_ceiling_and_no_contact_mass_addition(self):
        result = build_report(inventory(row('body', None, 'body', 1.0), row('leg', mass=.2)))
        self.assertAlmostEqual(result['total_mass_kg'], 1.2)
        self.assertFalse(result['below_1_2_kg'])
        self.assertEqual(result['gravity_hold_nm_by_leg']['FR'], [0]*3)
        result = build_report(inventory(row(mass=1.199)))
        self.assertTrue(result['below_1_2_kg'])

    def test_unknowns_propagate_only_to_affected_joints(self):
        component = row(attachment='upper', mass=None)
        result = build_report(inventory(component))
        self.assertIsNone(result['total_mass_kg'])
        self.assertEqual(result['gravity_hold_nm_by_leg']['FL'], [None, None, 0])
        self.assertEqual(result['gravity_hold_nm_by_leg']['RR'], [0]*3)
        component['mass_kg'] = .1
        component['com_local_mm'] = None
        self.assertEqual(correction(component, 'FL'), [None, None, 0])
        component['attachment'] = None
        component['leg'] = None
        for leg in BASE['legs']:
            self.assertEqual(correction(component, leg), [None]*3)

    def test_incomplete_coverage_cannot_pass(self):
        data = inventory(row())
        data['coverage_complete'] = False
        result = build_report(data)
        self.assertIsNone(result['below_1_2_kg'])
        self.assertIsNone(result['total_mass_kg'])
        self.assertEqual(result['gravity_hold_nm_by_leg']['FL'], [None]*3)

    def test_additivity_and_mirrored_local_coordinates(self):
        a = row('a', com=[12, 7, -30])
        b = row('b', mass=.2, com=[-4, 5, -20])
        result = build_report(inventory(a, b))['gravity_hold_nm_by_leg']['FL']
        for j in range(3):
            self.assertAlmostEqual(result[j], correction(a, 'FL')[j]+correction(b, 'FL')[j])
        mirrored = row('right', 'FR', com=[12, -7, -30])
        rear = row('rear', 'RL', com=[12, 7, -30])
        for other, name in ((mirrored, 'FR'), (rear, 'RL')):
            for x, y in zip(correction(a, 'FL'), correction(other, name)):
                self.assertAlmostEqual(x, y)

    def test_invalid_inputs_fail(self):
        with self.assertRaises(ValueError):
            validate(inventory(row(), row()))
        for field, value in [('mass_kg', -1), ('mass_kg', float('nan')),
                             ('mass_kg', True), ('attachment', 'knee_servo'),
                             ('leg', 'XX'), ('com_local_mm', [1, 2]),
                             ('com_local_mm', [0, float('inf'), 0]), ('evidence', '')]:
            component = row()
            component[field] = value
            with self.subTest(field=field, value=value), self.assertRaises(ValueError):
                validate(inventory(component))

    def test_template_is_explicitly_unresolved(self):
        data = json.loads((DIRECTORY/'mass-inventory.json').read_text())
        self.assertFalse(data['coverage_complete'])
        self.assertEqual(len([r for r in data['components'] if '_actuator_' in r['id']]), 12)
        self.assertTrue(all(r['mass_kg'] is None for r in data['components']))
        result = build_report(data)
        self.assertIsNone(result['total_mass_kg'])
        for values in result['gravity_hold_nm_by_leg'].values():
            self.assertEqual(values, [None]*3)


if __name__ == '__main__':
    unittest.main(verbosity=2)
