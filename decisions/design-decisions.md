# Design decisions

## MFG-001 — Manufacturing release scope, 2026-10-08

Adopt manufacturing/ as the current release-output location, following the new
AGENTS.md rules. Package the existing pitch-leg-1 mechanical design without
changing geometry: 16 assembly STLs/20 pieces and four fit coupons, current
hardware BOM, self-contained assembly instructions, STL-derived dimensions,
assembly image and editable transitive SCAD source snapshot.
Fresh exports and independent mesh/package checks verify consistency. This is
a release for printing and unpowered fit assessment, not a complete robot or
powered release. Physical fit remains untested. STEP and electrical/firmware
outputs are absent because those designs/workflows have not been released.
Future manufacturing changes must update affected outputs and manifest;
obsolete releases move to ARCHIVE rather than remain in manufacturing/.
No new dependency, purchase, architecture change or engineering stage advance.

## ARCH-001 — Requirements and leg topology, 2026-10-07

Status: adopted as an architecture baseline; physical feasibility unvalidated.

Decision: use four serial three-DOF legs, each ordered hip abduction/adduction,
hip pitch, knee pitch, attached to a common chassis. Initially assume one
servo per joint and a passive foot contact, for twelve actuators total.

Reason: this topology directly represents the user's requested motions and
provides a bounded starting point for a reference-leg kinematic model.

Preserve the user's approximately 180 x 110 mm body, total operating mass
below 1.2 kg, FDM construction, provisional 70/85 mm link lengths, and
MG90S-sized metal-gear servo candidate. None of these provisional dimensions
or actuator capabilities has been validated. Existing ESP32-S3 and PCA9685
entries remain deferred assumptions only.

Downstream implications: the reference-leg task must define axis directions,
origins, and mirror conventions. Later pose/workspace and torque tasks must
test this baseline before detailed mechanical design. Actuator changes may
require revisiting packaging, offsets, and mass allocation.

Source: user brief, AGENTS.md, and initial STATUS.md. PROJECT.md records the
complete baseline and distinguishes requirements from assumptions. Earlier
conversational geometry/torque exploration is not an approved design result.

## KIN-001 - Reference-leg frames and axes, 2026-10-07

Status: adopted mathematical convention; eight offline geometry checks pass.

Decision: use right-handed body and fixed leg-root frames with +x forward,
+y left, and +z up. Define symmetric roots as (f*a, s*b, h), with front/rear
sign f and left/right sign s. Positive abduction is outward, hip pitch is
forward from vertical-down, and knee flexion bends the lower link backward
relative to the upper link. Zero angles mean a straight downward reference
leg, not a selected standing pose.

The abduction signed axis is s*x. Hip pitch is about the abducted -y axis;
knee flexion is about the abducted +y axis. The J1-to-J2 offset is (u,s*d,w)
before abduction. All dimensions remain parameters; the subsequent ideal
links have no additional lateral offset. Axis reference centres and signed
directions are defined fully in docs/leg-frames.md.

Left/right skeletons are reflections, but their coordinate frames remain
right-handed. Rear legs translate the front-leg geometry rearward and use
the same joint conventions; they are not fore/aft-reflected mechanisms.

Reason: consistent geometric angles across all legs allow shared equations
and avoid left-handed right-leg frames. Explicit offset parameters preserve
packaging freedom without hiding axis-location assumptions.

Validation: mechanical/check_leg_frames.py checks handedness, zero geometry,
motion signs, axis/link invariants, left/right reflection, front/rear
translation, independent scalar equations, and finite-difference joint
motion against axis cross lever-arm geometry. Eight tests pass, using 43
deterministic angle samples per leg where sampling applies. Fixture values
are verification inputs, not approved dimensions or ranges.

Downstream implications: the numeric skeleton must use these signs and
offset definitions. Additional lateral link offsets or fore/aft-reflected
knee arrangements would require revising this contract and its checks.
Servo command polarity remains a later calibration issue. No torque,
workspace, packaging clearance, or physical feasibility is established here.

## KIN-002 - Candidate numeric skeleton, 2026-10-07

Status: adopted candidate for further kinematic analysis; physical feasibility
unverified. Seven candidate/drawing checks and all eight KIN-001 checks pass.

Decision: a = 75, b = 55, h = 0, u = 0, d = 25, w = 0, Lu = 70, Ll = 85 mm.
Preserve the 180 x 110 mm chassis planform. Place the body datum on the common
J1 plane; chassis top, bottom, and thickness remain undefined. This instantiates
KIN-001's parameters without changing its frames, angles, or leg mapping.

Reason: 150 mm longitudinal root spacing leaves a 15 mm nominal end inset;
placing roots at the chassis side boundaries makes the initial layout easy
to reference. A 25 mm outward pitch-centre offset is a compact starting
allocation, not a measured servo packaging result. Zero longitudinal and
vertical hip offsets simplify the initial skeleton. The link centre lengths
retain the user's 70/85 mm targets.

Derived zero-reference geometry: J1 roots form a 150 x 110 mm rectangle;
pitch-leg planes are 160 mm apart; straight hip-to-foot distance is 155 mm.
The zero-angle drawing is singular in the pitch plane and is not a stance.
With u = w = 0, J1/J2 infinite axes intersect: the 25 mm dimension locates
reference centres along J2 and is not an axis-to-axis minimum distance.

Validation: mechanical/check_leg_skeleton.py compares JSON coordinates with
the KIN-001 matrix chain; checks body insets, outboard distances, centre
lengths, reflection and rear translation; and checks SVG markers, link
projections, dimension-line lengths/labels, and documented coordinates.
The existing frame checker also passes unchanged. These are mathematical
and document checks, not physical fit, load, or printability validation.

Downstream implications: use this candidate for a nominal-standing-pose
task. Later actuator packaging or torque results may require changing hip
offsets, link lengths, or root locations. Any such revision must update the
JSON, drawing, documentation, checks, and this decision record. No servo
adequacy, joint limits, workspace, or detailed mechanical design is approved.

## KIN-003 - Nominal standing-pose candidate, 2026-10-07

Status: adopted geometric pose candidate; physical supportability unverified.
Eight new pose checks and all fifteen previous geometry checks pass.

Decision: keep the KIN-002 skeleton unchanged and place the level body datum
120 mm above ideal ground, with zero abduction and feet directly below H.
Every leg uses q1 = 0, q2 = 44.048625674, q3 = 78.978550364 degrees under
KIN-001. Use the forward-knee branch for both front and rear legs.

Reason: this gives a simple symmetric four-foot pose with bent knees and
no fore/aft foot displacement from the hip-pitch centres. The 120 mm height
is an initial moderate crouch, not an optimized clearance, torque, or
stability result. It avoids the straight-reference pitch singularity.

Derived geometry: feet at (+/-75,+/-80,-120) mm form a 150 x 160 mm contact
rectangle. Relative to H, K is (48.668802572,0,-50.3125) mm. Knees are
69.6875 mm above ideal ground. The front knee centres extend 33.668803 mm
beyond the nominal body front. Body thickness and physical clearances are
still undefined; the 120 mm dimension measures the hip datum, not the underside.

Validation: independent triangle-intersection geometry agrees with the
KIN-001 forward chain; checked geometric angles, link lengths, all-leg mapping,
ground-frame transformation, foot coplanarity, pitch nonsingularity, SVG
geometry/dimensions, and documented coordinates. The combined suite passes
23 tests. SVG was checked as XML/numeric geometry, not raster-rendered.

Downstream implications: candidate angle ranges should include this pose;
later workspace and torque tasks should use it as a reference. Servo mounting,
available travel, interference, holding torque, and COM/stability require
separate validation. Equal foot loads are not assumed or established.
Pose data and derivation are in mechanical/standing-pose.json and
docs/standing-pose.md; the KIN-002 zero-reference drawing is retained.

## KIN-004 - Candidate geometric joint-angle ranges, 2026-10-07

Status: adopted desired ranges for subsequent geometric analysis; measured
hardware limits and simultaneous physical feasibility remain unverified.

Decision: use q1 = [-25,30], q2 = [-40,85], q3 = [20,130] degrees for every
leg under KIN-001. Keep KIN-002 dimensions and KIN-003 nominal angles unchanged.
Closed endpoints define an analysis input only, not operational limits.

Reason: provide moderate inward/outward articulation, allow backward and
larger forward upper-link rotation around the nominal pose, and retain
positive knee flexion away from straight/folded pitch-chain references.
The bounds are engineering starting assumptions, not optimized gait or
clearance results. Spans of 55/125/110 degrees are desired joint travel,
not attributed MG90S specifications.

Nominal reserves to lower/upper boundaries are 25/30 degrees for q1,
84.048626/40.951374 for q2, and 58.978550/51.021450 for q3. These reserves
are arithmetic differences, not established operating safety margins.

Mapping: coordinate rotations are (s*q1,-q2,q3), giving +x abduction intervals
[-25,30] on left legs and [-30,25] on right legs. Local +y hip rotation is
[-85,40] and relative knee rotation is [20,130] on all legs. Rear legs retain
front-leg conventions. These coordinate rotations do not specify servo commands.

Validation: six new checks pass for finite ordered bounds, nominal containment,
spans/reserves, all-leg signed endpoint mapping, frame reflection at eight
angle-box corners plus nominal pose, excluded straight/folded knee references,
and documentation agreement. The complete suite passes 29 tests. No foot
positions or workspace were calculated in this task.

Downstream implications: workspace analysis should use these ranges as a
candidate geometric domain, not assume every angle combination is physically
feasible. Later actuator travel, coupled collision, ground-contact, and load
checks may require narrowing or revising them. No full three-axis singularity,
servo adequacy, stability, or mechanical stop approval follows from this task.
Sources: docs/joint-ranges.md and mechanical/joint-ranges.json.

## KIN-005 - Ideal geometric foot workspace, 2026-10-07

Status: ideal workspace characterized; usable physical workspace unverified.
Seven new workspace checks and the full 36-test geometry suite pass.

Decision: preserve the KIN-002 skeleton, KIN-003 pose, and KIN-004 angle box.
Record continuous marginal bounds relative to the FL J1 root O as
x = [-129.995,146.770], y = [-41.862,97.984], z = [-154.701,38.555] mm.
The nominal root-relative point remains (0,25,-120) mm. These are enclosing
bounds of unfiltered mathematical reach, not an approved Cartesian region.

