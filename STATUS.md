# Project status

Last updated: 2026-10-09

## Current milestone
Stage4 — single-leg mechanical prototype.
Supported three-DOF bench-leg CAD now includes J1 abduction plus J2/J3 pitch.
Physical assembly, fit and powered operation remain untested.

## Current design
- Physical print assembly: mechanical/prototype-rigid-bench-assembly.scad.
- Build guide: docs/three-dof-prototype-build.md.
- Bench carrier/saddle use their mirrored STLs; source: prototype-handed-parts.scad.
- Three positional hobby servos with supplied horns and three624 bearings.
- Retained70/85mm links; one existing bench adapter now mounts J1.
- Prototype pitch datum [85,-18,0]mm; nominal foot plane32mm outward.
- The generous85mm forward offset is a bench prototype, not a final chassis layout.
- DESIGN_PARAMETERS.md records current values. The old25mm-offset skeleton is
  retained as reference and does not describe this physical prototype.

## Validation and limits
The carrier compiles as a simple solid and passes closed/connected/bed checks.
Its solid PETG mass estimate is47.2g; actual slicing and measured mass supersede it.
The first support-rib clash was corrected with relief pockets.
Six sampled checks have no solid intersections: J1 fixed-case probes -25/0/+30deg
and carrier/J2 probes20/44.0486/55deg, with remaining joints at nominal angles.
Carrier mating-face contact is permitted; full swept ranges and actual cables,
fasteners, horns, board anchoring and servo limits remain unverified.
Existing pitch-leg checks pass. Suggested unpowered geometric trial envelope:
J1 -25..30deg, J2 20..55deg, J3 60..90deg; reduce travel if anything binds.
At2kg/three support legs, J1 neutral screen0.329Nm vs0.922Nm published stall;
+15deg0.525Nm and+30deg0.694Nm. Stall is not sustained torque or powered approval.

## Prototype manufacturing checkpoint
Corrected MFG-002 / three-dof-bench-3 is under manufacturing/.
Adapter rib clearance, fixing/pivot access and closed connected print checks pass;
the old bench-1 adapter had a CAD clash and is archived. Physical fit is untested.
The kit now selects mirrored carrier/saddle prints and proper printed-part poses.
Self-contained assembly: manufacturing/cad/prototype-rigid-bench-pack-assembly.scad.
18 unique assembly STLs/29 pieces, four coupons, CAD snapshot, BOM, assembly
instructions/image, print list, layout, validation and hashes:53 verified files.
The prior two-DOF pack is archived intact at ARCHIVE/MFG-001-two-dof-pack/.
The prior bench-1 checkpoint is intact at ARCHIVE/MFG-002-three-dof-bench-1/.
The prior bench-2 checkpoint is intact at ARCHIVE/MFG-002-three-dof-bench-2/.
Source and validation tooling remain under mechanical/ and docs/.
Manufacturing is updated for this build checkpoint, not during every design edit.

## Purchases and immediate next objective
Maintained buying BOM: docs/purchasing-bom.md; role data: mechanical/three-dof-hardware.json.
One full prototype needs3 servos/3 bearings,35 M3 bolts/nuts and70 washers
including one12mm backing washer. Bench-only anchors/standoffs are separate.
MG996R is assumed for all weight-bearing joints; variant/prices remain provisional.
No servos ordered; test one before12. MG90S is too weak for current leg loads.
Next: print four coupons, verify one actual servo/horn/bearing, then assemble
one leg unpowered. Do not infer fit or hardware ownership from CAD.
The fit record/evaluator in mechanical/prototype-fit-record.json and
docs/prototype-fit-check.md is ready; six evaluator tests pass and the real
record remains NOT_MEASURED. Bench-control preparation can proceed independently.

## Open issues
- Actual servo/horn/bearing/cable fit and measured printed mass.
- Loaded joint ranges, servo current/duty and power supply capacity.
- Final four-leg chassis attachment/symmetry and2kg complete mass budget.
Bench electronics preparation is underway; robot power, chassis and locomotion remain deferred.
The proposed isolated servo rail is5.2V, with a7.5A supply-capacity target for
three servos and an external rated distribution/cutoff. Wire-only drop screen
is0.189V. Available supply is adjustable60V/5A (user reported): set near5.2V
for MG996R, never60V. Its5A rating is below the7.5A three-servo planning target;
reuse it for staged individual tests. Actual voltage/current remain unmeasured.
Wiring: electronics/bench-wiring.md; no powered test is claimed.
Individual-servo firmware is compiled for the owned ESP32-S3 N16R8 configuration.
Twelve host C++ scenarios pass for disabled startup, single-channel arming,
1450..1550us commands, timeout, bus/configuration faults and explicit recovery.
Source/commands: firmware/README.md. No flashing, calibration or gait code.
The supervised bench console has12 fake-transport tests: explicit arm,
automatic keepalive, disarm on protocol failure and no automatic recovery.
Use firmware/console.ps1 with a verified port only after hardware setup.
The electrical commissioning record/checker is ready under electronics/;
seven tests pass and the real record remains NOT_MEASURED. Procedure:
docs/bench-commissioning.md. Physical results gate powered hardware progression;
offline development may continue with explicit provisional assumptions.

