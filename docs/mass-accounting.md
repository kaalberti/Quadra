# TOR-003: component mass and nominal gravity accounting

2026-10-08. The accounting model is implemented and testable; actual robot
mass and gravity corrections remain unknown. This is a servo torque validation
subtask, not an actuator selection or mechanical release.

## Editable inputs and use

[mass-inventory.json](../mechanical/mass-inventory.json) contains twelve actuator
placeholders, four leg remainder groups and one body remainder group. Every
mass is null. Actuator attachment is deliberately unknown: the actuated joint
name does not determine which link carries its body. Body-fixed remainder is
defined by its membership, not an assumption that all electronics must be there.

Run from the repository root:

```text
python -B mechanical/mass_accounting.py
python -B mechanical/mass_accounting.py path/to/another-inventory.json
python -B mechanical/check_mass_accounting.py
```

The default command prints a report without changing inputs. It reports null
total mass, null mass-target verdict, and null gravity corrections for all
joints. The zero known-mass subtotal means no mass has been entered; it is
not a robot mass estimate. Null never means zero mass or zero torque.

Each row has a unique physical instance/group ID, associated leg (or null),
attachment, mass in kg, local COM in mm, and evidence text. There is no hidden
quantity multiplier: enter four distinct leg instances, not one row counted
four times. Evidence should identify measurements or sources, date, included
hardware, uncertainty and any provisional bounds. The current calculator uses
point values only; recorded uncertainties are not automatically propagated.

Split remainder groups into disjoint rigidly attached components before
numeric use. Do not leave the parent aggregate alongside its children. Split
horns, output hardware and other moving portions from actuator-body mass when
they follow different links. Record whether published actuator mass includes
horns, screws or leads. Flexible wiring needs a stated mass partition and
nominal COM approximation; its drag is outside this gravity model.

Set coverage_complete true only after a human inventory audit establishes
that the complete operating assembly is represented exactly once. Unique-ID
validation catches repeated IDs, not the same screw hidden under two names.
The five remainder placeholders are coverage reminders, not verified BOMs.

## Attachment and local frames

Use the unchanged [KIN-001 frames](leg-frames.md) and
[KIN-003 nominal pose](standing-pose.md). COM coordinates are expressed in the
right-handed rotated frame below, not in a mirrored left-handed frame.

| attachment | COM origin | orientation in B | joints affected by its gravity |
| --- | --- | --- | --- |
| body | body datum origin | identity | none |
| hip_carrier | J1 root O | R_x(s*q1) | q1 |
| upper | hip-pitch H | R_x(s*q1) R_y(-q2) | q1, q2 |
| lower | knee K | R_x(s*q1) R_y(-q2) R_y(q3) | q1, q2, q3 |
| null | unresolved | unresolved | all joints on associated leg; all legs if leg also null |

Moving attachments require a leg ID. A body-fixed actuator may retain a leg
ID for inventory organization but contributes no local joint gravity moment.
For symmetric right-leg components, negate the local COM y coordinate while
retaining x and z. Rear geometry is translated, not reflected fore/aft. The
code does not silently mirror an entered COM. A COM on an axis may give zero
moment, but its mass must still be counted.

## Accounting and signed gravity correction

Total mass is the sum of all rows exactly once, including body-fixed masses.
The strict requirement is M < 1.2 kg; exactly 1.2 kg fails that comparison.
Unknown masses or incomplete coverage withhold both total and pass/fail.
Known mass with unknown COM can still establish total mass, but not affected
gravity moments. Unknown body-fixed COM does not affect leg gravity correction.

For component i attached downstream of joint j:

```text
C_i = origin_attachment + R_attachment * com_local_i
delta_tau_hold_j = -a_j dot ((C_i - J_j) cross (0,0,-m_i*g))
```

Convert mm to m before the cross product; g = 9.80665 m/s^2. Sum signed
corrections, not absolute values. This is balancing torque in geometric joint
signs, not servo command polarity. Gravity can oppose contact torque at one
joint and add demand at another.

For a complete mass distribution and compatible foot reactions, the nominal
static result would be TOR-001's signed contact torque plus these corrections.
The contact force balance must already include total mass M; do not add distal
weight to M again. This tool deliberately does not produce a combined sizing
verdict or solve contact reactions. A changed COM can invalidate an assumed
equal-load distribution; recheck whole-body equilibrium before combination.

Unknown attachment/mass/COM yields null for affected joints, with responsible
IDs listed in the report. Known non-downstream joints retain zero contribution.
Incomplete overall coverage withholds every summed correction because omitted
components may belong anywhere. Explicit zero-mass entries contribute zero
without needing a COM; use them only for a documented absent/ideal component.

## Independent validation

The synthetic lower-link midpoint fixture uses 0.1 kg, purely for testing.
At nominal stance its horizontal offset from H is half of
sqrt(70^2 - 50.3125^2) mm. Independent expected gravity corrections are
(m*g*0.025, m*g*knee_x/2, m*g*knee_x/2) Nm on all legs. The positive knee
correction opposes TOR-001's negative contact-balancing knee torque.

Tests also compare torque to d(m*g*z)/dq using central differences for all
four attachments on all four legs. They check total-mass counting, the strict
ceiling, additivity, mirror/rear mapping, unknown propagation, incomplete
coverage, duplicate IDs, malformed inputs and the unresolved real template.
Synthetic fixture values are not mass allowances or packaging choices.

## Limits and next task

This model assumes rigid serial attachments, level nominal body, gravity only
and unchanged geometry. It does not model cable forces, bearing friction,
remote/coupled transmissions, dynamics, thermal duty, physical fit or full
workspace loads. Mathematical checks do not establish physical feasibility.

Next bounded task: collect a small sourced actuator candidate evidence table
against TOR-002, prioritizing unit mass, travel, torque versus voltage and
available sustained-duty evidence. Identify missing data without selecting a
winner or treating stall ratings as continuous capability. This is not executed
here; real mass/COM population still needs component and placement evidence.