Method: enumerate planar pitch extrema at corners, edge stationary points,
and interior stationary points; then use affine dependence on planar Z to
reduce y/z extrema to abduction endpoints and stationary angles. Store
attaining joint angles for every coordinate bound. Visualize 103,936 samples
from an endpoint-inclusive 2-degree grid in 2 mm projected occupancy cells.
Distinguish sampled projections from slices and exact reachable boundaries.

Reason: sampled limits alone can miss true extrema; reporting witnesses and
the continuous method makes the approximate workspace independently checkable.
The enclosing box demonstrably includes unreachable points: the root lies
inside the box but outside the necessary radius shell [71.420077,154.700815] mm.

Validation: compare extrema witnesses and random all-leg samples with the
KIN-001 matrix chain, verify a 783,216-point 1-degree grid lies within bounds,
check the independent radius identity, reproduce JSON/SVG outputs, verify
source hashes, nominal/ground plot locations, and documentation agreement.
SVG geometry was checked as XML; no raster rendering/text-layout check was made.

Downstream implications: at nominal body height the unfiltered set includes
points below ground and above the hip plane. Body/link collision, actual
actuator travel, load capability, and stability still require separate checks.
The bounds must not become walking command limits. Proceed next to a bounded
nominal static joint-torque/initial-servo assessment before detailed parts.
Artifacts: docs/foot-workspace.md, mechanical/foot_workspace.py,
mechanical/foot-workspace.json, and mechanical/foot-workspace.svg.

## TOR-001 - Nominal static torque and MG90S assessment, 2026-10-07

Status: nominal contact-load assessment complete; MG90S direct drive is not
approved at the 1.2 kg design ceiling. No replacement or voltage selected.

Assumptions: unchanged KIN-003 pose, 1.2 kg ceiling, gravity 9.80665 m/s^2,
vertical upward foot reactions with per-leg weight shares 1/4, 1/3, and 1/2,
massless moving links, and ideal 1:1 drive. Equal three-foot sharing is only
a hypothetical case requiring its matching COM projection. A half-weight
share is a redistribution screen, not a stable two-leg gait claim.

Results: abduction magnitudes 0.073550/0.098067/0.147100 Nm and knee magnitudes
0.143183/0.190911/0.286367 Nm for those shares. Hip-pitch contact torque is
zero at this exact vertical-under-hip foot location; gravity on moving
components and nonvertical forces are not included.

Source comparison: Tower Pro Hong Kong's MG90S page lists 1.8 kgf.cm at 4.8 V
and 2.2 kgf.cm at 6.6 V; the Tower Pro branded sheet hosted by Electronilab
lists the latter at 6.0 V. Keep this discrepancy explicit and make no supply
choice. Use 0.1765197 Nm as the shared 4.8 V stall reference and 0.2157463 Nm
only as an optimistic published stall comparison. No supported continuous
holding rating was found in those sources. URLs are preserved in the report
and mechanical/static-torque-inputs.json, checked 2026-10-07.

Decision: do not approve the initial MG90S direct-drive baseline at the ceiling.
The half-weight knee case exceeds both stall figures; the equal-four-foot
case being below stall does not establish sustained holding capability.
This is a scoped screening conclusion, not proof about every possible mass
distribution or every servo of similar size. Missing moving-link gravity can
increase or reduce individual moments and must not be labelled uniformly
conservative. Do not invent favourable cancellation or continuous ratings.

Validation: seven new checks and the full 43-test suite pass. Checks cover
independent triangle lever arms, SI/kgf.cm conversion, all-leg signed moments,
finite-difference virtual work, example load equilibrium, source discrepancy,
comparison arithmetic, source freshness, and documented tables. A displayed
rounding discrepancy was corrected before the full suite passed.

Downstream implications: keep the skeleton, pose, and ranges unchanged as
analysis references; retain MG90S as historical packaging only. Resolve an
actuator performance-requirements brief next, including missing duty and
mass-distribution evidence. Do not begin detailed servo brackets or select
a replacement in this task. Dynamic/workspace-wide loads remain open.
Artifacts: docs/static-servo-torque.md, mechanical/static-torque-inputs.json,
mechanical/static_torque.py, and mechanical/static-torque.json.

## TOR-002 - Actuator performance-requirements brief, 2026-10-08

Status: requirements/evidence brief complete; actuator sizing approval open.

Decision: retain TOR-001's three nominal contact-load cases as benchmarks,
not complete continuous or peak requirements. Do not assign the half-weight
case a transient duration or infer continuous capability from stall torque.
Require explicit load uncertainty, duty, speed, thermal and terminal-voltage
evidence before performance approval. No arbitrary torque multiplier chosen.

Reason: moving mass can change both magnitude and sign, while sustainable
support and repeated motion depend on conditions absent from a stall rating.
Zero nominal hip-pitch contact torque does not imply zero actuator demand.

The brief defines nine traceable evidence requirements, mass accounting,
constant-ratio motoring torque/speed/travel relationships and their static
limitations, and staged approval gates. All open inputs have closure methods.
No actuator, transmission ratio, voltage, mass allocation, or geometry changed.

Downstream implications: build the component mass/COM accounting model next;
later candidate evaluation must revisit total mass and distal gravity with
actual placement. Thermal/duty and full operating loads remain open. Detailed
single-leg mechanical design is not released by this document-only task.
Artifact: docs/actuator-requirements.md. Validation is recorded in STATUS.md.

## TOR-003 - Component mass/COM accounting, 2026-10-08

Status: accounting model validated with synthetic fixtures; actual inventory
and gravity loads unresolved.

Decision: count distinct physical instances/groups once across the whole
robot. Assign gravity influence by rigid attachment: body affects no leg
joint, hip carrier q1, upper q1/q2, and lower q1/q2/q3. An actuator's driven
joint label does not select its body attachment. Local COMs use existing
right-handed frames, explicitly mirrored local y on symmetric right parts.

Reason: torque depends on what moves with each joint, while total mass must
also include body-fixed equipment. Adding distal gravity moments does not
add their weight to the contact-force mass a second time.

Unknown mass, COM or attachment withholds affected moments; incomplete
inventory coverage withholds all total gravity corrections and total mass.
The mass-target comparison is strictly below 1.2 kg. No actual mass,
placement, geometry, actuator, transmission or operating limit is selected.

Validation: eight new checks and all 51 mechanical tests pass, including
independent lever-arm and potential-energy-gradient tests on all four legs,
mass accounting, symmetry, invalid inputs and unknown propagation. Synthetic
test masses and offsets are not component estimates or design allocations.

Downstream implications: audit disjoint inventory coverage, split aggregates
by rigid attachment and collect evidence before entering real values. Contact
load sharing must be rechecked against actual COM before combining corrections
with TOR-001. Next collect a bounded candidate actuator evidence table; do
not release detailed mechanical design from this accounting result.
Artifacts: mechanical/mass-inventory.json, mechanical/mass_accounting.py,
mechanical/check_mass_accounting.py and docs/mass-accounting.md.

## TOR-004 - Candidate actuator evidence comparison, 2026-10-08

Status: bounded three-candidate comparison complete; no actuator selected.

Decision: record HS-5085MG, XL330-M288-T and XC330-M288-T as evidence examples,
not an approved shortlist. Their comparison-voltage stall figures exceed the
TOR-001 half-weight nominal knee contact benchmark; none has established
sustained support under project conditions. Preserve all geometry and the
unmeasured TOR-003 inventory.

Reason: mass, travel, interface and published torque can narrow questions,
but cannot replace complete loads and matching thermal/duty evidence. Hitec
default travel is short of the candidate hip span and its voltage limits
conflict across manufacturer sources. Bus candidates imply a later control
interface review; no electronics architecture change is made now.

Validation: primary sources opened and dated; independently checked torque
unit conversion, twelve-unit mass, strict residual mass and nominal ratios.
Published masses exclude unresolved installed hardware accounting and COMs.
No test data or sustained ratings invented; no hardware validation performed.

Downstream implications: define the nominal-standing duty/thermal test
requirements next, with proposed operating targets and unresolved manufacturer
limits separated. Do not release mechanical CAD or select an actuator from
this stall comparison. Artifact: ARCHIVE/2026-10-08-superseded-design/docs/actuator-candidates.md.

## TOR-005 - Provisional standing-duty test requirements, 2026-10-08

Status: test requirements complete; hardware execution not released.

Decision: use three separately cooled 600 s nominal-angle holds at 25 +/-2
degC ambient as a provisional finite standing screen. Target <=2-degree
joint-output tracking error and +/-5% applied nonzero torque tolerance,
including measurement uncertainty. Record fast channels at >=50 Hz and
temperatures at >=1 Hz, with explicit gap limits and independent protection.

Reason: a bounded indoor ten-minute scenario makes sustained-use evidence
questions concrete without claiming indefinite operation. Repeated cooled
starts assess repeatability, not a continuous thirty-minute session. All
numeric targets are engineering proposals; none is a manufacturer rating.

No load torque or protective temperature/current/voltage threshold is invented.
Those require specific evidence, calibrated fixture behavior and completed
load accounting before execution. Ambient limits do not become case/winding
limits. No actuator, geometry, supply or operating capability is approved.

Validation: reference/link and numeric consistency checks passed; reviewed
uncertainty rules, stop conditions and scoped pass/fail/inconclusive outcomes.
No hardware or thermal measurements performed.

Downstream implications: resolve candidate sensor-specific thermal/current
evidence next. Longer/warm-start operation, dynamics and whole-robot support
need separate validation even after a future scoped pass.
Artifact: docs/standing-duty-test.md.

## TOR-006 - Manufacturer protection evidence, 2026-10-08

Status: evidence matrix complete; test release and physical limits remain open.

Decision: distinguish control-table defaults and telemetry from sustained
current and sensor-specific thermal ratings. ROBOTIS default shutdown masks
differ (XL 0x35, XC 0x34); actual configuration must be verified. Do not adopt
register maxima or operating temperature ranges as physical test limits.

Reason: the reviewed primary documentation describes protection behavior but
does not establish the proposed installation's 600 s capability. TOR-005 now
explicitly requires manufacturer post-alarm recovery in addition to ordinary
cooled-start criteria; reviewed ROBOTIS guidance specifies at least 20 minutes
cooling after an overheating alarm. Reboot is not automatic permission to retry.

