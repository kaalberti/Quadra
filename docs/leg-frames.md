# KIN-001: leg coordinate and joint-axis contract

Status: mathematical convention checked. KIN-002 supplies candidate numeric
dimensions in [leg-skeleton.md](leg-skeleton.md); physical feasibility remains
unverified. Equations here remain parameterized.
Units: millimetres for position, radians in equations and the checker.
Illustrative angles in prose are degrees. All vectors are column vectors;
rotations are active right-hand rotations. Joint angles are geometric angles,
not servo command angles or pulse widths.

## Body and fixed leg frames

Body frame B has origin at the chassis planform centre on a designated
horizontal chassis datum plane. This plane is z = 0. KIN-002 chooses the
shared J1 plane as the datum; its placement relative to the chassis thickness
is deferred. It is not necessarily the centre of
mass, ground plane, or chassis underside.

- +x: robot forward.
- +y: robot left, looking forward.
- +z: up when the chassis is level.
- x cross y = z; positive body rotations follow the right-hand rule.

Define positive half-spacings a, b, and a signed common root height h.
The fixed root frame L of each leg has origin O = (f*a, s*b, h) in B and
orientation identical to B. Its y axis always points robot-left, even for
right legs. The front-left leg is the reference leg.

| Leg | f (front/rear) | s (left/right) | Root O in B |
| --- | --- | --- | --- |
| FL | +1 | +1 | (+a, +b, h) |
| FR | +1 | -1 | (+a, -b, h) |
| RL | -1 | +1 | (-a, +b, h) |
| RR | -1 | -1 | (-a, -b, h) |

This assumes symmetric root placement. Neither a nor b is automatically
half the 180 x 110 mm chassis envelope: mounting offsets are still open.

```text
Top view, +z toward viewer; schematic only

                  +x / forward
                       ^
        FL (+a,+b)      |      FR (+a,-b)
                       |
        +y / left <---- B
                       |
        RL (-a,+b)             RR (-a,-b)

        front/rear root spacing = 2a
        left/right root spacing = 2b
```

## Parameters and reference geometry

| Symbol | Meaning | Current value |
| --- | --- | --- |
| a, b | Positive root half-spacings | 75, 55 mm; KIN-002 candidate |
| h | Root height relative to chassis datum | 0 mm; KIN-002 datum choice |
| u | Forward offset from J1 root to J2 reference centre at zero abduction | 0 mm; KIN-002 candidate, signed parameter |
| d | Outward offset from J1 root to J2 reference centre at zero abduction | 25 mm; KIN-002 candidate, nonnegative parameter |
| w | Upward offset from J1 root to J2 reference centre at zero abduction | 0 mm; KIN-002 candidate, signed parameter |
| Lu | Upper link, J2 centre to J3 centre in the bending plane | 70 mm; KIN-002 candidate |
| Ll | Lower link, J3 centre to ideal foot contact in the bending plane | 85 mm; KIN-002 candidate |

The J1-to-J2 offset vector in the zero frame is t = (u, s*d, w).
Keeping u and w explicit allows later packaging to introduce longitudinal
or vertical offsets without silently changing the model. All three offsets
rotate with J1. The model assumes no additional lateral offset from J2 to
J3 or from J3 to the ideal foot. Any such offset requires a documented
revision. Axis reference centres locate the link skeleton; they do not yet
locate bearings, servo cases, or horns. In particular, d is not the shortest
distance between the infinite J1 and J2 axis lines.

## Angle zeros, frames, and axes

Let q1 be hip abduction, q2 hip pitch, and q3 knee flexion. At all angles
zero, both links point along -z and form a straight leg. This is a reference
configuration only, not a recommended stance or an accessible servo position.

Define the elementary right-hand rotations:

```text
Rx(theta) = [1, 0,          0         ]
            [0, cos(theta), -sin(theta)]
            [0, sin(theta),  cos(theta)]

Ry(theta) = [ cos(theta), 0, sin(theta)]
            [ 0,          1, 0         ]
            [-sin(theta), 0, cos(theta)]

R = Rx(s*q1)
U = R * Ry(-q2)
V = U * Ry(q3)

H = O + R * (u, s*d, w)       : J2 centre
K = H + U * (0, 0, -Lu)      : J3 centre
P = K + V * (0, 0, -Ll)      : ideal foot contact
```

