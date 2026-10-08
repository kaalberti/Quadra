# Removable chassis attachment — MEC-156

Working CAD: `mechanical/prototype-chassis-assembly.scad` and
`mechanical/prototype-chassis-mount.scad`. These are development outputs;
MFG-002 remains the single supported bench-leg release.

## Print and assemble

Print two `prototype-chassis-mount-left.stl`, two
`prototype-chassis-mount-right.stl`, and one `prototype-chassis-deck.stl`.
The mounts export flat on their large mounting plate,66 x59mm and33mm tall;
the deck exports flat,180 x110 x4mm. Start with PETG or PLA+,0.2mm layers,
four walls and ordinary prototype infill; inspect the slicer preview. No
support is intended for the mounts in the exported orientation. Actual print
fit and strength remain untested.

The left print serves front-left and rear-right; rotate180deg about body z
for the rear-right. The right print serves front-right and rear-left, again
rotating180deg for the rear-left. Handed leg components remain a separate
unreleased requirement; these brackets alone do not make a four-leg build kit.

Replace the bench adapter with the bracket's7mm mounting plate. Its contact
face sits at bench-frame x=-3mm, against the existing passive support base.
Four slotted3.5mm holes match y=-3.65/+24.35mm and z=+/-17.25mm. Reuse the
four M3 x20 cradle/support/adapter bolts for each leg; do not stack the bench
adapter behind the bracket. The22mm centre opening retains pivot access.

The6mm upper flange contacts the deck underside35mm above the J1 datum,
which keeps the existing155mm deck height. Each flange takes four M3 x16
through bolts, four nuts and eight ordinary washers. The deck has16 matching
holes. Assemble the fixed mount/support before installing the moving fork
if tool access is restricted. Remove motor power before assembly or service.

Nominal stacks excluding bolt head: reused joint mount3+3+7mm plus washers
and nut; deck joint6+4mm plus washers and nut. Verify actual nut/washer
thickness, thread engagement and protruding tips before tightening. Do not
let clamp torque crush the print or servo case. Servo cable relief remains
at the existing end of the cradle; actual leads/horns require physical checks.

## Validation and limits

`node mechanical/check-chassis-mount.mjs` reads all three working STLs.
It checks closed edges, connected surfaces, bed origin, dimensions, equal
mirror volumes and mesh-ray clearance through fixing holes on a3mm envelope.
Bounds remain inside a conservative300mm print area, without relying on an
unverified printer profile. The assembly preview is inspected separately.

Full nominal mount/leg intersection is checked with OpenSCAD mode
`mount-leg-collision`. The corrected nominal intersection is empty. Moving
travel, cables, real servo ears and wrench clearance remain physical prototype checks.
The printed bracket/deck mating face is intentional contact.
The initial bracket interfered with the passive-support ribs;0.2mm clearance
pockets now follow those existing ribs. The collision mode excludes only a
0.001mm layer at the intended support contact face.

Solid PETG estimates:31.5g per bracket and99.8g deck; four brackets plus deck
approximately225.9g. These are solid CAD volumes, not sliced or measured mass.
Keep the complete2kg limit and measure the actual assembly before choosing
robot power/battery hardware. No detailed structural optimization is warranted
until a supported physical trial identifies a problem.

Board blocks remain conservative unmeasured reservations for the owned ESP32
and PCA9685. Their attachment holes are not guessed. No battery mount, gait,
powered standing or manufacturing release is included.

The same rib check exposed127.65mm3 of interference with the older bench
adapter. That release needs a separate adapter correction before printing
its adapter. The fit coupons and unaffected leg parts remain useful.