Validation: checked primary tables/explanations, mA conversions, bit masks and
local references. Six gaps identify outstanding evidence. No actual settings
read, hardware test run, manufacturer message sent or actuator selected.

Downstream: prepare local inquiry drafts to obtain missing evidence; fixture,
load and external protection dependencies also remain open. No geometry or
inventory changes. Artifact: ARCHIVE/2026-10-08-superseded-design/docs/actuator-protection-evidence.md.
## TOR-007 - Local manufacturer inquiry packet, 2026-10-08

Status: two local drafts complete and unsent; all evidence replies outstanding.

Decision: ask Hitec and ROBOTIS separately about TOR-006 G1–G5 using the
provisional TOR-005 duty. Identify unresolved voltage, mounting and total
loads explicitly. Include contact-only knee figures solely as context, not
as approved holding requirements. Preserve a model-specific reply record.

Reason: targeted questions can obtain missing physical limits without
substituting stall ratings or control settings. Drafting does not close gaps.

Validation: checked both five-question sets, torque and duty values, local
references, unanswered matrix and unsent status. No external messages or
new hardware decisions. Artifact: ARCHIVE/2026-10-08-superseded-design/docs/manufacturer-inquiries.md.

Downstream: manufacturer evidence still needs a separately authorized inquiry
or new documentation. Independently, the next bounded analytical task is
nominal distal mass/COM gravity sensitivity with no real mass assignment.

## TOR-008 - Nominal gravity sensitivity and evidence policy, 2026-10-08

Status: reference sensitivity analysis complete; actual masses/placements open.

User direction: base decisions on publicly available information; do not email
suppliers. Supersedes TOR-007 contact workflow. Unsent drafts remain historical;
missing public evidence remains explicit uncertainty, not a supplier dependency.

Decision: use per-kg signed nominal gravity coefficients and affine local COM
gradients at seven reference points. These are mathematical probes, not selected
mountings. Preserve geometry and unknown real inventory. Contact reactions are
held fixed, so coefficients are not total robot torque sensitivity to added mass.

Validation: four new checks and all 55 mechanical tests pass. Independent
triangle lever arms and analytic gradients verify signs/units; affine COM and
mass reconstruction agrees on all legs, and generated JSON reproduces.

Implication: prioritize evidence for attachment and horizontal COM lever arms.
Next develop a provisional mass allocation using public data and explicit
engineering targets/reserves. No actuator selection or CAD release follows.
Artifacts: docs/gravity-sensitivity.md, mechanical/gravity_sensitivity.py,
mechanical/gravity-sensitivity.json and mechanical/check_gravity_sensitivity.py.

## TOR-009 - Provisional whole-robot mass allocation, 2026-10-08

Status: top-down budget adopted for planning only; physical feasibility open.

Decision: allocate 360 g actuator assemblies, 240 g printed structure, 150 g
battery assembly, 90 g electronics/power, 60 g additional wiring and 100 g
shared hardware/feet. Total 1000 g, plus 150 g growth reserve = 1150 g;
retain 50 g gap below the strict 1200 g limit. Average assembly target 30 g.

Reason: make the competing mass demands explicit while leaving growth capacity.
All allocations/reserves are engineering targets, not sourced part masses or
validated estimates. Public candidate unit masses leave 8.1/12/7 g per unit
for assembly additions; no complete assembly has yet been shown to fit.

Validation: checked sums, strict limit, candidate residuals, overrun sensitivity,
local links and preservation of unknown inventory; all 55 mechanical tests pass.

Downstream: track reserve transfers explicitly and reconcile published accessory
scope. Do not assign budget masses to COMs or infer torque adequacy. Next assess
one bounded attachment hypothesis using public masses and explicit COM bounds.
No supplier email, actuator selection, geometry change or CAD release.
Artifacts: docs/mass-budget.md and mechanical/mass-budget.json.

## TOR-010 — Analytical attachment hypothesis, 2026-10-08
Use q1 body, q2 hip carrier, q3 upper link for analytical screening only.
Nominal axis-centred COM and +/-34/26/34 mm boxes are engineering assumptions.
No mounting release. q3 actuator gravity loads q1/q2, not q3. See
../ARCHIVE/2026-10-08-superseded-design/docs/actuator-attachment.md and ../mechanical/attachment-loads.json.

## TOR-011 — Equilibrium-consistent screening, 2026-10-08
Use disjoint 360 g installed assemblies + 160 g moving structure + 680 g body
remainder at the 1.2 kg calculation ceiling. Preserve strict operating target.
Contact shares follow rectangular support equilibrium, not a fixed 50% cap.
COM and gravity interval endpoints are independently combined conservative
bounds within explicit assumed boxes; not physical evidence. Downstream
packaging must check those boxes or recalculate. See docs/nominal-load-bounds.md.

## TOR-012 — Limited sampled stance screen, 2026-10-08
Screen only common x foot offset +/-10 mm, height110..130 mm, q1=0 with four
contacts. 1 mm grid; no continuous extrema or gait approval. Retain full desired
travel as packaging objective. Geometry unchanged. See docs/stance-envelope.md.

## TOR-013 — Conditional XC330 packaging candidate, 2026-10-08
Investigate common XC330-M288-T direct-drive cases at all three axes, comparing
at5 V. Strongest published stall margin of screened candidates, metal gears,
feedback, 23 g mass. Selection is for geometry investigation only; sustained
duty/7 g accessory allowance unproven. No architecture baseline dimension changes.
Downstream electronics must address TTL half-duplex; PCA9685 candidate is
incompatible as sole driver. See ARCHIVE/2026-10-08-superseded-design/docs/provisional-actuator.md.

## MEC-001 — Drawing-referenced coarse packaging, 2026-10-08
Retain25/70/85 mm spacing. Place q1 case inward along x, q2/q3 cases outboard
along y. Choose horn front plane as axial joint datum; public X330 reference
shows9.5 mm top-to-axis,23 mm case depth+3 mm horn,29 mm with rear idler.
Proposed rear support planes are conceptual; bearings and printed load paths
remain unselected. Manufacturer M2/depth constraints override M3 preference at
purchased actuator interfaces. Five-pose case separation is an investigation
pass only; full assembly and duty gates remain open. COM envelope coverage
checked; no real mass inventory or baseline geometry changes. No sixth task.
Artifacts: ARCHIVE/2026-10-08-superseded-design/docs/single-leg-packaging.md, ARCHIVE/2026-10-08-superseded-design/mechanical/packaging_screen.py,
ARCHIVE/2026-10-08-superseded-design/mechanical/packaging-screen.json, ARCHIVE/2026-10-08-superseded-design/mechanical/single-leg-packaging.svg.

## MEC-002 - XC330 datum contract, 2026-10-08
Retain output-front-plane datum and3+23+3 mm axial stack. Use manufacturer M2
tapping interfaces/max3 mm depth at the indicated pilots. Do not infer bearing
capacity from rear idler, or screw strength from penetration. Nominal pattern
clocking needs calibration later. No fabrication release. Artifacts:
ARCHIVE/2026-10-08-superseded-design/mechanical/xc330-interface.json, ARCHIVE/2026-10-08-superseded-design/docs/xc330-mounting-datums.md.

## MEC-003 - Knee connector keep-out, 2026-10-08
Reserve both complete case-side service corridors,20 mm outward plus2 mm
axial/vertical padding. These are assumptions pending actual pocket/harness fit.
Do not convert manual21 AWG mention into a crimp selection: cited JST terminal
lists30..22 AWG. Downstream mechanical envelopes must include reserved volumes.
Artifacts: ARCHIVE/2026-10-08-superseded-design/mechanical/knee-connector-keepout.json, ARCHIVE/2026-10-08-superseded-design/docs/knee-connector-clearance.md.

## MEC-004 - Knee free-body load contract, 2026-10-08
Size investigations from a7.110802 N radial resultant and0.00196133 Nm off-plane
moment in the declared static scenario. Keep sampled torque separate from force
cap, and motor stall from sustainable duty. Exclude upstream q3 mass from local
free body but retain it in whole-body contact equilibrium. Horn pilot strength
unknown. Artifacts: ARCHIVE/2026-10-08-superseded-design/mechanical/knee-loads.json, ARCHIVE/2026-10-08-superseded-design/docs/knee-joint-loads.md.

## MEC-005 - Independent knee bearing topology, 2026-10-08
Investigate separate coaxial radial supports47 mm apart at y=-9/+38 mm;
servo horn carries torque, not the intended ground radial-load path. Require
alignment/radial compliance before physical release. NSK623 geometry candidate
only; no seal/fit/shaft/retention chosen. No load-rating credit for servo idler.
Link centres unchanged. Downstream mass/COM and support housing need checking.
Artifacts: ARCHIVE/2026-10-08-superseded-design/mechanical/knee-support.json, ARCHIVE/2026-10-08-superseded-design/docs/knee-support-topology.md.

## MEC-006 - Parameterized knee-yoke envelope, 2026-10-08
Investigate two axially offset cheeks bridged50 mm from knee, preserving85 mm
foot reference. Case/port separation is continuous across desired20..130 degree
knee range within simplified geometry;0.60 mm minimum reserved gap after0.4 mm
assumed uncertainty. Lower-frame uniform-solid centroid fits the existing COM
box, not a real assembly mass claim. Source is a clearance envelope, without
bearing seats, shafts, fastener holes or proven radial-compliant torque coupling.
Do not fabricate this source or credit external bearings before alignment and
load path are designed. Next task is coupler geometry/access, not automatically
started. Artifacts: ARCHIVE/2026-10-08-superseded-design/mechanical/knee-yoke-parameters.json, knee_yoke.py,
knee-yoke-envelope.scad, knee-yoke-clearance.json, knee-yoke-layout.svg,
ARCHIVE/2026-10-08-superseded-design/docs/knee-yoke-clearance.md. No change to baseline joint centres or actual inventory.


## MEC-007 - Knee coupler feasibility result, 2026-10-08
Reject the declared three-layer Oldham probe within unchanged radius8/axial3 mm
MEC-006 reservation. Two1.2 mm hub webs+2.4 mm centre+two0.1 gaps require5 mm
nominal,4.3..5.7 mm with stated assumptions. Keys overlap grooves and are not
counted twice. Integration into front arm might be possible, but requires a new
bounded package revision rather than silently treating the torque disk as a
finished coupling. Existing kinematics and envelopes remain unchanged.

