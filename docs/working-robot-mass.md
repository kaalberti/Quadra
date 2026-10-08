# Working robot mass screen — MEC-160

The current bench-derived four-leg plan is likely too heavy for the2kg limit.
Its example estimate is2.360kg, about360g over the limit. This is a planning
screen, not a measured robot mass or an instruction to increase the mass limit.
The supported single-leg manufacturing kit remains useful for proving the joints.

| Component | Screen mass |
| --- | ---: |
| Printed parts at assumed65% of solid CAD volume | 846g |
| Twelve MG996R servos | 660g |
| Steel fasteners, nuts and washers | 484g estimated |
| Twelve624 bearings | 40g reference |
| Battery | 150g provisional allowance |
| Electronics and power modules | 100g provisional allowance |
| Additional distribution wiring | 60g provisional allowance |
| Horns, feet and cable ties | 20g provisional allowance |
| Total | 2360g estimated |

The117 printed pieces have1302g of solid PETG CAD volume.65% is a material-use
example; it is **not** a65% infill setting. Thin plates and walls may use a much
higher fraction of solid volume. No slicer mass or actual print weight is known.
Under the other allowances, all prints together have about486g available,
only37.4% of solid CAD mass. That is a tight target for these parts; do not
assume changing infill alone solves it. Power hardware is not selected.

## Evidence and assumptions

[TowerPro](https://towerpro.com.tw/product/mg996r/) lists55g for MG996R;
actual delivered versions and the exact included lead/horn mass need weighing.
[SKF's624-2RS1 reference](https://www.skf.com/ro/products/rolling-bearings/ball-bearings/deep-groove-ball-bearings/productid-624-2RS1?failover=true)
lists3.3g. This does not select that bearing brand for purchase.
[Accu's M3x40 datasheet](https://www.accu.co.uk/api/product-datasheet?id=659829)
lists a5.5mm diameter/3mm high head and236g per100 screws. The rough steel
envelope model gives2.369g per screw, close to that2.36g reference. Other
lengths, partial threads, nut inserts and washer sizes remain estimates.

The hardware count comes from four copies of the active leg hardware roles
plus16 deck bolts, counted once. Bench adapters/anchors/standoffs are excluded.
The maximum48 horn bolts are included. Fastener geometry assumptions are recorded
in mechanical/robot-working-mass-check.json;7mm OD ordinary washers conservatively
screen mass, while some close locations require6mm washers for actual fit.
Servo lead mass is assumed within the published servo weight; the separate
wiring allowance covers additional robot distribution. Horn allowance may
overlap supplied contents and is intentionally provisional.

## What changes the decision

Use `mechanical/robot-mass-inputs.json` for later slicer/scale inputs. Each STL
has optional per-unit sliced and measured grams; measured values take priority.
Replace battery, electronics/power, distribution wiring and supplied hardware
allowances with actual weights when those parts are chosen. A complete operating
robot scale measurement is kept separately; null means unmeasured.

`node mechanical/check-robot-working-mass.mjs` verifies STL hashes/quantities,
computes volumes and the mass budget, and writes the report. Three independent
existing CAD-volume reports provide spot checks, and the M3x40 published weight
checks the fastener model. Actual records remain NOT_MEASURED.

The next robot-specific design unit should simplify the pitch output forks:
replace separate bridge/rear/front structures and long coupling bolts with a
conservative integrated print, retaining the bearing/horn/link interfaces. That
reduces parts, purchased fasteners and weight together. Keep the bench kit intact
for the first physical leg trial; this screen does not justify detailed stress
analysis, premium actuators or general structural optimization. A fork change
alone is not claimed to recover the entire360g excess.
