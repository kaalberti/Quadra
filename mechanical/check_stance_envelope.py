import json
import math
import unittest
from stance_envelope import pose, report
from stance_loads import HERE
from mass_accounting import BASE
from check_leg_frames import skeleton
from packaging_screen import boxes, separation, report as packaging, drawing

class EnvelopeChecks(unittest.TestCase):
    def test_planar_geometry(self):
        for x in (-10,0,10):
            for h in (110,120,130):
                q=pose(x,h)
                self.assertAlmostEqual(70*math.sin(q[1])+85*math.sin(q[1]-q[2]),x)
                self.assertAlmostEqual(70*math.cos(q[1])+85*math.cos(q[1]-q[2]),h)
                self.assertTrue(-40<=math.degrees(q[1])<=85)
                self.assertTrue(20<=math.degrees(q[2])<=130)

    def test_full_grid_reproducibility(self):
        self.assertEqual(json.loads((HERE/'stance-envelope.json').read_text()),report())

    def test_separating_axis_positive_and_overlap_controls(self):
        a=boxes(pose(0,120))[0]
        self.assertLess(separation(a,a),0)
        b=dict(a,vertices_mm=[(p[0]+100,p[1],p[2]) for p in a['vertices_mm']])
        self.assertAlmostEqual(separation(a,b),74)
        # Every pair must have a separating axis in all five selected poses.
        for data in packaging()['poses'].values():
            self.assertTrue(all(v>0 for v in data['pair_projection_gap_mm'].values()))

    def test_packaging_dimensions_and_COM_assumptions(self):
        from attachment_loads import HALF
        from packaging_screen import LIMITS
        for limits in LIMITS:
            self.assertEqual(sorted(b-a for a,b in limits),[20,26,34])
            for (a,b),bound in zip(limits,HALF):
                self.assertTrue(-bound<=a<=b<=bound)
        r=packaging()
        self.assertEqual(json.loads((HERE/'packaging-screen.json').read_text()),
                         json.loads(json.dumps(r)))
        self.assertEqual((HERE/'single-leg-packaging.svg').read_text(encoding='utf-8'),drawing(r))

if __name__=='__main__': unittest.main()
