# TOR-001: nominal static servo-torque assessment

**Do not approve MG90S direct drive for the 1.2 kg design ceiling with this
nominal geometry.** In the simplified vertical contact-load model, the knee
requires 0.143183 Nm with an equal four-foot share and 0.286367 Nm with a
half-weight share. The latter exceeds both cited MG90S stall figures, and
no sustainable holding rating has been established. This is a nominal-load
feasibility screen, not a workspace-wide load model or physical test.

The geometry, 120 mm nominal hip-datum height, pose, and angle ranges remain
unchanged. Inputs, sources, and calculations are recorded in
[static-torque-inputs.json](../mechanical/static-torque-inputs.json),
[static_torque.py](../mechanical/static_torque.py), and
[static-torque.json](../mechanical/static-torque.json).

## Assumptions and force balance

- Use M = 1.2 kg as the design ceiling, not a measured mass or a revision of
  the below-1.2 kg requirement. For the same pose and load shares, the model's
  contact torques scale linearly with actual total mass.
- Use g = 9.80665 m/s^2. Forces on each analysed foot are vertical upward,
  F = (0,0,Fz), with Fz = lambda*M*g. Ignore horizontal ground forces,
  acceleration, impact, joint friction, and bearing drag in this screen.
- Assume ideal direct drive, one servo per joint, ratio 1:1, efficiency 1.
  This enables a direct joint-versus-servo torque comparison; no transmission
  hardware has been selected, and losses do not improve this comparison.
- Treat moving links as massless and lump robot weight into the supported
  body for the base calculation. The real robot's 1.2 kg allowance includes
  all links, servos, battery, and hardware; the missing distribution matters.
  Contact-load-only torques are neither guaranteed upper nor lower bounds
  on the full gravity-loaded mechanism.
- The chassis is level at the KIN-003 pose. Equal four-foot sharing is an
  assumed symmetric case with a centered COM projection, not a consequence
  guaranteed by having four contacts. Unequal loading is possible even then.

Evaluate three independent load cases for a loaded leg:

| Case | lambda | Interpretation |
| --- | ---: | --- |
| quarter_weight | 1/4 | Assumed equal four-foot support |
| third_weight | 1/3 | Hypothetical equal three-foot share; requires suitable COM projection |
| half_weight | 1/2 | Redistribution sensitivity case; not proof of a stable two-foot gait |

Whole-body equilibrium additionally requires sum(Fz) = M*g,
sum(x_foot*Fz) = M*g*x_COM, and sum(y_foot*Fz) = M*g*y_COM for this
gravity-only, vertical-force case. An equal three-foot distribution balances
a COM projection at that triangle's centroid, not generally at the body
centre. For example, excluding FL puts the other three-foot centroid at
(-25,-26.667) mm in the body planform. With the COM still at (0,0), the
nominal diagonal FR/RL can instead each carry half the weight and RR zero;
this is a support-edge situation, not a stable gait approval. No real COM,
load distribution, or stability margin is selected here.

## Joint moments and sign convention

For each joint, take its KIN-001 signed unit axis a and reference origin J.
The external generalized moment from the foot reaction is
tau_contact = a dot ((P-J) cross F). The ideal balancing actuator moment is
tau_hold = -tau_contact. Position differences must be converted from mm to m.

At the nominal pose, the effective horizontal lever arms for vertical force
are 25 mm at J1, zero at J2, and 48.668802572 mm at J3. Hence on all legs:

```text
tau_hold_q1 = -0.025 * Fz                  Nm
tau_hold_q2 = 0                           Nm, contact contribution only
tau_hold_q3 = -0.048668802572 * Fz         Nm

1 kgf.cm = 0.0980665 Nm
```

The signs are relative to the geometric q axes, not servo command polarity.
Mirrored legs have the same generalized torque signs because the J1 signed
axis reverses with the side. Magnitudes below use the full-precision pose.

| Case | Fz (N) | Hip abduction (Nm) | Hip pitch (Nm) | Knee (Nm) |
| --- | ---: | ---: | ---: | ---: |
| quarter_weight | 2.941995 | 0.073550 | 0.000000 | 0.143183 |
| third_weight | 3.922660 | 0.098067 | 0.000000 | 0.190911 |
| half_weight | 5.883990 | 0.147100 | 0.000000 | 0.286367 |

| Case | Hip abduction (kgf.cm) | Hip pitch (kgf.cm) | Knee (kgf.cm) |
| --- | ---: | ---: | ---: |
| quarter_weight | 0.750000 | 0.000000 | 1.460064 |
| third_weight | 1.000000 | 0.000000 | 1.946752 |
| half_weight | 1.500000 | 0.000000 | 2.920128 |

