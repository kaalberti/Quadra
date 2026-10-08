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
- The generous85mm forward offset is a bench prototype, not a final chassis layout.
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
Offline IK returns explicit branches/errors/singular flags;36 trial-envelope
round trips and boundary tests pass. Candidates are FK-checked, without projection.
One-leg planning atomically checks calibration, IK branch, angle and1450..1550us
limits. Failure leaves output unchanged; partial-profile/explicit-branch tests pass.
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
Reference assembly: mechanical/prototype-four-leg-working-assembly.scad, with
22 unique STLs/117 pieces and12 rigid servo envelopes. Every printed-piece pose
is a proper rotation and matches intended meshes at0.001mm coordinate resolution.
Front-left/rear-right use mirrored carrier/saddle; other diagonal uses originals.
Closed connected/bed checks pass for the new mirrors; actual servo ears/leads unknown.
Independent fresh source/placed exports agree within0.001005mm (STL rounding).
Guide: docs/prototype-chassis-attachment.md; assembly: mechanical/prototype-chassis-assembly.scad.
Guide/counts: docs/four-leg-working-assembly.md and mechanical/four-leg-working-print-manifest.json.
Reference mass screen: approximately2.360kg at an assumed65% material fraction,
including660g servos,484g estimated fasteners,40g reference bearings and330g
other allowances. Actual complete mass remains NOT_MEASURED;2kg limit unchanged.
Only486g remains for all prints under those assumptions (37.4% of solid CAD
mass). Current bench-kit replication is not a demonstrated2kg robot design.
MEC-161 fork prototype: four handed STLs pass closed/connected/bed checks and
retained-interface mesh rays. Six sampled local pitch case/support checks clear.
Fresh source/placed exports agree within0.001005mm; five sampled J1/carrier
intersections are empty. No fork geometry/BOM correction was needed.
Side-on fork fit coupon: mechanical/prototype-fork-fit-coupon.stl,36 x78.2 x32mm.
Closed/connected/bed and27 interface ray checks pass; print/fit NOT_PERFORMED.
Procedure: docs/fork-fit-coupon.md. No new hardware purchase or mass/BOM change.
Offline calibration export/angle preview and foot-target CLI are tested; physical
profiles stay unset. Guides: docs/measured-calibration-profiles.md and offline-leg-planner.md.
Host console supports explicit disarmed timing/JSONL capture; nine fake-transport
tests and full host regressions pass. Guide: docs/board-pwm-timing-test.md.
No flash, physical capture or motion activation; voltage acknowledgements are not readings.
Integrated hip/carrier: both handed meshes pass closed/connected/bed checks;
30 interface rays, three sampled leg clearances and source/placement checks pass.
Experimental bench leg has23 prints; cumulative robot estimate2.178kg remains
above2kg. Conditional BOM is updated; print/fit/load tests remain NOT_PERFORMED.
Source/viewer: mechanical/prototype-integrated-hip.scad and prototype-integrated-hip-assembly.scad.
Integrated four-leg plan:21 unique STLs/93 pieces;12 new placements agree with
source within0.000709mm and all60 nominal chassis pairs pass. Variant mass
record remains NOT_MEASURED; screen2.178kg exceeds the unchanged2kg limit.
Viewer: mechanical/prototype-integrated-four-leg-assembly.scad.
Physical next: side-on coupon/fit and unpowered integrated-leg assembly remain pending.
Offline deck option: prototype-electronics-deck.scad adds eight strap slots while
retaining16 chassis fixings;169 mesh rays and minimum6.75mm ligament pass.
Guide:docs/electronics-deck.md; four optional ties, actual board mounts unverified.
Provisional12-servo channel/pin plan passes:channels0..11,three AHCT125N buffers.
Guide:electronics/four-leg-harness.md.30A capacity screen is provisional;
robot battery/regulator/protection stay TBD. Bench firmware remains one-channel.
Next offline task:commodity robot-power feasibility/cost shortlist.
Completed milestones are pushed to origin/main with user approval. No supplier contact.
