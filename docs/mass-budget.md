# TOR-009: provisional whole-robot mass allocation

2026-10-08. This is a top-down engineering budget, not a predicted or measured
robot mass. No actuator, battery or structure is selected. Actual TOR-003
inventory remains unknown. Public specifications constrain comparison; all
category targets and reserves below are explicit engineering allocations.

## Allocation and boundaries

| Category | Target (g) | Included exactly once / boundary |
| --- | ---: | --- |
| Twelve actuator assemblies | 360 | Actuator, integral lead, horn, horn screw, dedicated support bearing/shaft and mounting fasteners. Printed carriers belong to structure. |
| Printed structure | 240 | Chassis, hip carriers, upper/lower links, printed covers and battery tray; excludes all metal hardware and feet. |
| Battery assembly | 150 | Cells/pack, integral protection and factory lead/connector; strap/padding here, printed tray above. |
| Electronics, power and control | 90 | Controller, sensor, driver/interface, regulation, distribution and protection boards; heatsinks here. No particular architecture chosen. |
| Wiring/connectors | 60 | Additional harnesses, mating connectors, insulation and strain relief; excludes leads/connectors already counted with actuator or battery. |
| Shared hardware and feet | 100 | Inserts, shared bolts/nuts, chassis fasteners and passive foot material; excludes actuator-specific hardware above. |
| Allocated component subtotal | 1000 | Sum of six mutually exclusive categories. |
| Unassigned growth reserve | 150 | Planning allowance for unknowns; no physical mass or COM until spent. |
| Planning envelope | 1150 | Allocations plus reserve. |
| Gap to strict 1200 g limit | 50 | Additional unallocated separation; not a payload allowance. |

Rationale: reserve 150 g (15% of component subtotal) because structure and
power remain undefined. Keep a separate 50 g gap so using the reserve does
not land exactly on the forbidden 1200 g boundary. The 360 g actuator line
allows a 30 g average installed assembly; the remaining 640 g explicitly
allocates structure and support systems. The 240 g structure target may be
tracked initially as 80 g chassis/covers plus 40 g per leg; this subdivision
is provisional, not a printable design. Battery and electronics allowances
are placeholders, not evidence of adequate energy, current or cooling.

These choices organize design effort; no source demonstrates they are achievable.
Future CAD mass estimates, public part specifications and complete accounting
must substantiate each line. If a category cannot meet its target, revise the
budget explicitly instead of asserting feasibility from a balanced table.

## Actuator assembly ceiling and public comparisons

For a uniform allocation, 360/12 = 30 g per installed actuator assembly.
This is an average budgeting ceiling, not a requirement for identical servos:
4*(m_q1 + m_q2 + m_q3) <=360 g for a common three-joint leg design. A heavier
joint must be offset explicitly within the allocation or trigger rebudgeting.

| Candidate | Published unit (g) | Twelve units (g) | Assembly allowance left per unit (g) | Aggregate allowance left (g) |
| --- | ---: | ---: | ---: | ---: |
| HS-5085MG | 21.9 | 262.8 | 8.1 | 97.2 |
| XL330-M288-T | 18.0 | 216.0 | 12.0 | 144.0 |
| XC330-M288-T | 23.0 | 276.0 | 7.0 | 84.0 |

Public masses rechecked 2026-10-08: [Hitec manufacturer page](https://www.hitecrcd.co.kr/products/hs-5085mg/),
[ROBOTIS XL330 product page](https://www.robotis.com/shop/item.php?it_id=902-0163-000),
[ROBOTIS XC330 manual](https://emanual.robotis.com/docs/en/dxl/x/xc330-m288/).
TOR-004 records Hitec horn exclusion; ROBOTIS accessory inclusion remains to
be reconciled. Residual allowances are arithmetic capacity for missing assembly
items, not estimates of their actual mass. All three unit masses fit below
30 g, but complete assemblies have not been shown to fit. None is selected
or torque/thermal approved by this comparison.

## Reserve management and sensitivity

Unchanged non-actuator allocations total 640 g. Every 1 g increase in each
of twelve assemblies costs 12 g overall. At 35 g average, assemblies total
420 g: a 60 g overrun consumes reserve, leaving 90 g within the 1150 g planning
envelope. At 40 g average, 120 g is consumed and 30 g remains. These are
hypothetical stress cases, not approved new actuator allowances.

With all other allocations fixed, consuming the full 150 g reserve gives
(1150-640)/12 = 42.5 g average assembly mass and zero growth reserve. That is
not the normal target. The strict physical boundary would be
(1200-640)/12 = 46.666667 g, with actual average strictly less; equality fails.
Never spend both the same reserve and a category underspend twice.

Track transfers in a revised budget and decision record: increase a category
while decreasing available reserve by the same amount. If reserve is exhausted,
reduce another category or revise the design; do not silently relax the mass
requirement. Use unrounded totals for strict acceptance. Final measured mass
plus justified measurement uncertainty must stay below 1200 g; the 50 g gap
is not itself an uncertainty model.

Do not put reserve or these allocations into mass-inventory.json as measured
components. Allocated mass lacks placement/COM, so TOR-008 cannot turn this
budget into verified joint loads. Battery adequacy, structure strength,
attachment feasibility, actual COM and sustained actuator capability remain open.

## Validation and next task

Editable inputs: [mass-budget.json](../mechanical/mass-budget.json). Check sums,
strict inequality, category counts, per-unit limits, candidate remainders and
stress cases against the formulas above. Document checks and regression results
are recorded in STATUS.md. No mechanical geometry or real inventory changed.

Next bounded task: evaluate one explicit nominal actuator-body attachment
hypothesis (q1 body-fixed, q2 hip carrier, q3 upper link) using public candidate
masses and clearly bounded COM assumptions. Quantify nominal gravity effects
and mass accounting without treating the hypothesis as CAD or a final actuator
selection. This task is not executed here.
