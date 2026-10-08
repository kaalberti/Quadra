import json
import unittest
from attachment_loads import MASSES, report, gravity_bounds
from stance_loads import components, screen, HERE
from mass_accounting import correction, ANGLES

class StanceChecks(unittest.TestCase):
    def test_mass_partition(self):
        for m in MASSES:
            cs=components(m)
            self.assertAlmostEqual(sum(r['mass_kg'] for r,h in cs),1.2)
            self.assertTrue(all(r['mass_kg']>=0 for r,h in cs))
            # 12 installed assemblies at 30 g + 160 g moving printed mass.
            self.assertAlmostEqual(cs[-1][0]['mass_kg'],.680)

    def test_attachment_and_symmetry(self):
        for m in MASSES:
            bs=gravity_bounds(m)
            self.assertEqual(bs['FL'],bs['FR'])
            self.assertEqual(bs['FL'][2],[0.,0.])

    def test_reaction_extrema_independently(self):
        # Four rectangular supports: weights t, A-t, B-t, 1-A-B+t.
        # Endpoint solutions independently enforce sum and x/y equilibrium.
        for model in MASSES:
            r=screen(model)
            for x in r['COM_bounds_mm'][0]:
                for y in r['COM_bounds_mm'][1]:
                    A=(x+75)/150; B=(y+80)/160
                    for t in (max(0,A+B-1),min(A,B)):
                        w=[t,A-t,B-t,1-A-B+t]
                        self.assertGreaterEqual(min(w),-1e-12)
                        self.assertAlmostEqual(sum(w),1)
                        self.assertAlmostEqual(75*(w[0]+w[1]-w[2]-w[3]),x)
                        self.assertAlmostEqual(80*(w[0]+w[2]-w[1]-w[3]),y)
                        for n,v in zip(('FL','FR','RL','RR'),w):
                            low,high=r['legs'][n]['contact_share']
                            self.assertGreaterEqual(v,low-1e-12)
                            self.assertLessEqual(v,high+1e-12)

    def test_independent_gravity_lever(self):
        row=dict(leg='FL',attachment='upper',mass_kg=.1,com_local_mm=(0,0,-70))
        import math
        values=correction(row,'FL')
        self.assertAlmostEqual(values[0],.1*9.80665*.025)
        self.assertAlmostEqual(values[1],.1*9.80665*.070*math.sin(ANGLES[1]))
        self.assertEqual(values[2],0)

    def test_saved_results(self):
        self.assertEqual(json.loads((HERE/'attachment-loads.json').read_text()),
                         json.loads(json.dumps(report())))
        self.assertEqual(json.loads((HERE/'nominal-loads.json').read_text()),
                         {m:screen(m) for m in MASSES})

if __name__=='__main__': unittest.main()
