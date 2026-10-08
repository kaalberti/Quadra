# Purchasing BOM — Rev A working plan (2026-10-09)

Bench-3 includes the rib-relieved adapter and mirrored carrier/saddle selection;
purchased quantities are unchanged.

Maintain this file when purchased parts or quantities change. This is a staged
shopping list, not a purchase order. Prices are planning caps, not verified
retail quotations. No purchases or new ownership are inferred. The user already
has a multimeter, adjustable60V/5A supply, basic load cells and access to a
Creality K2 Pro. ESP32-S3 N16R8 and Adafruit PCA9685 boards are owned;
no servos/mechanical hardware are ordered. Supply model remains unknown.

## Buy first for fit checks

| Part | Quantity | Specification / cost cap |
| --- | ---: | --- |
| Positional MG996R servo | 1 | Provisional40.7 x19.7 x42.9mm envelope; supplied horn and original centre screw; NZ$25–35 target. Avoid continuous-rotation variants. |
| Commodity624 bearing | 1 | 4mm bore x13mm OD x5mm width; NZ$3 allocation, not retail quote |
| PLA+ or PETG | As needed | Use existing filament; print coupons first |

Servo source: [TowerPro MG996R](https://towerpro.com.tw/product/mg996r/).
Bearing boundary source: [SKF624](https://www.skf.com/ro/products/rolling-bearings/ball-bearings/deep-groove-ball-bearings/productid-624-2RS1?failover=true).
These were checked in previous public-manufacturer tasks. Actual delivered price,
model, ear shape and horn fit are not locked. Test one before a quantity order.

## Current supported three-DOF bench leg

Counts include J1 and BOTH pitch joints, foot, guide and one bench adapter. They replace
previous upper-leg/bench-joint lists; do not add those lists again. Chassis parts
are excluded. Machine-readable roles: mechanical/three-dof-hardware.json.

| Purchased item | Total needed | Purpose |
| --- | ---: | --- |
| Positional servos, supplied horns/centre screws | 3 | Includes first fit-check servo |
| 624 bearings | 3 | Includes fit-check bearing; one per joint |
| M3 x40 through bolts | 4 | J1 and J2 case clamps |
| M3 x20 through bolts | 12 | J1 cradle/support/bench4, J2 cradle/support/carrier4, carrier end tabs4 |
| M3 x16 through bolts | 9 | Three retainers6, foot2, cable guide1 |
| M3 x12 through bolts | 4 | Knee mounting ears; check actual ear thickness |
| M3 x70 through bolts | 2 | Upper plate/saddle/knee rear support; replaces old x40 saddle bolts |
| M3 x90 through bolts | 4 | Two bridges; or four90mm M3 threaded rods with four extra head-side nuts |
| M3 nuts | 35 | Locking nuts where suitable;39 if using bridge rods |
| M3 ordinary flat washers | 69 | Small6mm OD at close base/saddle positions |
| M3 backing washer,12mm OD | 1 | Under upper-plate window for cable guide; replaces one ordinary washer |
| M4 x35 socket-head pivot screws | 3 | Verify heads fit7.5mm diameter x4.5mm depth recesses |
| M4 pivot locking nuts and washers | 3 each | Bearing inner-ring retention |
| M2 x10 horn through bolts and nuts | Up to12 each | Actual supplied horn pattern/thickness sets count and length |
| M2 washers | Up to24 | Check tips/nuts clear servo case |
| Inner-ring spacer stacks | 8mm,8mm,10mm,3mm,3mm,3mm | Printed parts supplied; commodity metal substitutes optional; check only inner-ring contact |
| Adhesive rubber/EVA pad | 1 | Cut18 x8 x1mm;1mm thickness gives85mm nominal contact radius |
| Small cable ties | 4 | Cable guide; leave slack through joint motion |

Allow NZ$25 for initial small-hardware packs, then verify delivered prices.
This is an allowance, not an itemized quote. Buy a few spare fasteners. Supplied
servo centre screws are NOT substituted with the horn through-bolt hardware.

## Bench-only purchases / reusable workshop items

| Item | Quantity | Specification |
| --- | ---: | --- |
| Rigid vertical board/bracket | 1 | Scrap material acceptable; fixture itself not supplied by CAD |
| M4 standoffs/spacers | 2 |40mm length, maximum10mm OD; keeps board behind rear-arm space |
| M4 anchor bolts | 2 | Example x70 for a12mm board; select length for actual board and nut engagement |
| M4 nuts and nut-side washers | 2 each | Anchor heads seat directly in recessed adapter pockets |

These are fixture parts, not multiplied into the robot BOM. The board face is
40mm behind the adapter's back face. Confirm bench anchoring and fork clearance
before any loading; this is not a powered-test stability approval.

## Proposed bench control purchases — verify existing hardware first

| Item | Quantity | Planning allowance NZ$ | Requirement |
|---|---:|---:|---|
| Adafruit PCA9685 breakout | 1 owned | 0 additional |3.3V logic/pullups, accessible OE; external servo distribution |
| SN74AHCT125N DIP buffer and passives | 1 set | 5 |0.1uF ceramic,220ohm/1kohm/10kohm resistors; see wiring |
| Copper wire, rated terminals, DC cutoff and fuse holder/fuses | 1 set | 20 |10A main path,2A branch minimum;18/22AWG proposed |
| ESP32-S3 N16R8 development board | 1 owned | 0 additional | Header mapping to verify |

NZ$25 remaining bench-control allowance excludes the two owned boards;
this is a planning allocation, not a price quote or purchase commitment.
These items sit inside the existing other-parts budget. The multimeter and
bench supply are already owned; supply is rated5A and is for staged testing.
MG996R is the provisional choice for all12 leg joints; MG90S is not suitable
for these weight-bearing joints and adds no current purchase requirement.
Buy no battery, twelve-servo regulator or custom PCB at this stage.

## Planned robot quantities — wait before buying totals

| Item | One3-DOF leg | Four-leg robot | Status |
| --- | ---: | ---: | --- |
| Positional servos with horns | 3 | 12 | Architecture count; model/performance provisional |
| Passive support bearings | 3 | 12 planned |624 currently used; J1 bench package exists; chassis fit unfinished |
| Remaining fasteners, inserts, feet | TBD | TBD | Update as J1/chassis are designed; do not multiply bench kit by12 |
| ESP32-S3 N16R8 and Adafruit PCA9685 | Owned | Owned | No additional controller/PWM purchase planned |
| Battery, power distribution, BEC/regulator, cables | TBD | TBD | Robot electrical stage deferred; bench harness defined separately |

Servo cap:3 x NZ$25–35 = NZ$75–105 per leg;12 x NZ$25–35 = NZ$300–420.
The existing allocation remains NZ$300 for other parts plus NZ$80 reserve,
NZ$680–800 overall. Bearing/fixture allowances sit inside other parts, not
added twice. Verify shipping/tax and actual prices before purchasing. Preferred
budget NZ$500–800 and ceiling NZ$1,000 are unchanged.

User increased maximum COMPLETE operating mass to2kg on2026-10-08, including
battery/electronics. Twelve55g servos leave1340g for everything else. Historic
1.2kg calculations remain historical; new knee screen uses2kg. Actual whole
robot mass remains unknown. Never power servos through the ESP32 board.

Four-leg placement study: `mechanical/prototype-four-leg-study.scad`.
The raised deck and board blocks are placeholders; chassis brackets and mirrored
print variants are not released. No new purchases or chassis fastener counts
are established by MEC-155. Bench fixtures are not four-leg chassis components.

## Working chassis attachment — MEC-156, not yet a released robot kit

Print two left/two right chassis mounts and one deck from the working CAD.
Existing joint hardware stays with each leg; the bracket replaces the bench
adapter and reuses its four M3 x20 mounting bolts. Do not buy bench anchors
or standoffs for the robot. Actual mirrored leg parts remain under review.

| Added purchased item | One mount | Complete four-mount chassis |
| --- | ---: | ---: |
| M3 x16 through bolts | 4 | 16 |
| M3 nuts | 4 | 16 |
| M3 flat washers | 8 | 32 |

These quantities are additional deck fixings, not replacements for the bench
leg BOM. Use existing packs where possible; retail price remains unverified,
with no change to the approved overall budget. Guide: docs/prototype-chassis-attachment.md.

## Four-leg working hardware totals — MEC-158, wait for physical fit

These are complete totals, including the16 deck fixings above; do not add them
again. Bench adapters, board anchors and standoffs are excluded. Printed
quantities/handed assignments: docs/four-leg-working-assembly.md and
mechanical/four-leg-working-print-manifest.json. No new actuator or board selection.

| Purchased item | Complete working robot quantity |
| --- | ---: |
| MG996R positional servos with horns/original centre screws | 12 provisional |
| 624 bearings | 12 |
| M3 x40 / x20 / x16 / x12 / x70 / x90 bolts | 16 /48 /52 /16 /8 /16 |
| M3 nuts | 156;172 if bridge rods replace bolts |
| M3 ordinary washers /12mm backing washers | 308 /4 |
| M4 x35 pivots / locknuts / washers | 12 each |
| M2 x10 horn bolts / nuts / washers | Up to48 /48 /96; actual horn sets count |
| Rubber/EVA foot pads | 4,18 x8 x1mm assumed |
| Small cable ties | 16 |

Verify one servo and printed leg first. Battery, full-robot regulator/current
capacity, board attachments and measured mass are still unresolved. Existing
controller boards need no replacements. Cost targets remain unchanged.

MEC-160 mass screen: the current full working BOM estimates2.360kg with explicit
print/power assumptions, exceeding the2kg limit by about360g. Actual mass is
unmeasured. Do not treat these complete quantities as a ready-to-buy robot kit;
the supported single-leg kit remains the first purchase/test. Mass record and
next simplification: docs/working-robot-mass.md. No premium actuator is selected.

Experimental integrated-leg variant: eight pitch forks and four integrated
hips replace36 separate prints with12. Conditional robot totals are93 prints,
zero M3x90 bolts,32 M3x20 bolts,124 M3 nuts and244 ordinary M3 washers.
Other complete quantities above remain unchanged. Combined estimated savings
are181g under the same mass-screen assumptions, leaving2.178kg, still above2kg.
Actual mass is unmeasured. Both print hands and sampled one-leg clearances pass;
all12 new four-leg placements and60 nominal chassis pairs now pass.
Physical print/load tests remain open.
The experimental bench leg uses23 prints,27 M3 bolts/nuts and53 ordinary
M3 washers plus one backing washer. Compared with the supported bench kit,
omit four M3x90 and four M3x20 bolts, eight nuts and16 ordinary washers.
Keep the supported bench kit as the current purchase/test reference; do not
buy conditional complete robot quantities yet. Details: docs/tasks/MEC-164.md.

MEC-165 confirms21 unique STLs/93 pieces in
mechanical/integrated-four-leg-print-manifest.json. The source-bound variant
mass record is mechanical/integrated-robot-mass-inputs.json; its report remains
NOT_MEASURED. Assembly/measurement guide: docs/integrated-four-leg-working-assembly.md.
