# Current integrated robot mass screen

The active93-piece integrated plan estimates2.178kg. This exceeds the preferred
2kg target by178g but is not automatically rejected:heavier operation is allowed
within physically demonstrated servo and power capability. Qualified maximum
mass is TBD. No whole-robot mass or load/current/duty result is measured.

| Component | Screen mass |
| --- | ---: |
| Printed parts at assumed65% of solid CAD |782g |
| Twelve MG996R servos |660g published reference |
| Fasteners,nuts,washers |367g estimated |
| Twelve624 bearings |40g reference |
| Battery |150g provisional allowance |
| Electronics/power modules |100g provisional allowance |
| Additional distribution wiring |60g provisional allowance |
| Horns,feet,ties |20g provisional allowance |
| Total |2178g estimated |

Solid PETG CAD prints total1203g. The65% material fraction is an example,not
an infill setting. Under the other allowances,604g of prints would meet the
preferred2kg target (50.2% of solid volume). This is target accounting,not a
requirement to thin prints or raise infill efficiency. Slicer/scale values and
actual selected power hardware supersede provisional estimates.

Active inputs:mechanical/integrated-robot-mass-inputs.json. Enter per-STL slicer
or measured unit grams and actual component weights; measured values take
priority. Whole-robot scale mass is separate. No measured fields are populated.
The new electronic mounts are working options outside this print/mass manifest;
account for whichever option is adopted later,without double counting.

Run `node mechanical/check-robot-working-mass.mjs --integrated`.
Reports separate preferred_target_g,qualified_limit_g,target margins and
qualified-limit margins. A null qualified limit means unknown capacity,not0g
or2kg. Even a measured robot below2kg remains capacity-unqualified without a
qualified limit. A future approved limit must come from actual servo/power
qualification at intended geometry,voltage,ranges and duty.

`node --test mechanical/mass-policy.test.mjs` checks these distinctions.
The default mass command retains the117-piece reference geometry and2.360kg
estimate,with the same revised policy semantics. It is not the current build.
Both commands verify STL hashes/quantities,volume spot checks and rough hardware
accounting. Source-bound active report:integrated-robot-mass-check.json.

MG996R mass/torque primary source:[TowerPro](https://towerpro.com.tw/product/mg996r/).
Bearing reference:[SKF624](https://www.skf.com/ro/products/rolling-bearings/ball-bearings/deep-groove-ball-bearings/productid-624-2RS1?failover=true).
Fastener estimate check:[Accu M3x40](https://www.accu.co.uk/api/product-datasheet?id=659829)
lists236g/100;the rough model gives2.369g each. These references do not lock
bearing/fastener brands or claim actual delivered weights. Servo leads are
assumed within published servo weight;horn/wiring allowances remain provisional.

Do not approve weight from stall torque alone. Decision and minimum load screen:
[operating mass](servo-qualified-mass.md). First supported leg and full robot
tests determine useful capacity; no premium servo purchase is implied.
