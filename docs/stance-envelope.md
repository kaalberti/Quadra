# Limited stance domain — TOR-012

Sample common foot fore/aft offset -10..10 mm and hip datum height 110..130 mm
on a 1 mm grid (441 poses), all legs q1=0 and feet at y=+/-80 mm. This is a
four-foot quasi-static stance adjustment, not lifted-foot stepping or a gait.
Analytical planar geometry solves q2/q3; forward geometry checks every foot.

Sampled q2 is 32.093..55.507 degrees and q3 65.816..90.120 degrees, within
candidate desired travel. Every assumed COM box stays inside support. Maximum
conservative absolute bounds in Nm (q1/q2/q3):

| Candidate | q1 | q2 | q3 |
| --- | --- | --- | --- |
| HS-5085MG | 0.17332 | 0.12966 | 0.43612 |
| XL330-M288-T | 0.17038 | 0.13196 | 0.43338 |
| XC330-M288-T | 0.17415 | 0.12901 | 0.43689 |

All reported maxima occur at front-left, x=-10 mm, height110 mm (ties possible).
These are maxima of conservative intervals on sampled poses, not exact physical
loads or certified continuous-domain maxima. No claim between grid points;
q1 motion, three-foot support, horizontal forces and dynamics are excluded.

Source and results: ../mechanical/stance_envelope.py and stance-envelope.json.
Validation: every pose checks FK position and coplanarity; equilibrium support
checks run for each candidate. Existing 60 tests passed before this addition;
final suite includes independent inverse-geometry and regeneration checks.