## Deferred physical validation and ongoing development
Available: Creality K2 Pro access,60V/5A supply, ESP32-S3 N16R8 dev board,
Adafruit PCA9685, multimeter and basic load cells. Board header/revision unverified.
PHYSICAL_TESTS.md lists fit, wiring, calibration and load tests to do later.
User authorizes provisional development before parts selection and later rework.
Offline calibration/limit mapping supports both directions and rejects unmeasured
profiles, extrapolation and invalid data. Physical profiles remain unset;
the bench controller still exposes only its narrow pulse commands.
Offline forward kinematics agrees with current CAD transforms at five poses
within0.001mm. Nominal reference [85,32,-120]mm; pad centre [85,33,-120]mm.
The1mm distinction is within the existing pad, not a mechanical geometry change.
Special-pose/invariant tests and N16R8 build pass; manufacturing remains unchanged.
Offline inverse solving now returns explicit branches/errors and singular flags.
Thirty-six trial-envelope round trips plus reach-boundary/branch tests pass.
Candidates are checked against FK; targets are not projected into the workspace.
Offline one-leg planning now prepares all three pulses atomically only after
calibration, IK branch, angle and1450..1550us output checks. Failure leaves
output unchanged; complete/partial-profile and explicit-branch tests pass.
No powered IK or gait commands are enabled; physical profiles remain unset.
Board-only timing diagnostic is compiled/tested: explicit disarmed command,
channel15-to-GPIO7 loopback at3.3V,50ms waits, per-sample timing screens and
all-off/OE-high cleanup. Wiring/procedure: docs/board-pwm-timing-test.md.
No diagnostic has been run on hardware; no timing/voltage result is inferred.
Four-leg placement study: mechanical/prototype-four-leg-study.scad and preview.
Nominal reference footprint320 x174mm is symmetric; case/deck and inter-leg
case intersections are empty. Raised deck and board blocks are placeholders;
complete nominal printed-leg/deck intersection is also empty (CGAL).
Working chassis mount/deck CAD and STLs are available; mount print orientation
now uses a proper rotation for the original hand. Two mounts per hand;
16 added M3 x16 deck fixings. Carrier and saddle each have one new mirrored STL.
Mount ribs have clearance pockets; closed connected/bed/hole checks pass.
Corrected full nominal mount/leg intersection is empty, excluding intended contact.
Working assembly: mechanical/prototype-four-leg-working-assembly.scad, with
22 unique STLs/117 pieces and12 rigid servo envelopes. Every printed-piece pose
is a proper rotation and matches intended meshes at0.001mm coordinate resolution.
Front-left/rear-right use mirrored carrier/saddle; other diagonal uses originals.
Closed connected/bed checks pass for the new mirrors; actual servo ears/leads unknown.
Independent fresh source/placed exports agree within0.001005mm (STL rounding).
Rear local pitch directions differ from global forward; no powered mapping added.
Details/checks: docs/four-leg-placement-study.md and mechanical/check-four-leg-study.mjs.
Guide: docs/prototype-chassis-attachment.md; assembly: mechanical/prototype-chassis-assembly.scad.
Guide/counts: docs/four-leg-working-assembly.md and mechanical/four-leg-working-print-manifest.json.
Working mass screen: approximately2.360kg at an assumed65% material fraction,
including660g servos,484g estimated fasteners,40g reference bearings and330g
other allowances. Actual complete mass remains NOT_MEASURED;2kg limit unchanged.
Only486g remains for all prints under those assumptions (37.4% of solid CAD
mass). Current bench-kit replication is not a demonstrated2kg robot design.
Record/report: mechanical/robot-mass-inputs.json and docs/working-robot-mass.md.
MEC-161 fork prototype: four handed STLs pass closed/connected/bed checks and
retained-interface mesh rays. Six sampled local pitch case/support checks clear.
Local assembly viewer uses proper print rotations; preview visually inspected.
Conditional BOM removes16 long bolts and16 printed pieces, saving an estimated
143g; robot screen still2.217kg. Physical fit/strength remain untested.
Next: integrate forks into the handed3-DOF assembly and check J1/carrier clearance.
Details: docs/tasks/MEC-161.md. Supported bench manufacturing kit unchanged.
Completed units are committed and pushed to origin/main following explicit
user approval on2026-10-09. No supplier contact.
Detailed ten-step results are in docs/tasks/MEC-144-153.md.
