# TOR-008: nominal gravity sensitivity

The coefficients below describe signed balancing gravity torque per kg at the
unchanged nominal pose. Reference points are mathematical probes, not selected
servo locations, real COMs or mass allocations. Actual inventory remains unknown.

## Results

| Reference ID | Attachment | Local COM for FL (mm) | q1 (Nm/kg) | q2 (Nm/kg) | q3 (Nm/kg) |
| --- | --- | --- | ---: | ---: | ---: |
| carrier_at_H | hip_carrier | (0,25,0) | 0.245166 | 0 | 0 |
| upper_at_H | upper | (0,0,0) | 0.245166 | 0 | 0 |
| upper_midpoint | upper | (0,0,-35) | 0.245166 | 0.238639 | 0 |
| upper_at_K | upper | (0,0,-70) | 0.245166 | 0.477278 | 0 |
| lower_at_K | lower | (0,0,0) | 0.245166 | 0.477278 | 0 |
| lower_midpoint | lower | (0,0,-42.5) | 0.245166 | 0.238639 | 0.238639 |
| lower_at_P | lower | (0,0,-85) | 0.245166 | 0 | 0.477278 |

Body-fixed mass contributes zero local joint gravity correction but still
changes total robot mass and potentially contact reactions. Right legs use
mirrored local y coordinates; rear legs translate without fore/aft reflection.
Frames and distal membership follow [TOR-003](mass-accounting.md).

For each downstream joint j, coefficient c_j =
-a_j dot ((C-J_j) cross (0,0,-g)), with positions in metres. At nominal pose,
q1 uses outward horizontal distance from O, q2 forward distance from H, and
q3 negative forward distance from K, each multiplied by g = 9.80665 m/s^2.
Independent triangle geometry gives knee forward distance
sqrt(70^2 - 50.3125^2) = 48.668802572 mm.

## COM sensitivity and use

The [generated JSON](../mechanical/gravity-sensitivity.json) includes gradients
in Nm/(kg mm). Its three outer gradient entries are local x, y, z columns;
each contains q1,q2,q3 derivatives. For a fixed attachment and pose,

    gravity_torque = mass_kg * (reference_coefficient + gradient * COM_offset_mm)

This is affine in COM and linear in mass, so the expression is exact within
the rigid gravity model, not just a small-displacement approximation. It says
nothing about collision or whether the displaced COM fits a real component.
For FL, a +1 mm local y shift adds 0.00980665 Nm/kg to q1. Upper local x/z
shifts change q2 by +0.00704853/-0.00681826 Nm/(kg mm). Lower local x/z
shifts change q2 by +0.00804001/+0.00561503 and q3 by the opposite amounts.
These local directions rotate with their attachments; they are not body x/z.

Use measured or publicly justified mass/placement bounds later. For example,
a purely illustrative 10 g at lower midpoint gives +0.00238639 Nm q2 and q3;
this is arithmetic, not an assumed robot part. The positive q3 correction can
oppose TOR-001's negative contact moment. Do not claim a torque benefit from
adding mass: contact forces, total mass and COM would change too. This analysis
holds contact reactions fixed and reports only local gravity sensitivity.

Reference priority: resolve pitch-joint attachment and forward COM distance,
and lateral offset for abduction. Midpoint assumptions are not automatically
valid for motors, brackets or irregular printed links. No combined load,
thermal capability, preferred mounting or actuator is established.

## Reproduction and verification

Run `python -B mechanical/gravity_sensitivity.py --write` to regenerate JSON.
Run `python -B -m unittest discover -s mechanical -p 'check_*.py'` for checks.
New tests use independent nominal lever arms and analytic rotation gradients,
then verify affine reconstruction, mass scaling, mirrored/rear mapping,
reproducible output and preservation of unknown actual masses.

## Evidence policy and next task

Per user instruction on 2026-10-08, use publicly available information and
explicit validated calculations; do not email suppliers. TOR-007 drafts are
historical only. Missing public thermal data remains an uncertainty, not an
expectation of supplier replies. No new product claim is made by this analysis.

Next bounded task: establish a provisional whole-robot mass allocation with
explicit reserves and a maximum actuator-assembly mass, using public candidate
mass data and clearly labeled engineering allocations for unknown structure.
Check feasibility against the strict 1.2 kg ceiling without selecting an
actuator or treating allocations as measurements. Not executed here.
