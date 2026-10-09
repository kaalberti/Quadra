# ST3215 first-leg working design

Open mechanical/st3215-leg.scad; default view is the assembled nominal leg.
Parts are working prototypes,not a released manufacturing pack. The earlier
MFG-003 pack is MG996R-specific and must not be used for this design.

| STL | Pieces per leg | Purpose |
| --- | ---: | --- |
| st3215-clamp-bottom.stl |3| Fixed-case clamp halves |
| st3215-clamp-top.stl |3| Opposite clamp halves |
| st3215-hip.stl |1| J1 output and J2 fixed-case carrier |
| st3215-upper.stl |1| J2 output and J3 fixed-case support |
| st3215-lower.stl |1| J3 output;85 mm contact datum |
| st3215-mount.stl |1| J1 fixed-case mounting plate |
| st3215-shims.stl |6| One provisional wheel spacer per side |

Three12V ST3215s and six supplied-compatible wheels complete the joint interfaces.
Check the opposite wheel is a proper free support and confirm supplied hardware;
do not bolt the fork to a stationary rear case boss. No old624/M4 pivot is assumed.

Servo local shaft axis is+Z; body extends x=-10.11..35.11 mm. Pocket has0.8 mm
total allowance,1 mm clamp split gap and11 mm-long grip on the tail section.
Clamps close gently with through bolts outside the case; do not crush the shell
or bridge a connector. Actual body shape/ports may require clamp relocation. The drawing distinguishes29 mm main shell from35 mm overall case features. This conservative35.8 mm pocket may require reducing case_grip_height to the actual grip band or fitting firm removable liners; do not assume tightening can close a6 mm gap. Print/check one pair before complete leg.
Forks use5 mm plates at axial±23..28 mm,with a6 mm connecting web clear of the
case. Upper link fixes the next servo's case; lower link moves with that servo's
front wheel and opposite support wheel. Link axes remain70/85 mm apart.

The mounting plate has a notch clearing the rotating J1 hub and bolts the J1 clamp to a rigid vertical bench fixture or future
chassis. It is not a freestanding bench base. Secure the fixture before loading.
J2 bolts clamp to the hip carrier; J3 clamp bolts pass through both upper-fork
plates. Two0.5 mm spacer washers at each J3 bolt bridge nominal clamp/fork gaps.
Nominal M3 clamp bolts: fourx60 (J1/J2) and twox65 (J3),plain nuts/washers;
actual stacks/thread engagement/protrusion must be checked before buying.
J1 fixture screws depend on fixture thickness; start with fourM3 through bolts.

Wheel OD19.2 mm,PCD14 mm and total37.25 mm come from the downloaded drawing.
The drawing title saysSCS215 although linked from the ST3215 manufacturer page.
Both wheel faces are modeled symmetrically for now. Nominal4.375 mm spacer is
adjustable; measure each side rather than forcing the fork against the bearings.
Horn holes are radial6.5..7.5 mm slots,Ø3.2; use correct supplied screws and
washers after confirming thread size and engagement. CentreØ8 access permits
wheel retaining screw access. The printed clamp avoids unknown case screw threads.

Print PLA+/PETG,0.4 mm nozzle,0.2 mm layers,at least4 perimeters,moderate infill.
Files are bed-oriented. Upper and hip parts need local support under bridging
features; inspect slicer preview,especially holes and the hip bridge. Do not infer
support-free printing from an STL bounding-box check. Print one clamp pair and
wheel spacer first,then revise fit as needed. Sixteen pieces is a prototype count,
not an instruction to print four full legs before the first works.

Nominal foot point is approximately[85,0,-120]mm before J1 rotation,not the old
MG996R[85,32,-120] datum. The lower tip has a flat20 x56 mm nominal contact surface and anM3-size hole for a removable rubber/EVA
contact pad; a temporary secured pad is adequate. Its attachment is untested; pad thickness shifts the contact datum. Local support is also needed beneath the lower foot crosspiece.
No loaded limits or full swept collision range is released.

Run `node mechanical/verify-st3215-artifacts.mjs` to check existing artifact/source hashes without changing files. For fresh exports (overwrites working STLs/report), run node mechanical/check-st3215-leg.mjs for closed connected printable meshes,
print-bed bounds,proper placement rotations,clamp bore access and independently calculated70/85 mm geometry.
Recorded case clearance uses conservative rectangular envelopes at three sampled poses;
real wheel faces,connectors,cables,screw heads and rear support require dry fit. Sample checks do not release a swept or loaded range.

Manufacturer sources and immutable downloaded PDF/DXF/STEP are under
mechanical/reference/st3215; URLs recorded in decisions/st3215-3s-architecture.md.