| Frame | Origin in B | Orientation in B | Meaning |
| --- | --- | --- | --- |
| B | (0,0,0) | Identity | Chassis datum |
| L | O | Identity | Fixed leg root |
| A | O | R | Assembly after abduction |
| U-frame | H | U | Upper segment after hip pitch |
| V-frame | K | V | Lower segment after knee flexion |

Every orientation has orthonormal columns and determinant +1. These frames
are attached to ideal rigid links, not to servo housings. A foot-frame
orientation is unnecessary for an ideal point contact.

The signed axes below give positive q rotation by the right-hand rule.
Each infinite joint axis is origin + lambda * direction, for any real lambda.

| Joint | Origin in B | Signed unit direction in B | Positive motion near zero |
| --- | --- | --- | --- |
| J1, abduction | O | s * (1,0,0) | A point below J1 moves outward: left for FL/RL, right for FR/RR |
| J2, hip pitch | H | R * (0,-1,0) | Upper link swings forward |
| J3, knee flexion | K | U * (0,1,0) = R * (0,1,0) | Lower link bends backward relative to upper link |

Thus the hip-pitch and knee-pitch axes are parallel as unoriented lines,
but their positive-angle arrows are opposite. They remain perpendicular to
the abduction axis. Hip pitch does not change the knee-axis direction,
because rotating about y leaves y unchanged.

At q1 = 0, the upper link's forward lean from vertical-down is q2; the lower
link's forward lean is q2 - q3. Positive knee flexion reduces that lean.
This same convention is used for all four legs; the rear knee is not assigned
an opposite bend direction. Ranges and a physical knee-bend pose remain open.

For an independent scalar cross-check, with coordinates measured from O:

```text
X = u + Lu*sin(q2) + Ll*sin(q2-q3)
Y = s*d
Z = w - Lu*cos(q2) - Ll*cos(q2-q3)

P - O = (X,
         Y*cos(q1) - s*Z*sin(q1),
         s*Y*sin(q1) + Z*cos(q1))
```

These expressions exist to specify and verify the axes. They are not an
inverse-kinematics solver or an operational motion model with enforced limits.

## Mapping between legs

For identical parameters and identical q1/q2/q3:

1. Left to right: change s from +1 to -1. All skeleton points reflect across
   the body xz plane: (x,y,z) becomes (x,-y,z). Positive q1 still means outward.
2. Front to rear: change f from +1 to -1. All skeleton points translate by
   (-2a,0,0). Segment orientations and joint signs stay unchanged. This is
   placement at the rear, not reflection across the body yz plane.
3. Right rear combines both rules. No leg frame is defined as forward,
   outward, up: that would be left-handed on the right side.

Reflection is a mapping of geometry, not a rotation to use as a frame matrix.
With S = diag(1,-1,1), a reflected signed rotation axis transforms as
det(S)*S*axis = -S*axis, whereas points transform as S*point. This reproduces
the signed axes in the table without introducing a left-handed frame.
Servo mounting direction, horn index, zero calibration, and command polarity
remain separate later decisions.

## Verification and stage boundary

Run `python mechanical/check_leg_frames.py` using Python 3. The checker uses
only the standard library and writes no output files. It checks frame
handedness, orthogonality, axis relations, zero geometry, motion signs, rigid
link lengths, scalar/matrix agreement, reflection, rear translation, and
finite-difference foot motion against axis cross lever-arm geometry.

Fixture offsets and sampled angles are deliberately arbitrary numerical
inputs, not selected hip dimensions, joint limits, or a nominal pose.
The finite-difference check uses dP/dq = axis cross (P - joint origin),
with q in radians. This tests the declared joint origins as well as signs.

No collision, reachability envelope, torque, stability, or actuator travel
claim follows from these checks. KIN-002 supplies the candidate numeric
skeleton and dimensioned layout in leg-skeleton.md. Standing-pose,
workspace, torque, and detailed-part work remain separate tasks.
