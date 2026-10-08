# MEC-122: budget hobby-servo cradle

The first printable CAD result on the simplified path is a reusable split
servo cradle, not a complete leg. Print the coupon and check one actual servo
before committing to three joint brackets. No chassis/electronics stage started.

## Evidence and assumptions

[TowerPro MG996R](https://towerpro.com.tw/product/mg996r/), accessed 2026-10-08:
body 40.7 x 19.7 x 42.9 mm, mass 55 g, metal gears, stall torque
9.4 kgf cm at 4.8 V, supply 4.8–6.6 V. The same page has differing
configuration-table dimensions; use the published body envelope provisionally
and verify the actual servo with the coupon. This is a packaging candidate,
not a purchasing decision or a verified sustained-torque specification.

CAD axes: x along the case length, y across its width, z upward from the
print bed. The body rests on a 3 mm floor; the cradle grips its lower 18 mm.
The 41.5 x 20.5 mm pocket has 0.8 mm total clearance. A 1 mm split permits
gentle clamping; stop when secure, without deforming the case. Side walls
are 4 mm. Cable relief is 12 x 7 mm at one short end. Ear height, case ribs,
bottom screws and cable exit are assumptions to check physically. These
dimensions do not replace the historical 25/70/85 mm kinematic skeleton.

## Minimum decision checks

At the 1.2 kg target with three supporting legs, load is 3.924 N per leg.
A nominal 49 mm horizontal knee lever plus an assumed 0.08 Nm allowance
for moving parts gives about 0.27 Nm. The published 4.8 V stall value is
0.92 Nm, approximately 3.4 times that estimate. This supports a bent-pose
prototype trial; stall torque is not a continuous operating rating.
An extended horizontal 155 mm leg gives about 0.69 Nm including the same
allowance, so full-range loaded operation is not approved by this screen.
Hip packaging and abduction loads remain the next joint-design checks.

Twelve 55 g servos total 660 g, leaving 540 g within the 1.2 kg target for
everything else. Actual mass must be weighed; this is the main drawback
of standard-size servos. Do not buy twelve until one leg works.

Budget allocation, **not current retail quotations**: servo cap NZ$25–35
each x 12 = NZ$300–420; other hardware/printing/power/logic NZ$300;
reserve NZ$80; total NZ$680–800. Confirm delivered prices before locking
hardware. The premium XC330/precision-coupling path is deferred for Rev A.

## Print and assembly

Use 0.4 mm nozzle, 0.2 mm layers, PLA+ or PETG, four perimeters and around
30% infill. Exported parts sit flat on their base. Horizontal 3.5 mm bolt
holes may need clearing with a drill; no supports are intended. Coupon
lugs have open tops because it is a shallow fit sample, not a structural part.

1. Print `hobby-servo-cradle-coupon.stl`, check the case width/length and
   cable relief. Change source dimensions if needed and re-export.
2. Print the left and right halves. Place the servo on their floors.
3. Use two M3 x 40 through bolts, washers and nuts through the end lugs.
   Tighten gently and evenly. Verify the case cannot slip or distort.
4. Mount the base using four M3 through bolts, washers and nuts, with lengths
   chosen for the receiving plate. Slots permit clamp adjustment.
5. Check cable freedom, mounting-ear clearance, access to screws and removal.

This cradle provides case support only. The next joint fork must include a
passive support opposite the horn before loading the servo shaft. No powered
load test is part of this task; supply-current and connection checks precede it.

## Independent validation and tools

User approved repository-local OpenSCAD on 2026-10-08. Portable official
OpenSCAD 2021.01 is under `mechanical/tools/openscad-2021.01`.
Source: https://github.com/openscad/openscad/releases/tag/openscad-2021.01.
No global package or dependency installation performed.

Select `part="left"`, `"right"` or `"coupon"` in the editable SCAD source.
All three exported meshes pass OpenSCAD CGAL compilation. Run
`powershell -File mechanical/check-hobby-servo-cradle.ps1` to independently
check closed mesh edges, print-bed position and regenerate the saved screen.
The assembly PNG was visually reviewed for pocket, cable slot and bolt access.
Physical fit, clamping strength and actual print quality are unverified.

Next bounded task: create one horn-driven fork with a passive opposite pivot,
using the fitted cradle. The remaining leg links follow that repeatable joint.
