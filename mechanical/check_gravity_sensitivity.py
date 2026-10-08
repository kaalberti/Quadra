"""Independent TOR-008 checks; no fixture is a real component choice."""
import json
import math
import unittest
from gravity_sensitivity import build_report, coefficient
from mass_accounting import ANGLES, BASE, DIRECTORY, G, correction


class GravitySensitivityChecks(unittest.TestCase):
    def test_reference_coefficients_independent_triangle(self):
        x = math.sqrt(70**2-50.3125**2)*.001
        expected = [[G*.025,0,0], [G*.025,0,0], [G*.025,G*x/2,0],
                    [G*.025,G*x,0], [G*.025,G*x,0],
                    [G*.025,G*x/2,G*x/2], [G*.025,0,G*x]]
        for row, target in zip(build_report()['references'], expected):
            for a,b in zip(row['gravity_hold_nm_per_kg'],target):
                self.assertAlmostEqual(a,b,places=11)

    def test_gradients_independent_nominal_axes(self):
        for row in build_report()['references']:
            attachment = row['attachment']
            theta = {'hip_carrier':0, 'upper':-ANGLES[1],
                     'lower':ANGLES[2]-ANGLES[1]}[attachment]
            pitch = attachment != 'hip_carrier'
            knee = attachment == 'lower'
            expected = [[0, G*.001*math.cos(theta) if pitch else 0,
                         -G*.001*math.cos(theta) if knee else 0],
                        [G*.001,0,0],
                        [0,G*.001*math.sin(theta) if pitch else 0,
                         -G*.001*math.sin(theta) if knee else 0]]
            for a,b in zip(row['gradient_nm_per_kg_mm_columns_xyz'],expected):
                for x,y in zip(a,b): self.assertAlmostEqual(x,y,places=12)

    def test_affine_reconstruction_mass_scaling_and_all_leg_mapping(self):
        delta = [11,-8,6]  # synthetic offsets only
        for row in build_report()['references']:
            com = [x+y for x,y in zip(row['com_local_mm_FL'],delta)]
            prediction = [row['gravity_hold_nm_per_kg'][j] + sum(
                delta[k]*row['gradient_nm_per_kg_mm_columns_xyz'][k][j]
                for k in range(3)) for j in range(3)]
            for leg, info in BASE['legs'].items():
                mirrored = [com[0], info['side']*com[1], com[2]]
                actual = correction({'attachment':row['attachment'], 'leg':leg,
                    'mass_kg':.037, 'com_local_mm':mirrored},leg)
                for a,b in zip(actual,prediction): self.assertAlmostEqual(a,.037*b,places=12)

    def test_saved_output_and_unknown_inventory(self):
        self.assertEqual(json.loads((DIRECTORY/'gravity-sensitivity.json').read_text()),build_report())
        inventory=json.loads((DIRECTORY/'mass-inventory.json').read_text())
        self.assertTrue(all(r['mass_kg'] is None for r in inventory['components']))


if __name__ == '__main__':
    unittest.main(verbosity=2)