The hip-pitch zero occurs only because the ideal foot reaction passes
directly below H. That joint still carries structural force. Moving-link
gravity, horizontal force, pose changes, and acceleration give nonzero
torque, so this zero is not permission to omit or undersize that actuator.

## Sourced MG90S comparison

The [Tower Pro Hong Kong MG90S product page](https://torqpro.com/product/mg90s/)
lists stall torque of 1.8 kgf.cm at 4.8 V and 2.2 kgf.cm at 6.6 V; its
separate operating-voltage field states 4.8 V. The
[Tower Pro branded sheet hosted by Electronilab](https://electronilab.co/wp-content/uploads/2015/06/MG90S_Tower-Pro.pdf)
lists 1.8 kgf.cm at 4.8 V and 2.2 kgf.cm at 6.0 V, with a 4.8-6.0 V operating
range. Sources checked 2026-10-07.

Use the shared **1.8 kgf.cm = 0.1765197 Nm** rating as the 4.8 V baseline.
Also compare **2.2 kgf.cm = 0.2157463 Nm** as an optimistic published stall
figure only. The higher-rating voltage is inconsistent across the sources;
do not infer that 6.6 V is an approved operating choice for the actual unit.
This task selects no supply voltage. Neither cited source provides a
continuous holding-torque versus temperature/duty specification sufficient
to validate prolonged robot support.

| Case | Knee / 1.8 kgf.cm stall | Knee / 2.2 kgf.cm stall |
| --- | ---: | ---: |
| quarter_weight | 81.1% | 66.4% |
| third_weight | 108.2% | 88.5% |
| half_weight | 162.2% | 132.7% |

Four-foot knee demand is below both published stall figures, but this alone
does not establish a sustainable stance. The hypothetical third-weight knee
case exceeds the 4.8 V rating, and the half-weight knee case exceeds both
ratings even before considering losses or changes of pose. Hip-abduction
demands are below both stall figures in these three cases, but their
continuous-duty suitability is also unproven. Stall torque is not a valid
continuous holding specification; no universal fraction of stall torque is
substituted for missing thermal or duty data here.

## Missing moving-mass terms

For the actual mechanism, each joint must also balance gravity on every
component distal to that joint, including applicable servo bodies and feet:

```text
tau_hold_j = -a_j dot [ (P-J_j) cross F
                       + sum_i ((C_i-J_j) cross (0,0,-m_i*g)) ]
```

Only masses downstream of the joint enter its sum. C_i is that component's
COM in the body frame; actuator location is not yet fixed. Total mass M in
the contact-force balance already includes these masses: do not add their
weight to M a second time when adding their local gravity moments.

Gravity contributions can oppose the contact moment. For example, a mass
on the lower link between K and P has its COM behind K at this pose; its
weight reduces the magnitude of the knee's negative contact-balancing
torque. A mass forward of H adds positive hip-pitch holding torque, which
the contact-only table cannot show. Thus omission of these terms is not a
uniform conservatism assumption and not a complete actuator sizing result.
No link-mass values or favourable cancellation are invented to approve MG90S.

Required information for a full assessment remains: component masses and
COMs, servo placement, actual load sharing, contact-force directions,
transmission efficiency, allowable support duration/duty, and measured or
substantiated continuous torque/temperature capability. Dynamic and
workspace-wide loads are outside this task.

## Decision and next task

MG90S is **not a credible approved direct-drive baseline at the 1.2 kg
ceiling for this pose with load redistribution**. A short, lightly loaded
demonstration might behave differently; it is not validated here. A lower
actual mass, changed geometry, reduction drive, or different actuator could
change feasibility, but none is selected in this task. This conclusion
applies to the cited MG90S, not all servos of the same physical size.

Retain MG90S as the historical packaging candidate only. Its adequacy is
not approved, and detailed bracket dimensions should not be committed around
it. Keep the current skeleton as an analysis reference pending actuator
feasibility resolution.

Regenerate with `python -B mechanical/static_torque.py --write`; validate
with `python -B mechanical/check_static_torque.py`. Independent checks use
lever arms, SI/kgf.cm conversion, all-leg symmetry, finite-difference virtual
work, source freshness, and comparison arithmetic. No hardware test was run.

Next bounded task: define an actuator performance-requirements brief from
the assessed nominal load cases, stating what duty, load allowance, and
mass-distribution evidence is needed before comparing replacements. Do not
select replacement servos or start detailed mechanical CAD in that task.
