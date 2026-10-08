# Purchasing BOM — Rev A, updated MEC-142 (2026-10-08)

Maintain this file when purchased parts or quantities change. This is a staged
shopping list, not a purchase order. Prices are planning caps, not verified
retail quotations. No purchases or new ownership are inferred. The user already
has a multimeter, digital power supply and basic load cells; specs are unverified.

## Buy first for fit checks

| Part | Quantity | Specification / cost cap |
| --- | ---: | --- |
| Positional metal-geared hobby servo, MG996R-sized candidate | 1 | Provisional40.7 x19.7 x42.9mm envelope; supplied horn and original centre screw; NZ$25–35 target. Avoid continuous-rotation variants. |
| Commodity624 bearing | 1 | 4mm bore x13mm OD x5mm width; NZ$3 allocation, not retail quote |
| PLA+ or PETG | As needed | Use existing filament; print coupons first |

Servo source: [TowerPro MG996R](https://towerpro.com.tw/product/mg996r/).
Bearing boundary source: [SKF624](https://www.skf.com/ro/products/rolling-bearings/ball-bearings/deep-groove-ball-bearings/productid-624-2RS1?failover=true).
These were checked in previous public-manufacturer tasks. Actual delivered price,
model, ear shape and horn fit are not locked. Test one before a quantity order.

## Current supported two-DOF pitch leg

Counts include BOTH pitch joints, foot, guide and bench adapter. They replace
previous upper-leg/bench-joint lists; do not add those lists again. J1 and chassis
are excluded. Machine-readable roles: bom-hardware.json.

| Purchased item | Total needed | Purpose |
| --- | ---: | --- |
| Positional servos, supplied horns/centre screws | 2 | Includes first fit-check servo |
| 624 bearings | 2 | Includes fit-check bearing; one per pitch joint |
| M3 x40 through bolts | 2 | Hip case clamp |
| M3 x20 through bolts | 4 | Hip cradle/support/7mm bench adapter; replaces old x16 base bolts |
| M3 x16 through bolts | 7 | Two retainers4, foot2, cable guide1 |
| M3 x12 through bolts | 4 | Knee mounting ears; check actual ear thickness |
| M3 x70 through bolts | 2 | Upper plate/saddle/knee rear support; replaces old x40 saddle bolts |
| M3 x90 through bolts | 4 | Two bridges; or four90mm M3 threaded rods with four extra head-side nuts |
| M3 nuts | 23 | Locking nuts where suitable;27 if using bridge rods |
| M3 ordinary flat washers | 45 | Small6mm OD at close base/saddle positions |
| M3 backing washer,12mm OD | 1 | Under upper-plate window for cable guide; replaces one ordinary washer |
| M4 x35 socket-head pivot screws | 2 | Verify heads fit7.5mm diameter x4.5mm depth recesses |
| M4 pivot locking nuts and washers | 2 each | Bearing inner-ring retention |
| M2 x10 horn through bolts and nuts | Up to8 each | Actual supplied horn pattern/thickness sets count and length |
| M2 washers | Up to16 | Check tips/nuts clear servo case |
| Inner-ring spacer stacks | 8mm,10mm,3mm,3mm | Printed parts supplied; commodity metal substitutes optional; check only inner-ring contact |
| Adhesive rubber/EVA pad | 1 | Cut18 x8 x1mm;1mm thickness gives85mm nominal contact radius |
| Small cable ties | 2 | Cable guide; leave slack through joint motion |

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

## Planned quantities — wait before buying totals

| Item | One3-DOF leg | Four-leg robot | Status |
| --- | ---: | ---: | --- |
| Positional servos with horns | 3 | 12 | Architecture count; model/performance provisional |
| Passive support bearings | 3 planned | 12 planned |624 currently used; J1 packaging unfinished |
| Remaining fasteners, inserts, feet | TBD | TBD | Update as J1/chassis are designed; do not multiply bench kit by12 |
| Battery, power distribution, BEC/regulator, controller/PWM, cables | TBD | TBD | Electrical stage deferred; check voltage/current/polarity before powered tests |

Servo cap:3 x NZ$25–35 = NZ$75–105 per leg;12 x NZ$25–35 = NZ$300–420.
The existing allocation remains NZ$300 for other parts plus NZ$80 reserve,
NZ$680–800 overall. Bearing/fixture allowances sit inside other parts, not
added twice. Verify shipping/tax and actual prices before purchasing. Preferred
budget NZ$500–800 and ceiling NZ$1,000 are unchanged.

User increased maximum COMPLETE operating mass to2kg on2026-10-08, including
battery/electronics. Twelve55g servos leave1340g for everything else. Historic
1.2kg calculations remain historical; new knee screen uses2kg. Actual whole
robot mass remains unknown. Never power servos through the ESP32 board.