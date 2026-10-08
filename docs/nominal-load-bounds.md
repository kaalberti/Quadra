# Nominal static load bounds — TOR-011

This synthetic ceiling scenario has 12 installed actuator assemblies at 30 g,
160 g moving printed structure (40 g/leg), and 680 g body-fixed remainder.
The remainder includes all other budget categories, unused allowance, reserve
and the 50 g ceiling gap. Total 1200 g is a conservative load calculation, not
an acceptable measured robot mass: the operating target remains strictly less.
Public servo mass is subtracted from each assembly allowance exactly once.
All accessory allowance for a leg is placed on its upper link for this scenario.

Upper structure/accessories COM box: centre (0,0,-35), half (10,10,35) mm;
lower structure: centre (0,0,-42.5), half (10,10,42.5) mm. Body remainder COM
box is +/-20 mm in B. Servo boxes are TOR-010. These are assumed envelopes,
not validated bounds on a future assembly; actual inventory stays unknown.

For a rectangular support polygon let A be front-side mass fraction and B
left-side fraction from total COM. Four vertical reaction fractions are
(t,A-t,B-t,1-A-B+t), with max(0,A+B-1)<=t<=min(A,B). This includes contact
unloading. No arbitrary 50% cap is imposed. Whole-robot mass and COM include
moving weights once; joint torque then balances ground force and local distal
gravity. Including local gravity does not add a second ground weight.

COM box extrema and gravity extrema are affine corner calculations. Separate
contact and gravity intervals are combined conservatively; endpoints need not
be simultaneously attainable. They are upper screens, not predicted loads.
At nominal stance the largest knee upper bound across candidates/legs is in
mechanical/nominal-loads.json, approximately 0.35723 Nm. Horizontal ground force,
dynamic acceleration, friction, transmissions and thermal duty are excluded.

Validation: five new independent checks; all 60 mechanical tests passed.
Reaction endpoint tests verify nonnegative forces, total force and both moments
at every COM corner. Independent gravity lever arms and saved reproducibility
also pass. No change to kinematic dimensions or the real mass inventory.
