# ST3215 four-leg chassis — working prototype

Assembly CAD: `mechanical/st3215-chassis.scad`; preview: `mechanical/st3215-chassis.png`.
This is an untested working layout, not a manufacturing release. Verify one servo
kit and first-leg fit before repeating the leg prints.

## Printed assembly

| Part | Quantity | Print envelope / purpose |
| --- | ---: | --- |
| st3215-chassis-body.stl | 1 | 175 x160 x42 mm; floor, end walls and hip reliefs |
| st3215-chassis-deck.stl | 1 | 140 x140 x4 mm; removable generic mounting deck |
| st3215-chassis-riser.stl | 4 | Diameter10 x51 mm; deck spacers |
| st3215-battery-tray.stl | 1 | Existing central padded battery holder |
| Current leg parts | 4 sets | Sixteen installed pieces per leg; see leg build guide |

Total71 installed printed pieces, including the tray. The two fit coupons are
alternative trial parts and are not added to this count. All three new STLs are
bed-oriented; inspect holes, thin features and local bridges in the slicer.
Use the existing PLA+/PETG prototype approach and at least four perimeters.
Actual material, infill mass and stiffness need the first print/load trial.

## Placement and mounting

Body frame: +x forward, +y left, +z up; z=0 is the hip shaft reference plane.
Hip origins: FL[115,50,0], FR[115,-50,0], RL[-115,50,0], RR[-115,-50,0] mm.
Front legs use the existing assembly orientation; rear legs rotate180 degrees
about z. There are no mirrored leg prints. The long hip carriers point away from
the central body. This reuses the current leg geometry at the cost of a long
footprint; nominal foot reference spacing is about400 x100 mm.

Bolt each existing J1 mounting plate to an end wall through its four fixture
holes:16 M3x20 bolts/nuts and32 washers provisionally. The wall and plate stack
is10 mm; check actual washer/nut engagement and protrusion. The34 mm hub relief
clears the rotating hip fork. Keep these reliefs and cable access open.

This layout does not establish servo calibration. Outward source-J1 sign is
FL+, FR-, RL-, RR+; rear rotations also affect body-to-leg coordinates.
Firmware must use the actual frames and measured joint directions/limits.

## Battery and removable deck

The tray bolts centrally to the floor with four M3x25 bolts/nuts and eight
washers provisionally. The bolts go through the11 mm tray side walls and5 mm
floor; heads/washers stay outside the pouch footprint. Verify no sharp hardware
contacts the cells. Add soft padding and the two existing15 mm battery straps.
Battery remains the provisional120 x50 x20 mm pack. Leads, connector, swelling,
actual dimensions and cell condition remain unverified.

The padded battery top is z=-19 mm; deck underside is z=8 mm, leaving27 mm
nominal clearance (26 mm above the modeled strap). Lead/connector routing can
use the open sides; bend radius and strain relief await the actual pack.
Remove the deck to release the battery straps. Remove/disconnect the battery
for charging and use an appropriate balance charger.

Four printed51 mm risers at x=+/-55,y=+/-60 mm support the deck. Use four
M3x70 through bolts/nuts and eight washers provisionally. The printed stack is
60 mm including floor and deck; verify actual thread engagement/protrusion.
Deck fasteners remain clear of the reserved module spaces.

Green65 x35 x20 mm, blue50 x35 x20 mm and orange120 x45 x25 mm blocks reserve
space for the ESP32, bus adapter and power/buck/fuse wiring respectively. These
are provisional allowances, not dimensional models or selected electronics.
Use insulating standoffs or secured perfboard/boards with the generic slots;
confirm real headers, USB connectors, switch access and tool clearance.
Keep the main motor-current distribution in rated wiring/connectors. The deck
and perfboard do not provide electrical protection. An accessible disconnect
and actual fuse/buck/harness selection remain separate pending work.

## Verification and limits

Run `node mechanical/verify-st3215-chassis.mjs` for a read-only check of current
source/report/STL identity. Run `node mechanical/check-st3215-chassis.mjs` to regenerate chassis STLs and
validate mesh connectivity, bed size and all fixture/deck/tray/riser bores.
Conservative component boxes exclude other body/leg and inter-leg collisions;
actual exported hip meshes then check the hub relief at source outward J1=0 and
5 degrees. These two poses do not release a swept or loaded motion range.

The geometric body centre lies within the nominal four-foot reference rectangle,
with50 mm lateral margin. This is not a measured centre of mass, three-leg
support margin or walking qualification. Weight shifting is needed before a
crawl; actual battery/servo/electronics mass must be measured.
Nominal floor-to-contact clearance is72 mm before fastener protrusions or pads.

Chassis/deck/risers have a combined solid-PETG estimate of about331 g at
1.24 g/cm3. This excludes the tray, legs, hardware and electronics, and differs
from actual sliced mass. Extra weight remains subject to loaded servo tests.
No FEA, dynamic gait, physical load test or powered operation was performed.