Independent +/-0.2 mm x/z part errors give relative offset norm0.565685 mm;
the tested strokes/swept disk barely fit on paper. Horn-edge screen and installed
driver access fail. M2 example depth passes without strength or screw selection.
Do not claim an Oldham topology eliminates shaft forces: friction/alignment are
unresolved and can change support reactions beyond ground/gravity-only MEC-005.
Public manufacturer topology used, not commercial ratings. Full81 tests pass.
Artifacts: ARCHIVE/2026-10-08-superseded-design/docs/knee-torque-coupler.md, ARCHIVE/2026-10-08-superseded-design/mechanical/knee-coupler-inputs.json,
knee_coupler.py, knee-coupler-feasibility.json, check_knee_coupler.py.
Downstream: revise/check local front-interface geometry, access, mass/COM and
clearance before any fabrication; no subsequent task started.

## MEC-008 - Active front-package revision B, 2026-10-08
Adopt local revision for investigation only to address MEC-007 stack/edge failures.
Input radius8->9.4; window3->6; front arm shifts-3 mm; front bearing-9->-13;
rear38 retained, span47->51. Preserve joint centres and links. Installed tool
access still requires front module removal; release mechanism unknown. Record
new proposal separately; historic results remain reproducible but are not current
support/clearance evidence. Recheck clearance/COM and51 mm reactions downstream.
Artifacts: ARCHIVE/2026-10-08-superseded-design/mechanical/knee-front-revision.json, ARCHIVE/2026-10-08-superseded-design/docs/knee-front-package.md.

## MEC-009 - Revision B local clearance
Retain revision B for investigation: continuous axial/radial witnesses pass local
case/port reservations with minimum0.2 mm assumed-adjusted margin. Input horn
contact and output hub/arm union are intentional. This does not approve actual
coupling face tolerances, bearing carrier, full-leg clearance or manufacture.
Historical MEC-006 geometry remains a superseded packaging comparison.

## MEC-010 - Revised loads and attachment accounting
Ground/gravity-only support reactions use current centres[-13,38] mm; historical
MEC-005 centres remain for comparison. Peaks5.337/1.851 N are conditional on the
inherited20 g distal scenario. Friction sensitivity is separate and not a material
rating. Actual moving hardware invalidates inheriting TOR-011's all-upper accessory
allocation as a finished assembly model. Retain actual inventory unknowns and
reconcile attachment-resolved masses before actual torque/support approval.
Printed coupling parts count as structure. Floating disk has no fixed rigid-link
COM. Envelope solid volumes are illustrative, not weighed/validated BOM values.

## MEC-011 - Removable front cartridge interface
Investigate a front outer-ring cartridge at the unchanged y=-13 bearing centre,
withdrawn7.5 mm toward negative y after accessible M3 flange bolts and positive
inner retainer release. Precision3 mm metal journal required; threaded M3 journal
forbidden. Nominal seat clearance is not a fit approval. Ring-only contact,
shaft-root attachment, fixed upper anchor and actual cover/retainer design remain
open. This contract reserves space without claiming a printable assembly.

## MEC-012 - Reject revision-B service stroke
A candidate removal sequence needs1.4 mm negative-y yoke motion to release assumed
0.8 mm output-key engagement with declared error/buffer. Revision B permits only
0.6 mm against the side-port reservation after allowance. Explicit point and SAT
show overlap at nominal pose. Do not claim removable front cartridge makes the
whole yoke serviceable, or reduce the uncertainty allowance to bypass this failure.
Correct rear spacing next, preserving the front package and kinematic skeleton.

## MEC-013 - Active service-spacing revision C, 2026-10-08
Revision B's rear removal stroke conflicts with reserved side-port space. Adopt
revision C for investigation: rear arm/hub shift+1 mm to y[33,36.5], bridge end
follows; rear bearing moves+3 mm to41, front-13 unchanged, span54 mm. The larger
bearing shift reserves a rear outer-ring cartridge wall with1.2 mm adjusted arm
clearance. All front coupling parameters, joint centres and link lengths remain.

Local operating and assumed key-release path clear continuously20..130 degrees;
minimum adjusted service margin0.2 mm. Updated conditional ground/gravity peaks
5.435/1.748 N and lower solid volume/COM are recorded separately. Historic B
reports reproduce and remain a comparison, not current service evidence.

Critical limitation: front nominal outer+inner endplay0.6 mm exceeds nominal
coupling face gap0.1 mm. No coupling axial compatibility or physical service
approval. Resolve controlled axial location and positive metal stub retention
before hardware operation; rear support must float, not duplicate front location.
Actual keys/retainers/shaft roots/fits/upper anchor/global fit/strength/duty and
attachment-resolved masses remain open. No printed structural journal threads.

## MEC-014 - Assembly axial acceptance, 2026-10-08
Reject nominal FDM dimensions as proof of operating clearance. Require measured
total sandwich clearance0.15..0.30 mm and full assembled hub travel<=0.05 mm,
with declared measurement uncertainties. Internal bearing play/root/seat/mount
motion must be included; no numeric bearing axial play is invented. Operating
movement0.05 remains a qualification assumption. Conditional C service stroke
includes full hub travel:1.45 mm, adjusted rear margin0.15. No physical approval.

## MEC-015 - Positive metal stub candidate, 2026-10-08
Separate inner-ring cap/shoulder capture from outer-ring seat/cover; no deliberate
cross-ring preload or shield clamping. Custom3 mm journal/5 mm root with7 mm
positive stop flange and transverse M2 capture investigated. Preserve C outer
package. Root socket alters real part material; no actual mass/strength approval.
Nominal capture clearance0.2 mm alone cannot establish0.05 assembled-travel target.
Positive retention, fit/endplay and strength are separate checks. Actual metal
machining, root location, outer cover/shims and bearing variant remain dependencies.

## MEC-016 - Measurement-based axial screen, 2026-10-08
Use a null actual worksheet and conservative measured intervals. No nominal or
synthetic values count as actual measurements. Full assembled travel includes
root, rings, bearing internal displacement and mount motion under documented
reversing bench load. Evaluation states distinguish missing/invalid/fail/geometric
pass, with physical approval always false. Operating allowance, key/contact geometry,
rear float, root/retainer strength and powered duty require separate qualification.

## MEC-017 - Precision root requirements
Use a smooth located metal pin, not a threaded clearance bolt, for the low-motion
root proposal. Pin/root gap<=0.02 plus combined pin-anchor/cassette/yoke motion<=0.01
is conditional0.03. Do not add only one gap if pin is loose in two holes: that
case consumes0.05 before bearing play. Actual anchor/mount and measurements absent.

## MEC-018 - Separate outer-ring datum
Investigate measured/shimmed metal shoulder/cover with residual outer travel<=0.01.
Keep inner/outer ring contact separate; no shield contact or cross-ring preload.
Cover-head extensions outside original body explicitly require global checks.
No actual shims, internal bearing displacement or mounting compliance established.

## MEC-019 - Rear outer-ring float detail
Investigate external outer-ring float, not a loose rotating journal. Rear cage
[38,44], nose37.2 replaces C38.1, extraction9.5 replaces7.5; centre41 unchanged.
Conditional float/error and service margins pass. Actual sliding fit/load direction,
ring stops, rear cap/root/retainer strength and global access remain unverified.

## MEC-020 - Nominal stress demands, not strength approval
Record annular beam bending/shear and pin demand per conditional C force scenario.
Do not use solid-circle shear for hollow journal or transfer demanded yield to an
unselected metal. Thread/root notches, fatigue/impact, axial/end-cover loads and
actual support geometry still require validation. Factor2 is a comparison target.

## MEC-021 - Integrated support detail limits
Retain C joint/link centres with explicitly separate support detail reservations.
Rear nose37.2 and extraction9.5 override the bare C cartridge38.1/7.5. Front cover
head extension and cassette pockets are additional global fit/strength/mass checks.
Include accepted0.05 hub travel in operating carrier gaps (front0.15/rear0.25) and
service stroke1.45 (rear port0.15). Remaining bearing/mount allocation0.01 unmeasured.
Support-plane sensitivity changes conditional force/stress demand; no selected
material/strength or physical service approval. Next compare an undrilled journal
retention arrangement before fabrication; not executed in this batch.

## MEC-022 - Compare solid and axially drilled journal sections
Solid section reduces nominal bending demand by19.75%; bore removal alone does not establish strength. Keep historical MEC-015 unchanged; investigate external retention before selecting replacement.

## MEC-023 - Capture the public DC-3 external retaining-ring interface
DC-3 is a public candidate with4.1 mm installed envelope and1 mm end margin. No ring purchase, shaft grade or performance transfer. Public groove-width tolerance missing remains uncertainty.

## MEC-024 - Screen the nominal external-ring axial slack
Nominal ring slack0.04..0.09 mm already exceeds remaining0.01 mm bearing/other-motion allocation. Plain clip is rejected as a drop-in axial locator.

## MEC-025 - Define a measured inner-ring shim acceptance interval
Allocate<=0.005 mm residual inner stack clearance provisionally; requires measurement plus shim uncertainty small enough, not assumed machinability. It adds to prior0.03 root/0.01 outer and leaves only0.005 for bearing/other motion. Actual shim and measurements remain null.

## MEC-026 - Package a front groove and annular shim washer
Candidate groove[-15.9,-15.46], end-17.0±0.02 and washer4.4/3.1 fit local radial reservation; minimum end margin1.06. New shaft bound-17.02 retains front extraction7.5 (margin0.18). Ring/washer contact land and actual fit unresolved; historical files unchanged.

## MEC-027 - Screen groove axial stress without transferring catalogue ratings
Nominal axial groove stress is tabulated for hypothetical1/10/50 N only. Groove is outside ideal radial bending span, but actual notch/contact/edge shear and shaft material are unverified. Catalogue thrust ratings are not robot approval.

## MEC-028 - Compare solid-journal bending compliance
Report ideal radial deflection/slope sensitivity at70/200 GPa illustrative moduli. No metal grade selected, no total joint stiffness or axial motion inference. Root/pin/cassette compliance remains unresolved.

## MEC-029 - Define external-ring service sequence and bench access
External clip prevents withdrawing bearing with the cartridge. Revised candidate service: remove outer cover/housing first, expose/remove clip and shims, then withdraw bearing. Local housing aperture fits4.4 washer; global tools and detachable cover topology remain unvalidated.

