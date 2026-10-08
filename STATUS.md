# Project status

Last updated: 2026-10-08

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
Servo model and delivered prices remain provisional; test one before buying12.
Next: print four coupons, verify one actual servo/horn/bearing, then assemble
one leg unpowered. Do not infer fit or hardware ownership from CAD.
The fit record/evaluator in mechanical/prototype-fit-record.json and
docs/prototype-fit-check.md is ready; six evaluator tests pass and the real
record remains NOT_MEASURED. Bench-control preparation can proceed independently.

## Open issues
- Actual servo/horn/bearing/cable fit and measured printed mass.
- Loaded joint ranges, servo current/duty and power supply capacity.
- Final four-leg chassis attachment/symmetry and2kg complete mass budget.
No chassis, electronics, firmware or locomotion stage has been started.
Detailed ten-step results are in docs/tasks/MEC-144-153.md.
