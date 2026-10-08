# KIN-004: candidate geometric joint-angle ranges

Adopt the following desired ranges for subsequent kinematic analysis. They
are **not measured servo travel, collision-free bounds, physical stops, or
operational software limits**. All four legs share these geometric q ranges
under the [KIN-001 convention](leg-frames.md). Preserve the KIN-002 skeleton
and [KIN-003 nominal pose](standing-pose.md) without changes.

The machine-readable range contract is
[joint-ranges.json](../mechanical/joint-ranges.json); it references the pose
data rather than copying nominal angles. Units are degrees. Endpoints are
included for analysis, with no implication that hardware can reach them.

## Selected bounds and nominal reserve

| Joint | Lower | Upper | Span | Nominal | To lower bound | To upper bound |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| q1: hip abduction/adduction | -25 | 30 | 55 | 0.000000 | 25.000000 | 30.000000 |
| q2: hip pitch | -40 | 85 | 125 | 44.048626 | 84.048626 | 40.951374 |
| q3: knee flexion | 20 | 130 | 110 | 78.978550 | 58.978550 | 51.021450 |

Span = upper - lower. Reserves = nominal - lower and upper - nominal.
These are distances in angle coordinates from the nominal pose to proposed
boundaries, not guaranteed operating margins or allowances for a servo stop.
The nearest proposed boundary is 25 degrees away for q1, 40.951374 for q2,
and 51.021450 for q3. No separate inner operating interval is selected.

## Rationale and coordinate meaning

- **q1, -25 to +30:** provide moderate inward and outward articulation, with
  slightly more requested outward motion. The asymmetry is a design preference
  that may be useful for stance adjustment, not a result of clearance or gait
  validation. q1 = 0 puts the pitch-leg plane vertical; positive is outward
  on either side. Negative q1 is inward rotation, not necessarily crossing
  the body side plane.
- **q2, -40 to +85:** allow upper-link motion behind vertical-down and a larger
  forward rotation around the forward-leaning nominal pose. q2 = 0 puts the
  upper link downward within the abducted leg plane. Positive q2 swings the
  upper link forward. The bounds leave the upper link below the hip in that
  plane, but do not constrain the complete lower-link/foot position.
- **q3, 20 to 130:** preserve positive knee flexion and keep this coordinate
  away from both pitch-chain singular references, q3 = 0 (straight) and
  q3 = 180 (fully folded). The lower bound is 20 degrees from straight and
  the upper bound is 50 degrees from folded. The knee's internal triangle
  angle is 180 - q3, hence 50 to 160 degrees. q3 = 0 is the mathematical
  straight reference, deliberately outside this candidate operating range.

The bounds are initial engineering assumptions, not optimization results.
Their spans (55, 125, 110 degrees) are desired joint travel, not specifications
attributed to an MG90S. No assumption of a 180-degree usable servo sweep is
made. Transmission, horn indexing, mounting polarity, and measured usable
servo travel are still unknown. MG90S remains an unvalidated actuator candidate.

Excluding q3 = 0 and 180 excludes those pitch-chain singularities only.
It does not establish full three-axis nonsingularity, acceptable mechanical
advantage, or a collision-free configuration for any combined angle triple.
The independent intervals form an analysis input box; many combinations may
later need exclusion for body/leg/ground contact, actuator travel, or load.
No Cartesian workspace, ground clipping, or reachable gait is asserted here.

## Mapping to coordinate rotations on all four legs

Use the same q1/q2/q3 bounds and nominal values for FL, FR, RL, and RR.
Do not negate the right leg's q1 range itself: q1 remains outward-positive.
KIN-001 forms orientations with these active right-hand coordinate rotations:

```text
alpha1 = s*q1       about body +x
alpha2 = -q2        about abducted +y
alpha3 = q3         about upper-frame +y

R = Rx(alpha1)
U = R * Ry(alpha2)
V = U * Ry(alpha3)
```

Here s = +1 for FL/RL and -1 for FR/RR. The pitch axes' local y directions
remain parallel. Alpha3 is relative knee rotation; the lower segment's net
pitch relative to the abducted frame is -q2 + q3. These alpha values are
coordinate rotations, **not servo angles**.

| Leg | alpha1 about +x | alpha2 about local +y | alpha3 about local +y | Nominal alpha1 / alpha2 / alpha3 |
| --- | --- | --- | --- | --- |
| FL | [-25, 30] | [-85, 40] | [20, 130] | 0 / -44.048626 / 78.978550 |
| FR | [-30, 25] | [-85, 40] | [20, 130] | 0 / -44.048626 / 78.978550 |
| RL | [-25, 30] | [-85, 40] | [20, 130] | 0 / -44.048626 / 78.978550 |
| RR | [-30, 25] | [-85, 40] | [20, 130] | 0 / -44.048626 / 78.978550 |

For a negative sign, transform both endpoints and reorder them:
[lower, upper] maps to [-upper, -lower]. Rear-leg angles retain the front-leg
convention; the fore/aft placement translation does not affect ranges.
Left/right reflection maps frames by S*frame*S, where S = diag(1,-1,1);
the resulting orientation still has determinant +1. This describes geometry
only and does not select an actuator command conversion.

## Verification and boundary

Run `python -B mechanical/check_joint_ranges.py`. The checker reads the
range and pose contracts, verifies finite ordered bounds, spans and nominal
reserves, checks all-leg endpoint mapping, and verifies frame reflection at
the eight angle-box corners and nominal pose. It examines orientations only:
it does not compute foot positions or map workspace. Document tables are
checked against source values to six displayed decimals.

The earlier geometric zero reference remains valid for dimensioning even
though its q3 = 0 lies outside the proposed range. Nothing in KIN-001 through
KIN-003 is redefined by the range selection.

KIN-005 now characterizes the [ideal foot workspace](foot-workspace.md) for
this unchanged angle box. Its bounds and projections do not establish
physical clearance or usable ground-contact motion. Torque validation and
detailed mechanical design remain later tasks.