## MEC-030 - Create editable grooved solid-shaft machining geometry
Created knee-solid-stub-candidate.scad with real groove and root cross-hole, preserving prior root/shoulder/stop dimensions. It is a nominal custom metal source, uncompiled and unapproved; no printed substitute, tolerance achievement or notch strength asserted.

## MEC-031 - Review solid-journal retention candidate and remaining gates
Prefer solid-journal external-ring candidate for investigation only. Revised axial allocation0.03 root+0.01 outer+0.005 inner leaves0.005 bearing/other motion; external retention changes service sequence. No baseline replacement released, mass entered, physical test or following stage started. Ten tasks MEC-022..031 complete; stop.

## MEC-032 - Audit saved evidence for the 623 axial-play requirement
Saved source audit finds no quantified selected623 axial bound. Five evidence/regeneration assertions pass. Missing evidence stays null; no internet or dependency change.

## MEC-033 - Audit the full axial motion allocation and measurement boundaries
Defined four disjoint diagnostic boundaries and unchanged0.05 travel budget. Five assertions pass;0.01/0.03 bearing-other cases fail. Direct full-assembly measurement remains mandatory.

## MEC-034 - Define a reversible unpowered axial inspection load matrix
Defined nine mandatory reversal pairs, explicit measured force intervals and abort conditions. Five assertions pass.1N is only an inspection load; operating axial load and fixture force method remain unknown.

## MEC-035 - Implement a conservative reversal-displacement uncertainty calculator
Implemented conservative two-endpoint uncertainty sum and invalid/missing input handling. Eleven assertions pass. Synthetic0.0047 fails/0.0009 passes provisional0.001 method target; actual setup capability unknown.

## MEC-036 - Create a traceable null component-inspection worksheet
Created separate null actual-only worksheet for four diagnostic boundaries and traceable method/setup context. Allocation and all null-field checks plus saved regeneration pass; original actual worksheet untouched.

## MEC-037 - Implement conservative component-inspection validation
Conservative component evaluator validates context, fixed allocations, uncertainty and disjoint IDs. Fifteen tests pass; saved actual result NOT_MEASURED. Synthetic boundary pass never grants release; direct assembly measurement required.

## MEC-038 - Capture and conservatively evaluate raw assembled reversal readings
Created nine-pair null matrix and conservative worst-reversal evaluator with angle/load/context validation. Fifteen checks pass; actual result NOT_MEASURED. No original acceptance or mass data edited.

## MEC-039 - Define an editable FDM inspection mount-plate candidate
Created editable50x40x6 FDM mount-plate envelope and seven geometry/source checks plus regeneration. Cover window passes locally; plate blocks flange withdrawal and must be removed before service. Stiffness/tools/real fixture/SCAD compilation unverified; no print release.

## MEC-040 - Gate unchanged axial geometry on traceable assembled inspection evidence
Integrated context/identity/component/raw-travel and interval-clearance gate preserves historical limits. Fourteen checks pass; actual gate NOT_MEASURED. Even a synthetic traceable geometric pass leaves physical/fabrication approval false.

## MEC-041 - Independently review the inspection batch and preserve stage boundaries
All nine new check scripts and cross-artifact null/invariant checks pass. Baseline skeleton/inventory hashes and original0.05/0.15..0.30 acceptance unchanged. Legacy136 Python checks not rerun: runtime unavailable in PATH and outside-project runtime not accessed. No network/deletion/dependency change; actual inspection NOT_MEASURED. Exactly ten tasks MEC-032..041 complete; stop.

## MEC-042 - Define the actual metrology capability evidence gate
Created actual-only null metrology capability gate and five checks. Actual setup evidence is missing; no capability or physical pass. Continue independent key/slot calculations because unresolved coupling geometry is a separate stage4 dependency; no precision fit validation or prototype.

## MEC-043 - Screen axial key engagement and groove-bottom interference under FDM errors
FDM axial projection window is empty (P>=0.80, P<=0.35). Minimum-depth repair requires3.90 disk/7.20 worst stack and fails6 mm envelope. Eleven formula/invalid/regeneration assertions pass. Historical geometry unchanged; no fit approval.

## MEC-044 - Define a precision axial key and grooved-disk candidate within the stack reservation
Separate C-key1 precision candidate meets axial geometric targets with5.98 upper stack in6 mm. Twelve assertions pass. Explicit groove/disk/output-face changes and downstream effects recorded; +/-0.02 machining and material unknown, not adopted as historicalC or fabrication release.

## MEC-045 - Dimension closed radial slide grooves and opposed drive pads
Defined11x2.5 closed slots and two2.4-square pads per hub at+/-3.2. Analytical and360 angle checks pass, stroke margin0.434315 and width0.06..0.14 positive. Feature errors included in disk offset; existing gross radius retained. New minimum contact lever1.97 changes downstream forces.

## MEC-046 - Bound candidate rotational lost motion from rectangular pads and slot width
Implemented first-contact rectangular envelope bound and conservative series lost motion. Eight checks pass. Actual backlash, acceptable robot angular error and axis tilt remain unknown; no actuator-accuracy inference.

## MEC-047 - Create editable detailed coupling geometry and local clearance review
Created real grooved/keyed input/disk/output SCAD and local package review. Independent gap/pocket/port/source/old-face overlap checks pass. Pocket wall0.915 under conservative errors; source uncompiled and strength/access/material unverified. HistoricalC and axes unchanged.

## MEC-048 - Calculate contact and key-root stress demands for the detailed pad geometry
Computed sampled/stall mean contact and nominal pad-root stress demands for equal-two and single-contact cases. Nine assertions pass. One-contact loading doubles individual demand and adds uncanceled bearing force; no material/contact or strength approval.

## MEC-049 - Recalculate support reaction and shaft-demand sensitivity for the new contact layout
Recomputed both balanced-friction and single-pad unbalanced-normal support cases. Endpoint force/moment, vector magnitude and solid-section checks pass. Gravity added by triangle bound rather than assumed orthogonality. New demands do not validate material/strength; historical reports preserved.

## MEC-050 - Account detailed coupling part volumes without inventing actual mass
Created nominal part-volume/attachment ledger with independent disk slicing and illustrative density-only cases. Nine checks pass; actual materials/masses remain null and inventory hash unchanged. No summed robot mass or distal scenario validation.

## MEC-051 - Integrate coupling geometry, contact/support limits and batch invariants
All18 focused PowerShell scripts plus prior/new batch invariants pass. Separate C-key1 fits geometry but remains unapproved: single-pad support bound exceeds saved218N comparison and nominal shaft/material/contact demands are severe. Actual metrology and materials missing; original thresholds, skeleton/inventory and actual worksheets preserved. Exactly ten tasks MEC-042..051 complete; stop.

## MEC-052 - Derive the contact lever required by the cached radial comparison
Derived minimum contact lever for the saved218N radial magnitude comparison under one-pad stall/mu0.3. Recorded user multimeter, power supply and basic load cells; models/calibration unknown and displacement instrument deferred. Formula checks pass; no actual measurements or bearing approval.

## MEC-053 - Bound the largest lever compatible with the unchanged disk reservation
Unchanged gross disk envelope cannot provide the required lever while retaining pad length, slide and radial rim. Independent circle/rectangle bound passes. An explicit separate radial-package proposal is needed; historical dimensions unchanged.

## MEC-054 - Define a larger disk and outboard pad candidate
Separate C-key2 increases disk radius to8.9, pad centers to5.6 and grooves to15.8 with45/135deg axes. Positive rim/port margins and unchanged1.1 slide pass. Minimum lever4.37 exceeds calculated magnitude-screen requirement. Radial envelope change/downstream effects explicit; not adopted.

## MEC-055 - Screen rotated keys and horn fastener head access
Clocked keys clear horn-hole reservations, unlike unrotated outboard pads. Saved1.3mm button-head comparison intersects disk if unrecessed; actual horn fastener is unselected. Thin input web/0.02 stack margin prevents assuming an added head-height web. Conditional collision documented; horn retention remains open.

## MEC-056 - Bound lost motion at the larger contact lever
Recomputed conservative rectangular first-contact reversal bound; larger lever reduces lost-motion bound compared with key1. Actual backlash, acceptable robot error and axis tilt remain unknown. Formula and nonapproval checks pass.

## MEC-057 - Recalculate pad contact and root demands at the larger lever
Recomputed sampled/stall two-contact and single-contact flank/root demands using4.37 mm minimum lever. Force/mean stress scales by1.97/4.37; material/contact/wear/root attachment and simultaneous engagement remain unverified.

## MEC-058 - Recompute bearing and shaft demand after moving the pads outward
Larger lever reduces worst single-pad front radial bound below cached218N comparison under the stated model, but no required static factor or actual bearing/material is selected. Independent corner recomputation confirms gravity not scaled; solid-journal demands remain severe and unapproved.

## MEC-059 - Create editable enlarged coupling source and nominal geometry accounting
Created enlarged clocked coupling SCAD and exact nominal groove/hole/pocket/pad accounting. Explicit optional red head reservations show unresolved conditional interference. Floating disk volume increases; actual materials/mass remain unknown. Source dimension and independent volume-delta checks pass, no compiler or fabrication release.

## MEC-060 - Recalculate release and radial withdrawal for the explicit keys
New explicit keys require1.535 release under conservative errors, leaving0.065 rear-port margin instead of historical0.15. Axial-first then25 radial yoke withdrawal and2 disk removal pass local bounds. Sequence avoids re-engagement; actual heads/tools/retainers/global service unresolved and unapproved.

## MEC-061 - Review enlarged coupling geometry, support gains and remaining release blockers
Prior18 and new9 focused PowerShell scripts plus cross-artifact batch checks pass. Larger lever puts conservative single-pad radial demand below cached218N magnitude comparison, but shaft/material/contact and horn-head constraints remain open. Local margins are small; actual equipment recorded without fake calibration. Exactly ten tasks MEC-052..061 complete; no following task or stage.

