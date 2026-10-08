# KIN-005: ideal geometric foot workspace

The unchanged candidate geometry and angle ranges give the following
**continuous enclosing box relative to the front-left J1 root O**:

| Coordinate | Minimum (mm) | Maximum (mm) |
| --- | ---: | ---: |
| x, forward | -129.995 | 146.770 |
| y, robot-left | -41.862 | 97.984 |
| z, up | -154.701 | 38.555 |

The nominal foot is **(0,25,-120) mm** in this frame. These are marginal
coordinate extrema of the ideal reachable set, not a rectangular operating
region. The extrema generally occur at different angles. The box contains
many unreachable points and physically unsuitable configurations.

See [workspace projections](../mechanical/foot-workspace.svg), the
[machine-readable report and witnesses](../mechanical/foot-workspace.json),
and [reproducible source](../mechanical/foot_workspace.py).

## Model and scope

Use KIN-002's 70/85 mm links, 25 mm outward offset, and zero longitudinal/
vertical hip offsets. Use KIN-004's q1 = [-25,30], q2 = [-40,85], and
q3 = [20,130] degrees. The skeleton, ranges, nominal standing pose, and all
joint conventions remain unchanged.

The reference origin is O, not the body centre or moving hip-pitch centre H.
Its axes are parallel to the body: +x forward, +y left, +z up. For the left
leg the scalar forward geometry is:

```text
X = 70*sin(q2) + 85*sin(q2-q3)
Z = -70*cos(q2) - 85*cos(q2-q3)
x = X
y = 25*cos(q1) - Z*sin(q1)
z = 25*sin(q1) + Z*cos(q1)
```

Angles in these expressions are evaluated consistently in radians by the
code, with degrees used for input/output. This is the entire ideal foot
reach over the closed angle box, with no collision, ground, load, or actual
actuator-travel filtering. It is not a gait or a new operating-range decision.

## Continuous extrema and witnesses

| Coordinate bound | q1 (deg) | q2 (deg) | q3 (deg) |
| --- | ---: | ---: | ---: |
| x minimum | 0.000000 | -40.000000 | 50.000000 |
| x maximum | 0.000000 | 85.000000 | 20.000000 |
| y minimum | -25.000000 | 10.977595 | 20.000000 |
| y maximum | 30.000000 | 10.977595 | 20.000000 |
| z minimum | -9.299909 | 10.977595 | 20.000000 |
| z maximum | 30.000000 | -40.000000 | 130.000000 |

These values are obtained by analytic stationary-candidate enumeration,
evaluated with floating-point arithmetic. They are not inferred from sampled
extrema. The calculation checks rectangle corners, stationary points on
all four pitch-domain edges, and interior stationary points. On a fixed
edge, the objective is A*sin(t) + B*cos(t); stationary values satisfy
t = atan2(A,B) + n*pi within the edge interval. For interior pitch candidates,
the lower-link derivative and then the upper-link derivative must both vanish.

This produces the continuous extrema of X and pre-abduction Z. For each
q1, final y and z are affine in Z, so their extrema over the pitch domain
occur at one of those Z endpoints. The calculation then checks abduction
endpoints and all stationary abduction angles for each endpoint. This
exhausts the continuous coordinate-extremum candidates on the compact
domain; no numerical optimizer initialization or grid convergence is needed.
The source explicitly rejects nonzero u/w/h or an abduction interval outside
(-90,90) rather than silently extending its scoped model assumptions.

The reported decimals are numerical geometry, not manufacturing precision.
Witness coordinates and bounds are checked within 0.000001 mm against the
independent KIN-001 matrix chain. This tolerance allows floating-point
rounding and is not a statement about printed or servo positioning accuracy.

## Why the box is not the workspace

For this model, squared distance from O is invariant under abduction:

```text
norm(P - O)^2 = 25^2 + 70^2 + 85^2 + 2*70*85*cos(q3)
```

Hence any reachable point must lie between radii **71.420077 and 154.700815 mm**
from O. This spherical shell is only another necessary enclosure: the hip
and abduction limits still exclude much of it. For example, O itself lies
inside the coordinate box but cannot be reached; its radius is zero.
Likewise, combining the three coordinate extrema into a box corner does
not generally produce a reachable target. No wholly reachable Cartesian
sub-box or practical stepping region is selected in this task.

## Projections and sampling

The SVG shows XZ, YZ, and XY projections of **103,936** configurations on a
maximum 2-degree joint grid. Every lower and upper endpoint is included;
the last step may be smaller than 2 degrees. Each occupied projected 2 x 2 mm
cell contains at least one sample. Filling that cell does not prove every
point in it is reachable; empty cells do not prove continuous unreachability.
Cells may extend less than 2 mm beyond an exact marginal bound because of
binning. Red rectangles show the independently computed continuous bounds.

These are projections of all sampled configurations, not slices at a fixed
third coordinate or abduction angle. Apparent agreement in all three
projections does not establish that a particular 3D point is reachable.
The nominal foot is drawn in gold. The ground reference z = -120 mm appears
in XZ/YZ as a dashed grey line. Axes are coordinate plots, not camera views.

A separate 1-degree grid of **783,216** configurations is checked against
the continuous bounds. The 2-degree sampled extrema differ from continuous
extrema by at most about 0.0241 mm on this geometry, but that close agreement
is not the proof of the continuous bounds and not a spatial-resolution claim
for the entire projected set.

## Mapping to the body and other legs

For an FL-root point (x,y,z), the corresponding body point for any leg is:

```text
p_body = (f*75 + x, s*(55 + y), z)
f = +1 front, -1 rear
s = +1 left, -1 right
```

Thus right-leg local y bounds reverse sign and order; rear placement shifts
body x by -150 relative to the corresponding front leg. The body-frame boxes
are below, rounded to three decimals. All share z = [-154.701,38.555] mm.

| Leg | Body x minimum | Body x maximum | Body y minimum | Body y maximum |
| --- | ---: | ---: | ---: | ---: |
| FL | -54.995 | 221.770 | 13.138 | 152.984 |
| FR | -54.995 | 221.770 | -152.984 | -13.138 |
| RL | -204.995 | 71.770 | 13.138 | 152.984 |
| RR | -204.995 | 71.770 | -152.984 | -13.138 |

These remain per-leg marginal boxes, not a simultaneously attainable robot
envelope or valid multi-leg contact arrangement.

## Physical exclusions and next task

At the fixed nominal body height, z_body < -120 puts the foot below the
ideal ground. Such mathematical points cannot be used as unobstructed foot
positions on a rigid level floor. The set also includes z_body > 0 points
above the hip plane, and inward positions that may meet the body or other
parts. Removing points below ground alone would not establish link clearance,
usable stance reach, or actuator capability. No physical exclusion has been
applied to these plots or bounds.

Geometry near singular configurations, hardware travel, body/link/foot
volumes, structural loads, stability, and servo adequacy remain unverified.
The wide mathematical box must not be used as a walking command limit.

Regenerate with `python -B mechanical/foot_workspace.py --write`; validate
with `python -B mechanical/check_foot_workspace.py`. The JSON records hashes
of all three source contracts so stale results are detectable. The SVG is
an editable standalone artifact generated by the same source.

TOR-001 now provides a [nominal static torque screen](static-servo-torque.md)
for the unchanged pose and does not approve MG90S direct drive at the mass
ceiling. Workspace-wide load capability remains unverified. Actuator
requirements and feasibility must be resolved before detailed part design.
