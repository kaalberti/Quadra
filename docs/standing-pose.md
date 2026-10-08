# KIN-003: nominal standing-pose candidate

Adopt a **120 mm body-datum height** with all four feet directly below their
hip-pitch centres and zero hip abduction. With the unchanged 70/85 mm links,
every leg uses q1 = 0 degrees, q2 = 44.048625674 degrees, and
q3 = 78.978550364 degrees under the [KIN-001 conventions](leg-frames.md).
These are geometric angles, not servo commands.

This pose is geometrically checked, not proven physically supportable.
The [pose data](../mechanical/standing-pose.json) references the unchanged
[KIN-002 skeleton](../mechanical/leg-skeleton.json). See the editable
[dimensioned pose drawing](../mechanical/standing-pose.svg).

## Assumptions and choice

- The body is level and all four ideal point contacts lie on one horizontal
  plane. There is no foot deformation in this ideal model.
- Body axes remain +x forward, +y left, +z up. Place the ground-frame origin
  directly below B, with axes parallel to B. Thus p_ground = p_body +
  (0,0,120) mm, and the ground plane is z_body = -120 mm.
- The body datum is the J1/J2 axis plane, not the chassis underside. Body
  thickness, foot shape, and resulting physical ground clearance remain unknown.
- Preserve all KIN-002 dimensions, including the 25 mm outward hip offset.
  Zero abduction keeps the pitch planes vertical; feet directly below H
  give a simple common pose across all legs without a fore/aft foot bias.
- Choose 120 mm as an initial moderate crouch: it is 35 mm shorter than the
  155 mm straight reference and avoids the straight-leg singularity. This
  difference is geometric shortening, not verified usable motion reserve.
  The choice is not a torque, energy, stability, or packaging optimum.
- Select the forward-knee branch on all four legs, preserving the established
  common front/rear convention. No joint limits or actuator travel are selected.

## One-pose derivation

Let Lu = 70, Ll = 85, and D = 120 mm. Relative to the hip-pitch centre H,
the desired foot vector is (0,0,-D). At q1 = 0:

```text
0  = Lu*sin(q2) + Ll*sin(q2 - q3)
-D = -Lu*cos(q2) - Ll*cos(q2 - q3)

cos(q3) = (D^2 - Lu^2 - Ll^2) / (2*Lu*Ll)
q3 = acos((120^2 - 70^2 - 85^2) / (2*70*85))
q2 = atan2(Ll*sin(q3), Lu + Ll*cos(q3))
```

The acos branch is 0 < q3 < 180 degrees, giving a forward knee here.
The upper link leans 44.048626 degrees forward of vertical-down; the lower
link leans 34.929925 degrees backward, since q2 - q3 = -34.929925 degrees.
The internal triangle angle at the knee is 101.021450 degrees, distinct
from the 78.978550-degree flexion coordinate.

An independent triangle intersection checks the knee position without using
the forward-chain implementation. Let (Xk,0,Zk) be K relative to H:

```text
Xk^2 + Zk^2       = Lu^2
Xk^2 + (Zk+D)^2   = Ll^2
Zk = (Ll^2 - Lu^2 - D^2) / (2*D) = -50.3125 mm
Xk = +sqrt(Lu^2 - Zk^2) = 48.668802572 mm
```

The positive root selects the forward knee. The pitch-chain determinant
magnitude is Lu*Ll*abs(sin(q3)), which is nonzero here; this establishes
that this one pitch configuration is not straight/folded singular. It does
not define a workspace or prove good behaviour at other joint angles.

## Body-frame coordinates

All positions below are mm, rounded to six decimals where needed.

| Leg | O / J1 | H / J2 | K / J3 | P / foot |
| --- | --- | --- | --- | --- |
| FL | (75, 55, 0) | (75, 80, 0) | (123.668803, 80, -50.3125) | (75, 80, -120) |
| FR | (75, -55, 0) | (75, -80, 0) | (123.668803, -80, -50.3125) | (75, -80, -120) |
| RL | (-75, 55, 0) | (-75, 80, 0) | (-26.331197, 80, -50.3125) | (-75, 80, -120) |
| RR | (-75, -55, 0) | (-75, -80, 0) | (-26.331197, -80, -50.3125) | (-75, -80, -120) |

Ground-frame coordinates add 120 to every z: hips lie at z_ground = 120,
knees at 69.6875, and feet at 0 mm. Joint axes are unchanged from the
zero-abduction directions: J1 is +x on left legs and -x on right legs,
J2 is -y, and J3 is +y. Hip/knee pitch do not change the y-axis directions.

## Stance dimensions and interpretation

| Dimension | Value |
| --- | ---: |
| Body datum / hip-plane height above ideal ground | 120 mm |
| Foot-centre spacing, front to rear | 150 mm |
| Foot-centre spacing, left to right | 160 mm |
| Knee forward displacement from its hip-pitch centre | 48.668803 mm |
| Knee height above ideal ground | 69.6875 mm |
| Upper link reference length | 70 mm |
| Lower link reference length | 85 mm |

The front knees reach x = 123.668803, or 33.668803 mm beyond the nominal
chassis front at x = 90. Their centre-lines remain at y = +/-80, 25 mm
outside the chassis side boundaries. This is a packaging consequence to
carry forward; it is not a collision-clearance result. Rear knees point
forward too, as required by the existing mapping.

Four coplanar feet form a 150 x 160 mm contact rectangle. For gravity-only
static support, the centre-of-mass projection would need to lie within this
rectangle, with suitable contact forces and actuator capability. No COM
position, load distribution, stability margin, or walking stability is
established here. In particular, four contacts do not imply equal loads.

The side view looks along -y, so +x points left on the page. It shows FL
only; O and H overlap in projection. The top view shows feet and the body
planform only, not the complete leg envelope. SVG view scales differ and
dimension labels govern. The KIN-002 straight reference drawing remains
unchanged and is still useful for its separate dimensional purpose.

## Verification and limitations

Run `python -B mechanical/check_standing_pose.py`. It checks the selected
angles against the one-pose derivation, triangle-intersection knee geometry,
forward-chain closure, all four link lengths, ground-frame transformation,
left/right reflection, rear translation, foot rectangle, documentation,
and SVG geometry/labels. JSON coordinate tolerance is 0.000001 mm to allow
decimal rounding; this is a numerical check tolerance, not manufacturing accuracy.

Joint stops, available servo rotation, interference, structural deflection,
actuator holding torque, physical ground clearance, and stability remain
unverified. This pose is a geometric candidate for later analysis, not a
command to apply to assembled hardware.

KIN-004 now defines [candidate joint-angle ranges](joint-ranges.md) containing
this unchanged pose. They do not establish actual servo travel or physical
clearance. Workspace mapping, servo torque validation, and detailed
mechanical design remain separate tasks.
