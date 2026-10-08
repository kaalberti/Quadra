# KIN-002: candidate numeric skeleton

This is an ideal centre-line layout for subsequent kinematic work, not a
mechanically released design. All dimensions are in millimetres. The frame
and angle definitions remain those in [KIN-001](leg-frames.md).
The machine-readable candidate is [leg-skeleton.json](../mechanical/leg-skeleton.json);
the editable drawing is [leg-skeleton.svg](../mechanical/leg-skeleton.svg).

## Candidate dimensions and rationale

| Parameter | Candidate | Basis |
| --- | ---: | --- |
| Chassis length x width | 180 x 110 | Preserve the user's target planform; thickness is undefined. |
| a: root half-length | 75 | Gives 150 front/rear root spacing and a 15 longitudinal inset at each chassis end. This is a starting allocation, not verified mounting room. |
| b: root half-width | 55 | Puts each J1 reference centre on the nominal chassis side boundary. |
| h: J1 root height | 0 | Choose the shared J1 axis plane as the body z = 0 datum; this does not place the chassis top or bottom. |
| u: J1-to-J2 forward offset | 0 | Begin with roots and hip-pitch centres at the same longitudinal station. |
| d: J1-to-J2 outward offset | 25 | Provides a compact candidate separation from the chassis side to the pitch-leg centre plane. This is not derived from a measured servo envelope. |
| w: J1-to-J2 vertical offset | 0 | Begin with hip centres at the same height to simplify the initial skeleton. |
| Lu: J2-to-J3 reference length | 70 | Preserve the user's approximate upper-link target as the candidate exact centre distance. |
| Ll: J3-to-foot reference length | 85 | Preserve the user's approximate lower-link target as the candidate exact centre-to-contact distance. |

The 25 mm offset is a hypothesis to be tested during actuator packaging and
torque validation. Increasing it widens the leg planes but increases the
lateral lever arm of ground forces about J1. No adequacy claim follows from
its selection. The 15 mm end inset similarly does not reserve a proven
servo or fastener envelope.

All four J1 axes are coplanar, and the chassis origin is their rectangle's
centre. This chooses a datum within the freedom left by KIN-001; chassis
thickness and underside clearance remain unknown. No extra lateral offset
is introduced along the upper or lower links.

With u = w = 0, the infinite J1 and J2 axis lines intersect at O. H lies
25 mm along the J2 axis from O. Thus 25 mm is the distance between the
selected reference centres, not a shortest distance between the axes.
Whether actuator bodies, bearings, and a hip carrier can realize this
arrangement remains unverified; nonzero u or w may be needed later.

## Reference configuration and coordinates

The drawing uses q1 = q2 = q3 = 0 solely to expose the reference lengths.
Both links point downward. This straight configuration is singular for the
two-link pitch chain and is not a standing-pose recommendation. The foot
points at z = -155 do not define the eventual ground plane or body clearance.

Positions below are in the body frame (+x forward, +y left, +z up).
O is J1's reference centre, H is J2's centre, K is J3's centre, and P is
the ideal foot contact. J1/H/K labels in the drawing denote axis centres,
not servo case positions.

| Leg | O / J1 | H / J2 | K / J3 | P / foot |
| --- | --- | --- | --- | --- |
| FL | (75, 55, 0) | (75, 80, 0) | (75, 80, -70) | (75, 80, -155) |
| FR | (75, -55, 0) | (75, -80, 0) | (75, -80, -70) | (75, -80, -155) |
| RL | (-75, 55, 0) | (-75, 80, 0) | (-75, 80, -70) | (-75, 80, -155) |
| RR | (-75, -55, 0) | (-75, -80, 0) | (-75, -80, -70) | (-75, -80, -155) |

| Joint | Zero-reference signed axis, FL/RL | Zero-reference signed axis, FR/RR |
| --- | --- | --- |
| J1 at O | (+1, 0, 0) | (-1, 0, 0) |
| J2 at H | (0, -1, 0) | (0, -1, 0) |
| J3 at K | (0, +1, 0) | (0, +1, 0) |

These are positive-angle arrows, not merely unsigned shaft directions.
For nonzero angles, use the rotated axes and centre equations in KIN-001.
The numerical candidate simply substitutes a = 75, b = 55, h = u = w = 0,
d = 25, Lu = 70, and Ll = 85 into that existing contract.

## Derived dimensions and drawing interpretation

| Relationship | Value | Interpretation |
| --- | ---: | --- |
| Chassis bounds | x = +/-90; y = +/-55 | Nominal planform only |
| J1 rectangle | 150 x 110 | Root-centre spacing |
| End inset | 15 | 90 - 75, at both ends |
| J1-to-J2 centre separation | 25 | Outward, at zero abduction |
| Left/right pitch-plane spacing | 160 | 2 x (55 + 25), at zero abduction |
| J2/J3/foot outboard distance | 25 | Beyond the body side in the zero reference |
| Upper centre distance | 70 | H to K |
| Lower centre-to-contact distance | 85 | K to P |
| Straight H-to-P reference distance | 155 | 70 + 85; not a stance height |

The top view shows the body planform and all four legs. H, K, and P overlap
in that projection. The front view looks rearward along -x; rear-leg centres
overlap the corresponding front-leg centres there. The left-side reference
view looks along -y and shows FL only; O and H overlap in that projection.
Colours distinguish the offset carrier, upper link, and lower link.
Dimensional labels govern; SVG zoom or paper scaling does not set dimensions.
Datum and dimension lines are not chassis solids or a ground surface.

The reference foot rectangle is 150 x 160. This is not a selected support
polygon, overall moving envelope, or complete robot width. Physical parts
extend beyond their centre-lines, and a later bent pose changes foot positions.

## Verification and unresolved work

Run `python mechanical/check_leg_frames.py` and
`python mechanical/check_leg_skeleton.py` with Python 3. Both checks use only
the standard library. The second reads the candidate JSON and SVG, uses
KIN-001's matrix chain, independently checks the selected distances and
planform relationships, and checks the drawing's centre markers, link
endpoints, dimension-line lengths, and numeric labels. Perturbation samples
test candidate symmetry away from zero; they do not select joint ranges.

The SVG is a schematic skeleton. It does not prove servo/bracket fit, moving
clearance, bearing support, printability, fastener access, strength, mass,
torque adequacy, or allowable servo travel. MG90S remains a candidate only.
The numeric candidate must be revisited if packaging or actuator feasibility
requires it; changes should propagate through JSON, documentation, SVG,
checks, and the decision record.

KIN-003 now supplies a [nominal standing pose](standing-pose.md) for this
unchanged skeleton, including checked foot/knee coordinates and stance
dimensions. The zero-angle reference in this document remains unchanged.
Joint-range/workspace analysis and servo torque validation remain later tasks.
