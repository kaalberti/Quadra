# Project status

Last updated: 2026-10-09

## Current milestone
Stage4 — single-leg mechanical prototype.
Supported three-DOF bench-leg CAD now includes J1 abduction plus J2/J3 pitch.
Physical assembly, fit and powered operation remain untested.

## Current design
- Editable assembly: mechanical/prototype-three-dof-leg.scad.
- Build guide: docs/three-dof-prototype-build.md.
- New carrier: mechanical/prototype-j1-carrier.scad and STL.
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
MFG-002 / three-dof-bench-1 is under manufacturing/.
18 unique assembly STLs/29 pieces, four coupons, CAD snapshot, BOM, assembly
instructions/image, print list, layout, validation and hashes:54 verified files.
The prior two-DOF pack is archived intact at ARCHIVE/MFG-001-two-dof-pack/.
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
Next: offline inverse position solving with explicit unreachable/ambiguous targets.
No powered IK or gait commands are enabled.
Completed units are committed and pushed to origin/main following explicit
user approval on2026-10-09. No supplier contact.
Detailed ten-step results are in docs/tasks/MEC-144-153.md.