## MEC-062 - Audit compatible horn-fastener evidence and unknown head geometry
Audited manufacturer-compatible M2 tapping requirement and3mm penetration ceiling. Machine button-head envelope is not evidence of horn compatibility; Public ROBOTIS package lists PHS M2x6 TAP horn screws (https://www.robotis.com/shop/item.php?it_id=902-0173-000, accessed2026-10-08). Head dimensions and central retention remain unknown; compatible metal HNX330-N101 is an alternative requiring a separate interface audit. No supplier contact.

## MEC-063 - Bound head-height clearance and residual material for an input-adapter recess
Recess window rejects saved1.3mm head; minimum web1.0 and provisional0.6 floor leave0.4 recess/0.35 head before recess error. Independent arithmetic checks pass; no thread/contact/structural floor approval or selected hardware.

## MEC-064 - Screen head-relief pockets in the translating floating disk
Circular disk pockets sized for head/translation/errors cross the disk edge and groove reservation; axial relief also violates center-web target. Independent negative controls pass. Rejected this relief geometry, without claiming actual tapping-head dimensions.

## MEC-065 - Screen a spaced coupling stack against the existing axial reservation
Moving the downstream coupling to clear the comparison head needs at least1.4375 extra nominal spacing and exceeds6mm reservation before spacer error. Rejection checks pass; no silent face-gap opening, disengaged key or support shift accepted.

## MEC-066 - Define a tolerance-aware low-profile horn-fastener envelope contract
Defined conditional installed-head cap2.6 diameter/0.31 height for2.7x0.38 precision counterbores. Worst floor0.6/outer ligament1.64 arithmetic passes;0.1 radial bearing-seat width lacks strength qualification. No compatible part existence or central retention verified; hardware gate closed.

## MEC-067 - Screen bending at the actual nominal shaft steps
Corrected the constant3mm loaded-length screen to actual nominal3/4.4/7/5mm steps. Independent second-moment checks pass. Journal lever is2.05 rather than7.45mm; nominal demand falls, but cross-hole, shoulders, rear shaft and fatigue remain unqualified. Dimensions unchanged.

## MEC-068 - Calculate transverse pin-hole net section for radial bending
Calculated two-cap net area and directional second moments for transverse root hole using diameter limits and conservative position allowance. Independent numerical strip integration passes. Nominal arbitrary-orientation bending bound and average shear recorded; notches and actual pin load transfer remain unresolved.

## MEC-069 - Bound consequences of hypothetical root stress concentration
Recorded factor2 pure-bending sensitivity for hypothetical Kt1/1.5/2/3. Scaling checks pass; no actual stress concentration, yield or fatigue approval inferred. Actual root geometry/load transfer remains the strength gate.

## MEC-070 - Check listed horn screw length against the thin adapter
ROBOTIS lists PHS M2x6 TAP horn screws (https://www.robotis.com/shop/item.php?it_id=902-0173-000, accessed2026-10-08). Under direct seating assumption, nominal penetration4.8mm flat/5.18mm recessed exceeds saved3mm ceiling. Minimum flat grip3mm needs1.8mm extra versus0.02 stack margin. Independent subtraction checks pass; actual screw drawing/tolerances and compatible shorter hardware or alternate horn remain open.

## MEC-071 - Integrate horn-fastener clearance and stepped-shaft evidence
Completed exactly ten bounded tasks MEC-062..071. Public ROBOTIS pack evidence identifies PHS M2x6 TAP; actual head dimensions remain unknown. Recess, circular disk relief and added standoff screens do not release hardware. Direct screw length exceeds saved penetration ceiling. Actual nominal shaft steps replace overly conservative constant3mm model; root-hole caps independently numerically checked, notch sensitivity remains hypothetical. Prior27 and new9 focused PowerShell checks plus integration pass. CAD not compiled; Python historical tests not rerun. Stage4 only, no physical/fabrication release or following task started.

## MEC-072 - Audit public metal horn mounting interface
Saved and audited the manufacturer-linked HNX330-N101 reference drawing (21-Dec-22): four M2x0.4 through threads on12mm PCD,16mm OD,2.7mm plate and5.6mm overall axial dimension. XC330 central retention explicitly BHS_M2.5x06_NYLOC_K. Product page lists compatibility and PHS M2x4 frame screws. Cross-checked visual paths and text; production tolerances, alloy/temper, installed face datum and actual heads unknown. Sources: https://en.robotis.com/shop_en/item.php?it_id=903-0314-000 and https://www.robotis.com/service/download.php?no=2163 (accessed2026-10-08). Separate candidate only.

## MEC-073 - Define a local metal horn axial datum and unresolved installation transform
Defined horn-local front face y0, plate back2.7 and overall back5.6, with four explicit PCD centres. Independent boss/PCD checks pass. Usable thread span is at most plate thickness, not a guaranteed engagement. Installed transform remains unknown; original knee datums unchanged. Any replacement affects stack, servo clearance, support/service and central retention.

## MEC-074 - Screen supplied frame screw length and rear protrusion
Supplied nominal M2x4 gives2.8mm penetration through1.2mm flat adapter and3.18mm through0.38 recess:0.1/0.48mm beyond nominal2.7mm plate. Independent checks pass. No plastic penetration limit imported; motor rear space, actual usable engagement, screw tolerances and tip geometry remain unknown. A1.3 nominal grip alone leaves zero dimensional margin and is not a repair approval.

## MEC-075 - Screen a central access opening against clocked adapter keys
Proposed6mm central adapter opening (+/-0.2 diameter) retains1.27mm conservative key separation and1.5mm ligament to mounting-hole envelopes. Drawing cavity5.6 fits nominally, but actual screw-head maximum, horn tolerance, alignment, tool corridor and plate strength remain unqualified. Independent worst-case arithmetic passes; no installed hardware change.

## MEC-076 - Define central retention assembly and service dependencies
Created explicit assembly/service dependency contract: central retention before disk installation; independent support, key release, radial yoke withdrawal and disk removal before central service. Order assertions pass and original1.535 release retained. Actual tools, locking/torque, installed horn datum and global service remain unknown; no physical procedure released.

## MEC-077 - Calculate frame-screw group torque-transfer demands
Calculated0.93Nm nominal screw-group demands at6mm lever:38.75/77.5/155N per screw for equal4/opposed2/single transfer. Torque equilibrium and single-screw imbalance checks pass. Gross2mm shear and1mm-web hole-bearing comparisons are not actual allowable stresses; preload, thread root/strip, material, joint slip and radial transfer unqualified.

## MEC-078 - Calculate net area and nominal volume of the access adapter
Created nominal net-area/volume ledger for6mm central access opening, four2.2mm holes and unchanged clocked pads/web. Independent cylinder subtraction and pad-volume checks pass. Actual density/mass, plate stiffness and hole/seat strength remain unknown; historical inventory unchanged.

## MEC-079 - Create editable separate central-access adapter geometry
Created separate editable SCAD input adapter with6mm central opening, flat2.2mm mounting holes,1.2mm web and unchanged45deg clocked2.4mm pads at5.6mm. Source/ledger checks pass. Horn and installed transform not modeled; actual heads and rear protrusion unresolved. Source uncompiled, geometry proposal only; original coupling source unchanged.

## MEC-080 - Bound adapter hole registration for nominal M2 screws
Worst-case2.2mm mounting holes at FDM+/-0.2 diameter give zero nominal M2 radial clearance before0.283mm position error; this error contract cannot guarantee fit. Hypothetical+/-0.02 diameter/coordinate positions leave0.0617mm for all remaining horn/screw/registration errors. Independent diameter/position checks pass; no precision capability or actual pattern fit inferred.

## MEC-081 - Integrate metal horn evidence and adapter feasibility gates
Exactly ten tasks MEC-072..081 complete. Saved primary horn drawing and separate datum, frame screw length, central access, service-order, screw-group demand, net-volume, editable SCAD and tolerance reports. Prior36 plus new9 focused PowerShell checks and integrated reviews pass. Metal horn offers verified M2x0.4 mounting threads and XC330 central screw specification, but supplied nominal4mm screws protrude behind the2.7mm plate with thin adapter, installed heads/datum/usable engagement unknown, and FDM pattern error cannot guarantee fit. Separate access geometry only; actual mass/material/metrology null, source uncompiled, stage4 retained. No supplier contact or next task executed.

## MEC-082 - Verify a publicly dimensioned M2 frame-screw candidate
Primary NBK PDF and product table verify nominal M2x0.4, head diameter3.6..4 and height0.4..0.6, length4. The screw is a metal-horn comparison only; never use it in the plastic tapping pilot. Published0.15Nm screw ceiling is not horn tightening approval. Length tolerance and actual lot strength unknown. Primary sources linked in JSON; accessed2026-10-08. No supplier contact.

## MEC-083 - Bound a precision recess and residual adapter floor
Separate2.3+/-0.02 web,0.7+/-0.02 recess and4.2+/-0.02 seat leave1.56 floor,0.08 flush and0.18 diametric clearance. Independent corner arithmetic passes. Precision process, head fillet seating and material strength unqualified; no FDM capability inferred.

## MEC-084 - Bound screw penetration using explicit incoming-inspection limits
Proposed incoming-inspection length3.9..4.1 and horn plate2.68..2.72 yield penetration2.26..2.54 and0.14 rear margin. Eight corners independently checked. These are requirements, not manufacturer tolerances; incomplete threads, tip/runout, seating and actual usable engagement remain unknown.

## MEC-085 - Bound recessed-seat separation from the plate edge and central opening
Separate9.3+/-0.02 radius,6+/-0.02 central opening and maximum4.22 seats retain positive outer/inner/adjacent ligaments with0.02 coordinate position errors. Independent distances pass; seat/floor strength not established.

## MEC-086 - Check the thicker adapter against the unchanged axial package
Conservative stack7.08 exceeds prior6mm reservation. Independent subtraction/rejection passes. Front support/root/yoke and reservation need an explicit separate revision; opening a running gap or reducing engagement is not accepted. Original datums unchanged.

## MEC-087 - Define the separate C-key3 package and front-support revision
Recorded explicit separate C-key3 revision and downstream impact: thicker recessed adapter,7.2 working-layer reservation, front shaft/root/support/cartridge/arm shifted1.1 outward, rear support/arm unchanged and bridge lengthened. Coordinates assume horn-local y0, not a verified installed transform. Baseline axes, links, acceptance and inventory unchanged. No candidate adoption.

## MEC-088 - Validate key engagement and groove floor clearance at axial corners
Axial corners retain0.445 minimum engagement,0.095 floor clearance and0.8 disk center web. Revised precision input allocation makes worst working stack6.90 within7.2 by0.30. Original measured acceptance retained; actual travel/tilt/flatness not measured. Output root extent is excluded from this working-layer sum and separately checked.

## MEC-089 - Check revised adapter and disk swept radial keepouts
Checked full-rotation circles against cached connector x boundaries with0.4 allowance. Adapter gains positive margin at precision9.3 radius. Disk offset uses assembly coordinate bounds and two precision position errors; this allocation is independently stated rather than copying historical scalar offset. Actual harness/service box still unverified.

## MEC-090 - Check clocked key prisms against four recessed mounting seats
Eight key/seat pairs checked with circumscribed maximum key square, maximum seat radius and independent position errors. Independent cosine-rule bound agrees; positive separation throughout clocked input geometry. No strength/head-fillet approval.

## MEC-091 - Validate key travel inside the unchanged closed slots
Recomputed worst closed-slot slide allowance from length, key-centre and key-size limits; nominal1.1 travel and0.06..0.14 width clearance retained. Positive corner margin verified. Angular misalignment, wear, actual backlash and precision capability remain unknown.

## MEC-089 - Check revised adapter and disk swept radial keepouts
Checked full-rotation circles against cached connector x boundaries with0.4 allowance. Adapter gains positive margin at precision9.3 radius. Disk offset uses assembly coordinate bounds and two precision position errors; this allocation is independently stated rather than copying historical scalar offset. Actual harness/service box still unverified.

## MEC-092 - Bound reversal lost motion for the revised key fit
Independent rotated-rectangle first-contact equation confirms two-interface reversal bound; thicker input does not improve unchanged pad/slot backlash. Axis tilt and acceptable robot angular error remain unverified.

## MEC-093 - Calculate equal opposed-pad pressure and root demands
Computed momentary stall comparison for two equally loaded pads at worst lever/engagement. Torque and area independently checked. Equal engagement, peak contact, wear, actual material and fatigue not qualified.

## MEC-094 - Calculate one-pad demand and unbalanced friction resultant
One loaded pad doubles individual demand and produces unbalanced normal load. Hypothetical friction0/0.1/0.3 resultant checked by vector squares; no actual friction or load-sharing claim. Existing high mean-pressure/material gate remains.

## MEC-095 - Recompute shifted support reaction envelopes from force and moment intervals
Freshly enumerated support, force/moment and contact-position endpoints for front-14.1/rear41 proposal. Ground uses saved20g distal assumption; not stale prior-support reactions. Force/moment equations independently pass; rotating contact and gravity combined by triangle bound. Actual mass, dynamic/horizontal/axial loads unverified.

## MEC-096 - Calculate front shaft stresses at each shifted nominal step
Updated front-shaft3/4.4/7/5mm step demands using new reaction envelope. Relative levers remain unchanged because root and front bearing shift together. Independent section-moment checks pass; groove, root hole, fit, shoulders and fatigue remain excluded.

## MEC-097 - Recalculate root-hole net bending under the new support load
Root net-cap geometry unchanged and translated with front support. Fresh weak-axis section agrees with independently integrated prior geometry; stress scales with new force. Kt1..3 sensitivity stays hypothetical. No yield, fatigue or pin-bearing qualification.

## MEC-098 - Screen nominal root-shaft torsion and flag transverse-hole limitations
Calculated solid-root torsion comparison while explicitly withholding cross-hole torsion capacity. Independent solid polar formula passes. Hole/pin transfer changes the load path; cap Ix+Iz cannot be treated as a valid noncircular torsion constant.

## MEC-099 - Calculate root-pin shear with torque and radial reaction combined
Root-pin calculation now includes drive torque as an opposed couple plus radial force by triangle bound. Checked two-side and one-side sharing; single-plane demand doubles. Earlier radial-only pin comparison is insufficient for this torque-transfer assumption. Actual contact, support sharing, pin material/bending and fatigue remain open.

## MEC-100 - Calculate nominal pin-hole bearing pressure and end ligament
Projected pin-hole bearing comparison assumes half-root width as effective contact length; one-side load doubles pressure. Conservative pin position and hole diameter leave only0.3925 axial end ligament. Arithmetic passes; real pressure distribution, pin bending, root cracking and torque transfer are unqualified.

## MEC-101 - Verify translated clip groove remains outside the front radial support span
Translated external DC3 groove and end interval retain0.46 separation from loaded journal and1.08 minimum end ligament. No axial bore added. Source coordinates checked; actual axial load, clip/groove material capacity and installation retention unresolved.

## MEC-102 - Compare shifted bearing loads against the cached static radial rating
Cached NSK623218N provides only about1.12 magnitude ratio for revised front load. Required-factor1/1.5/2 scenarios show factor2 not met. Pure radial comparison excludes actual variant, axial/mixed loading, life and dynamic impact; required factor not selected.

## MEC-103 - Calculate stepped-shaft compliance without selecting a material modulus
Nominal cantilever strain-energy compliance integrated piecewise over actual steps, independently midpoint-checked.0.02mm radial target is exploratory, not adopted acceptance. Bearing-distributed loading, root fixity, cross-hole and carrier compliance excluded; actual modulus unknown.

## MEC-104 - Bound additional radial compliance within the remaining disk-port margin
Remaining disk-port geometric margin bounds any added radial compliance. Subtracting exploratory0.02 leaves positive margin, but actual carrier/shaft/bearing deflection, vibration and manufacturing evidence are absent. The previous0.4 keepout allowance remains intact; this is an additional conservative allocation.

## MEC-105 - Calculate recessed screw seat pressure under explicit preload hypotheses
Minimum nominal annular seat area uses head minimum3.6 and through-hole maximum2.22. Torque/nut-factor hypotheses yield pressure sensitivity only; friction, head fillet/contact, horn thread strength and preload scatter unknown. NBK screw ceiling does not authorize any horn tightening setting.

## MEC-106 - Check seated screw clearance even when the floating disk touches the input face
Published maximum0.6 head fits minimum0.68 recess by0.08 even at zero disk-face gap. Retaining0.05 clearance leaves0.03 maximum additional seating lift. Burrs, fillets, debris and actual dimensions must be inspected; this resolves a conditional head-envelope collision, not actual fabrication.

## MEC-107 - Create the recessed input-adapter source and nominal volume ledger
Created separate precision input SCAD with real recessed seats, central opening and shifted keys. Nominal volume subtracts only extra seat annuli after full through holes. Independent accounting and source checks pass; uncompiled and no actual density/mass/material approval.

## MEC-108 - Create translated floating-disk source and volume accounting
Created translated precision disk source with orthogonal clocked closed grooves. Groove subtractions do not overlap through center web; span and volume accounting checked. Volume unchanged from same-size prior disk; actual material/wear/mass and compilation unknown.

## MEC-109 - Create translated output-hub source and root-pocket ledger
Created translated output hub with real root pocket and output keys; nominal pocket floor1.315 retained instead of inadvertently thinning it while enlarging input. Independent axial spans/volume checked. Root cassette attachment, material and compilation remain open.

## MEC-110 - Create shifted front-shaft source and bounded cross-hole volume accounting
Created translated stepped custom-metal shaft source with external groove and transverse root hole. Union ledger avoids overlapping shoulder/flange double count; numerical orthogonal-cylinder intersection bounded independently by chord lengths. Actual material, machining fits/notches/strength, mass and compilation unresolved.

## MEC-111 - Create a local inspection assembly for the four revised parts
Created editable local coupling scene using separate parts and original servo-case box. Actual installed metal horn, screw heads and housing interfaces not falsely modeled. Source linkage checks pass; no CAD compilation, interference-mesh or physical release inferred.

## MEC-112 - Check revised part faces and key engagement against the shared datum
Cross-part nominal faces retain0.1125 gaps and equal0.7525 key engagement, total0.225. Root shaft end/pocket stop share-6.7. Independent face differences pass; actual installed horn datum and tolerance measurements remain unknown.

## MEC-113 - Create translated front-cartridge and flange clearance envelope
Created translated cartridge/flange clearance source with bearing/bolt reservation contract. Body and bearing centre cross-checked against old source. Ring stops, cover screws/contact, fits and fixed mount remain omitted/open; envelope is not a printable bearing housing or fabrication release.

## MEC-114 - Check translated flange mounting-hole and driver reservations
Translated flange retains nominal2mm head-edge ligament and local negative-y driver corridor. Existing FDM position error exceeds minimum nominal M3 radial clearance; mount fit cannot be guaranteed by hole diameter alone. Actual heads, captive nuts/inserts, driver and fixed anchor unknown.

## MEC-115 - Create revised front-arm and bridge bounding geometry
Created translated-front/unchanged-rear yoke bounding source and lengthened bridge47.1. Box joins overlap3.5. Actual root bosses, pin anchors, holes, shell/fillet topology and structural properties remain absent; source is a clearance envelope, not a printable structural leg.

## MEC-116 - Bound bridge clearance over a full rotation around the knee axis
Whole360deg bridge radial bound clears circumscribed cached servo and connector boxes after0.4 allowance, therefore includes desired knee range. This is a conservative local bounding proof, not body/harness/self-collision approval.

## MEC-117 - Check rotating arms and output hub against connector axial bounds
Front arm/hub remain axially outside cached ports while rear arm stays unchanged; locating cartridge-to-arm reserve remains0.15 with original travel allowance. Positive slab separation checked. Installed horn transform, rear cartridge float and real harness still unverified.

## MEC-118 - Verify key disengagement and rear-arm release margin for the revised package
Explicit0.865 keys retain1.535 axial release requirement. Because rear arm stays at33, rear port margin remains0.065; shifting whole yoke would fail this constraint and was not assumed. Local arithmetic passes; fixture/control/tools/global service unknown.

## MEC-119 - Bound radial yoke withdrawal and floating-disk extraction
25mm radial withdrawal separates revised input/disk bounds after axial release, then2mm disk extraction exceeds release by0.465. Sequence checked to avoid moving disk toward unretracted output keys. Actual covers/rings/harness/tools and body service remain unverified.

## MEC-120 - Bound translated front-cartridge withdrawal from the shifted shaft
Translated7.5mm front withdrawal leaves0.18 conservative shaft-end margin after0.4 additional service allowance. Independent subtraction passes. Actual cover/clip removal, bearing fit, fixed-carrier bolt access and unsupported-load fixture still open.

## MEC-121 - Record revised local service dependencies and unverified operations
Recorded support/retainer/cartridge/key/yoke/disk/central-service dependencies with checked ordering. Unverified fixture, locking/torque, clip covers and actual tools prevent an operational procedure release. No hardware built, moved or powered.

## MEC-122 - Create a reusable budget hobby-servo split cradle and fit coupon
Created adjustable split case cradle, shallow fit coupon, three compiled STL exports and visually reviewed assembly PNG. Independent mesh-edge and print-bed checks pass. Minimum bent-pose torque screen is about0.27Nm versus0.92Nm published stall; extended-leg loading is not qualified. Provisional budget allowance NZ$680–800 is not retail pricing. MG996R-class12-servo mass660g leaves540g within target; actual fit/mass unknown. Public TowerPro evidence recorded; user-approved portable OpenSCAD2021.01 added locally. XC330 precision-coupling route deferred for RevA; historical geometry and actual inventory preserved.

## MEC-123 - Define the reusable supported hobby-servo joint layout
Recorded provisional shaft/horn datum,624 bearing boundary size and common-fastener stack. Bridge span66.2mm and bearing front face-18mm independently reconcile. Actual horn datum and fits require a cheap sample; no precision machining or historical skeleton change.

## MEC-124 - Create the fixed rear support for the hobby-servo cradle
Created printable3mm base with10mm local pivot boss, reinforcing ribs, cradle-matched mounting slots and recessedM4 head. CGAL compilation passes; actual screw head and clamp fit remain prototype checks.

## MEC-125 - Create the horn-driven front arm
Created5mm front arm with10mm central access and four radial7–11mm M2 clearance slots for the supplied horn. Lightening window and two M3 bridge holes compile as a simple solid. Actual horn hole availability, rear nut clearance and face height require the fit sample.

## MEC-126 - Create the rear arm with a commodity 624 bearing seat
Created7mm rear arm with provisional13.2mm diameter x5.2mm deep624 seat,1.8mm front lip,8mm inner clearance and two outer-ring retainer holes. CGAL compilation passes. Bearing seating remains adjustable via the upcoming coupon.

## MEC-127 - Create the twin-column cross-joint bridge
Created two12mm columns with a joining3mm rib and M3 through-holes14mm apart.66.2mm length reconciles arm contact faces. Single-solid CGAL compilation passes; use twoM3x90 bolts or threaded rods, no structural printed threads.

## MEC-128 - Create the bearing spacers and outer-ring retaining plate
Created8mm front and3mm rear inner-ring spacers plus3mm outer-ring retaining plate with10mm central clearance. Three CGAL compilations pass.5.8mm spacer OD is provisional and must contact only the actual inner ring; hand rotation checks binding. Plain commodity metal spacers are acceptable substitutes.

## MEC-129 - Create the supported hobby-servo joint assembly
Created nominal assembled joint scene with case/horn assumptions clearly distinguished from printed parts. CGAL assembly export and separate PNG render pass; image reviewed for axial gaps, bridge position and access. Integration review corrected the retaining plate to a connected18mm central ring. An unused interactive shell variable failed after the successful export; the independent preview command succeeded. No physical fit inferred.

## MEC-130 - Create the horn and bearing-seat fit samples
Created flat horn-slot sample and three-seat624 coupon at13.0/13.2/13.4mm, identified by1/2/3 dots. Both CGAL compilations pass. Test these and the existing cradle coupon before printing the complete joint; actual bearing/horn fit remains unmeasured.

## MEC-131 - Validate the supported joint meshes and nominal rotation clearances
Independent checks pass for nine closed, connected STL parts on the print bed and layout/source consistency. All local modeled rotations have2.67mm bridge radial margin after0.8mm allowance; front/rear axial separations pass. Actual ears/horn/cables/fasteners and downstream links excluded. Solid printed mass estimate83.5g; illustrative65% material with12 servos totals1311g before other hardware. Therefore this is an oversized bench-joint test kit, not a12-joint robot baseline. Full robot needs integrated lighter mounts; no strength/duty/physical release inferred.

## MEC-132 - Package the supported bench-joint print kit and assembly instructions
Packaged nine printed joint parts with verified SHA256 manifest, three fit-first samples and concise unpowered assembly instructions/BOM. Increased M4 head recess to4.5mm for the assumed socket-head screw; support recompiled and all nine mesh/clearance checks rerun successfully. Current directions explicitly restrict this oversized kit to bench testing;12-copy mass exceeds the1.2kg target. No purchasing, hardware testing or next major stage. Exactly MEC123–132 complete; stop.

## MEC-133 - Create the70mm upper-leg mount with a lighter knee-ear saddle
Created70mm upper plate, lighter knee-ear saddle and fit coupon; all three compiled STL meshes pass closed-edge/connectivity/bed checks. Sampled q2=-40..85 nominal holder clearance minimum10.48mm; assembly preview reviewed. Knee case clocked90deg and hip bridge/rear arm moved to opposite side in this new variant; historical sources and25/70/85 skeleton preserved. Saddle7.8g solid versus old clamp26.2g, excluding the unfinished new knee rear support; upper plate17.7g. Maintained docs/purchasing-bom.md now lists staged servo/bearing and current assembly fastener counts, future quantities and explicit unquoted budget caps. Actual ear/horn fit, rear support, lower leg and full robot mass remain unresolved; no powered/physical tests or purchases.

## MEC-134 - Create a removable knee rear-support bracket for the ear saddle
Created3mm-base knee support with local8mm pivot boss and36mm saddle tower. Axis aligns to knee0,0; support top28 matches saddle underside. Shared mount stack63mm uses twoM3x70 bolts replacing M3x40. CGAL compilation passes; M4 head access and actual fit remain hand checks.

## MEC-135 - Create the85mm knee-driven lower front link
Created5mm flat knee-driven link with supplied-horn slots, reused58mm bridge holes and foot mount76mm from axis. Its matching carrier ends at84mm;1mm pad establishes85mm nominal contact. CGAL compilation passes; no printed spline or skeleton change.

## MEC-136 - Create the10mm knee bearing inner-ring spacer
Created10mm inner-ring spacer with existing5.8mm OD/4.3mm bore. Fixed support-8 reaches bearing front-18. CGAL passes; actual inner-ring contact and small-print quality checked physically, metal substitution allowed.

## MEC-137 - Create the replaceable foot-pad carrier
Created support-free3mm base with raised3mm end wall, twoM3 foot mounts and replaceable1mm rubber/EVA pad.76+8+1=85mm nominal knee/contact radius. CGAL passes; actual pad thickness/compression remains a prototype measurement.

## MEC-138 - Create the supported two-DOF pitch-leg assembly
Created the supported two-DOF pitch-leg scene at nominal44.0486/78.9786deg with70/85mm references. Reused rear arms, bridges, retainers and rear spacers; knee front spacer10mm and new support included. CSG export and PNG render pass; nominal image reviewed. No actual fit or powered motion inferred; J1 still absent.

## MASS-002 — User revised mass limit,2026-10-08
Adopt maximum complete operating mass2.0kg in place of1.2kg. Includes battery/electronics; budget and70/85mm geometry unchanged. Twelve55g servos leave1340g for other parts. New load screens use2kg; historical1.2kg reports remain unchanged and cannot qualify the increased load. Downstream servo torque, supply sizing, chassis and final mass checks must use the new ceiling.

## MEC-139 - Check the supported knee motion and minimum load screen
Four new STL meshes are closed/connected/on bed.70/85mm chain closes to120mm height in nominal pose. Knee bridge20–90deg1deg samples pass; modeled front-arm intersections empty at20/79/90deg. Updated user2kg ceiling gives nominal knee about0.42Nm vs0.92Nm published4.8V stall with0.10Nm allowance. Extended horizontal load exceeds stall, so no full-range loaded approval; continuous/dynamic duty unknown. Absolute-path CSG export verified after initial relative-path export failed;138 preview remains valid. Actual fit and cables untested.

## MEC-140 - Create a removable upper-link cable guide
Created open8mm cable channel with small tie holes and M3 mounting tab; clamp to existing negative upper-plate window using12mm OD backing washer. CGAL passes; nominal guide location-24.5 keeps mounting hole-30.5 inside window and separates it from knee horn. Cable slack and connector fit remain hand checks; no added structural holes.

## MEC-141 - Create the pitch-leg bench mounting plate
Created5mm flat bench plate with existing14/17.25mm mounting coordinates and four4.5mm bench-anchor holes. FourM3x20 bolts replace hip base M3x16 to include the extra5mm layer. CGAL passes; clamp/anchor to a rigid bench, support moving leg for unpowered assembly. Fixture is not a robot chassis or proof of powered-load stability.

## MEC-142 - Update the buying BOM for the supported two-DOF pitch leg
Updated maintained shopping list and machine-readable role counts: two servos/two624 bearings,23 M3 bolts/nuts and46 washers including one12mm backing washer. Separate40mm-standoff bench hardware from robot quantities. Assembly review corrected bench adapter to7mm with22mm pivot-boss relief and negative-x anchors, avoiding the original solid-plate interference; recompiled and six-mesh checks pass. Revised mass ceiling2kg applied, budgets unchanged; quantities for complete robot remain provisional.

## MEC-143 - Package and independently check the supported pitch-leg print kit
Packaged16 unique printable files/20 pieces including bench adapter, SHA256 manifest, maintained purchasing BOM and unpowered assembly guide. Six new meshes pass closed/connectivity/bed checks; modeled front intersections empty at20/79/90deg, sampled bridge margin1.16mm, fixture bounds pass. Final assembly PNG visually reviewed and absolute-path CSG verified. Complete mass ceiling now2kg; nominal knee0.42Nm vs0.92Nm stall is only a bent-pose screen. Printed pitch-leg solid mass156.3g excludes19.8g bench adapter; actual prints/fit/current/duty unknown. Exactly MEC134–143 complete;2DOF only, noJ1 or next stage started.
# ARCHIVE-001 — Repository housekeeping, 2026-10-08

Moved the deferred XC330 precision knee/coupling route and MEC-001–121 records
into ARCHIVE/2026-10-08-superseded-design, preserving original paths and bytes.
The current low-cost hobby-servo direction and its dependencies remain active.
The move manifest provides SHA256 and restoration paths. Historical scripts
are retained for reference, not treated as current runnable workflows.
No geometry, architecture, inventory or engineering stage changed.
