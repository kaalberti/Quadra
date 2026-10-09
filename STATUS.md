# Project status

Last updated: 2026-10-09

## Current milestone
Stage4 — single-leg mechanical prototype.
Integrated three-DOF build checkpoint includes J1 abduction plus J2/J3 pitch.
Physical assembly, fit and powered operation remain untested.

## Current design
- Build assembly: manufacturing/cad/prototype-integrated-bench-pack-assembly.scad.
- Build/print guides: manufacturing/docs/assembly.md and printing.md.
- Original integrated hip, mirrored pitch forks and mirrored knee saddle.
- Three positional hobby servos with supplied horns and three624 bearings.
- Retained70/85mm links; one existing bench adapter now mounts J1.
- Prototype pitch datum [85,-18,0]mm; nominal foot plane32mm outward.
- DESIGN_PARAMETERS.md records current values. The old25mm-offset skeleton is
  retained as reference and does not describe this physical prototype.

## Validation and limits
The integrated hip passes closed/connected/bed and30 interface-path checks.
Its solid PETG CAD mass is73.6g; actual slicing and measured mass supersede it.
The first support-rib clash was corrected with relief pockets.
Three sampled integrated-leg poses have no modeled hip/fixed-case intersections.
Carrier mating-face contact is permitted; full swept ranges and actual cables,
fasteners, horns, board anchoring and servo limits remain unverified.
Unpowered geometric trials: J1 -25..30deg, J2 20..55deg, J3 60..90deg; stop if binding.
At2kg/three support legs, J1 neutral screen0.329Nm vs0.922Nm published stall;
+15deg0.525Nm and+30deg0.694Nm. Stall is not sustained torque or powered approval.

## Prototype manufacturing checkpoint
MFG-003 / integrated-bench-1 is under manufacturing/.
15 unique assembly STLs/23 pieces, five coupons, editable CAD, buying BOM,
print/support/assembly instructions and preview:53 verified self-contained files.
All23 printed poses/three case poses are proper; source-bound sampled evidence,
closed connected assembly meshes, hashes, imports/dependencies and quantities pass.
Assembly rendered from the pack and visually inspected. Physical fit is untested.
Bench-3 is archived intact at ARCHIVE/MFG-002-three-dof-bench-3/; all53 file
bytes including its manifest are verified unchanged. Earlier packs stay archived.
Run docs/check-manufacturing-pack.ps1 for the active checkpoint.

## Purchases and immediate next objective
Maintained buying BOM: docs/purchasing-bom.md; active roles: integrated-bench-hardware.json.
Integrated prototype needs3 servos/3 bearings,27 M3 bolts/nuts and54 washers
including one12mm backing washer. Bench-only anchors/standoffs are separate.
MG996R is assumed for all weight-bearing joints; variant/prices remain provisional.
No servos ordered; test one before12. MG90S is too weak for current leg loads.
Next: print the side-on coupon, check remaining fit coupons and one actual
servo/horn/bearing, then assemble
one leg unpowered. Do not infer fit or hardware ownership from CAD.
The fit record/evaluator in mechanical/prototype-fit-record.json and
docs/prototype-fit-check.md is ready; six evaluator tests pass and the real
record remains NOT_MEASURED. Bench-control preparation can proceed independently.

## Open issues
- Actual servo/horn/bearing/cable fit and measured printed mass.
- Loaded joint ranges, servo current/duty and power supply capacity.
- Final four-leg chassis attachment/symmetry and servo-qualified complete operating mass.
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
Offline IK returns explicit branches/errors/singular flags;36 trial-envelope
round trips and boundary tests pass. Candidates are FK-checked, without projection.
One-leg planning atomically checks calibration, IK branch, angle and1450..1550us
limits. Failure leaves output unchanged; partial-profile/explicit-branch tests pass.
No powered IK or gait commands are enabled; physical profiles remain unset.
Board-only timing diagnostic is compiled/tested: explicit disarmed command,
channel15-to-GPIO7 loopback at3.3V,50ms waits, per-sample timing screens and
all-off/OE-high cleanup. Wiring/procedure: docs/board-pwm-timing-test.md.
No diagnostic has been run on hardware; no timing/voltage result is inferred.
Current integrated four-leg plan supersedes the117-piece bench-kit replication.
Its21 unique STLs/93 pieces and unmeasured mass record are described below.
Integrated hip/carrier: both handed meshes pass closed/connected/bed checks;
30 interface rays, three sampled leg clearances and source/placement checks pass.
Experimental bench leg has23 prints; cumulative robot estimate2.178kg remains
above the preferred2kg target. Conditional BOM is updated; print/fit/load tests remain NOT_PERFORMED.
Source/viewer: mechanical/prototype-integrated-hip.scad and prototype-integrated-hip-assembly.scad.
Integrated four-leg plan:21 unique STLs/93 pieces;12 new placements agree with
source within0.000709mm and all60 nominal chassis pairs pass. Variant mass
record remains NOT_MEASURED; screen2.178kg exceeds the preferred2kg target;qualified maximum remains TBD.
Viewer: mechanical/prototype-integrated-four-leg-assembly.scad.
Physical next: side-on coupon/fit and unpowered integrated-leg assembly remain pending.
Offline deck option: prototype-electronics-deck.scad adds eight strap slots while
retaining16 chassis fixings;169 mesh rays and minimum6.75mm ligament pass.
Guide:docs/electronics-deck.md; four optional ties, actual board mounts unverified.
Provisional12-servo channel/pin plan passes:channels0..11,three AHCT125N buffers.
Guide:electronics/four-leg-harness.md.30A capacity screen is provisional;
robot battery/regulator/protection stay TBD. Bench firmware remains one-channel.
Power shortlist:electronics/robot-power-shortlist.md; no regulator selected.
25A candidate misses30A screen; split10A option costsNZ$260/out of stock.
Keep common5.2V rail provisionally; measure actual demand before supply purchase.
Perfboard buffer layout:electronics/buffer-perfboard.md;162 unique pads and
12 complete signal paths pass. Actual body/board/soldering clearance untested.
DigiKey perfboard BOM:electronics/digikey-perfboard-bom.md; NZ$32.82 ex GST/shipping. Prototype perfboard100 x80mm; final SMT deferred; all fit untested.
Completed milestones are pushed to origin/main with user approval. No supplier contact.

Optional voltage input:electronics/voltage-perfboard.md;150k/10k,100nF,GPIO8.
Overlay172-pad/tolerance/power checks, host regressions and embedded build pass.
Explicit disarmed16-sample diagnostic keeps outputs disabled; no flash or readings.
Sense positive must disconnect before ESP32 power; calibration/cutoff remain unset.

Preferred working mount:docs/electronics-sleds.md;three single-level printed
frames,no added M3 hardware.472 mesh checks and nominal board clearance pass.
Solid PETG24.5g vs79.8g stacked fallback;actual board/strap/print fit pending.
Not adopted in robot mass/manifest;preferred2kg target and MFG-003 remain;heavier mass requires servo qualification.

Mass policy:2kg preferred,heavier permitted within demonstrated servo/power duty.
No qualified maximum or measured loads. Eight policy tests pass;CAD mass totals unchanged.
Guide:docs/servo-qualified-mass.md;no stall-derived mass approval or servo upgrade.
