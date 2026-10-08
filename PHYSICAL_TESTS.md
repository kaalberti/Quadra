# Physical tests to do

No servos or mechanical hardware have been ordered. Development may continue with
provisional parts; revise CAD and calibration after actual parts are chosen.
Available: Creality K2 Pro printing access, adjustable60V/5A bench supply,
multimeter, basic load cells, ESP32-S3 N16R8 and Adafruit PCA9685 dev boards.
The supply's model/transient behavior and board header/revision remain unknown.

## Before buying a full set

Use the current MFG-003 / integrated-bench-1 manufacturing pack and its
assembly/printing guide. It includes the integrated hip, mirrored pitch forks,
mirrored knee saddle and five fit coupons. Bench-3 and earlier packs are
archived fallback references, not the current first-leg buying/print list.
Confirm actual servo ear/horn/lead orientation and free seating before
fastening. The optional electronics deck/carrier is working CAD outside this
single-leg release; dry fit actual boards, straps, connectors and jumpers
before adopting it. See docs/electronics-carrier.md.

1. **Servo identity and fit:** buy one positional MG996R with supplied horn and
   original centre screw. Measure case, mounting ears, shaft/horn height and
   horn bolt pattern. Print the five manufacturing fit coupons; check624
   bearing retention, M4 head recess and cradle fit. Record in
   mechanical/prototype-fit-record.json. Do not force a bearing into a tight print.
2. **Print and assembly:** use the K2 Pro for the prescribed flat orientations.
   PETG is the structural baseline; PLA may be used for fit coupons. Inspect
   layer bonding, bolt/nut access and support removal. Weigh printed parts.
   Assemble one unpowered leg and check alignment, cable slack and binding
   through the provisional ranges. Actual fit overrides nominal dimensions.
3. **Bench wiring:** verify polarity, common ground,3.3V logic/pullups, OE high
   at startup/reset and the physical cutoff. Set the supply near5.2V for
   MG996R testing, NOT its60V maximum. Begin with one secured, hornless servo
   and a modest current limit. Record electronics/bench-commissioning.json.
4. **Unloaded control:** check centre response with1450..1550us commands,
   disconnect/timeout behavior, rail voltage/current and heating. Measure PWM
   timing if possible before widening travel. Stop on current limiting/buzzing;
   diagnose rather than increasing current to overcome binding.
   A board-only timing check can precede servo arrival: see
   docs/board-pwm-timing-test.md. It uses3.3V channel15-to-GPIO7 loopback,
   no connected servos/servo rail, and does not establish motor-power behavior.
5. **Each joint's calibration:** establish mechanical reference, pulse direction,
   at least two measured angle/pulse points, and usable limits clear of stops,
   fasteners and cables. Centre before horn installation with power isolated
   for fitting. Record J1/J2/J3 separately; do not assume1500us means joint0deg.
6. **Supported one-leg load trial:** after fit/control checks, support the fixture
   and increase load gradually. Check small commanded motion, voltage droop,
   current, horn slip, printed-part flex and heating. Representative three-leg
   support at2kg is about6.5N per foot; avoid deliberate prolonged stalls.
   Determine whether usable torque/duty requires a lighter robot or different
   actuator before ordering12. Published stall torque is not continuous torque.
7. **Later integration:** check complete mass against2kg, chassis clearances,
   all-leg current and power distribution before supported standing. The5A
   bench supply is not assumed sufficient for three loaded joints or12 servos.
   Slow walking and IMU work follow stable hardware and calibrated joint control.
   Enter slicer/scale masses in mechanical/integrated-robot-mass-inputs.json. The current
   integrated working BOM's example is2.178kg, so actual print and power masses may
   change the robot design. Weigh fasteners and supplied horns/leads as well;
   do not infer printed mass from the infill percentage alone.

## Provisional servo choices

After actual first-leg calibration, use docs/measured-calibration-profiles.md
to validate a separate measured JSON record and preview mappings offline.
All current profiles remain unmeasured; exporting does not activate firmware
or approve wider powered travel.

Experimental MEC-161 forks: print one upper/lower pair side-on, inspect support
removal, bearing-seat fit, horn/retainer and saddle/foot assembly access. Gradually
load the assembled pair and inspect the web/plate junctions for flex or cracking.
These tests are NOT_PERFORMED; the flat-print coupons do not qualify this new
orientation. Use docs/tasks/MEC-161.md; wait for whole-leg clearance integration
before replacing the supported bench parts.
First use the smaller side-on coupon: mechanical/prototype-fork-fit-coupon.stl.
Print/support, bearing/retainer and actual horn fit are NOT_PERFORMED; procedure
is docs/fork-fit-coupon.md. The coupon does not qualify loaded strength.
Integrated MEC-164 hip: inspect removable supports under the raised output
plates, actual bearing/horn/retainer andJ2 mounting access, then gradually load
the assembled leg and inspect integral joints for cracks/flex. Print, fit and
load tests remain NOT_PERFORMED; source: mechanical/prototype-integrated-hip.scad.

- **MG996R:** all12 weight-bearing joints; three for the first leg. Current CAD
  already uses its size class. Manufacturer stall torque9.4kgf·cm at4.8V is
  approximately0.922Nm. Existing J1 neutral/knee estimates0.329/0.42Nm support
  prototyping, not sustained-duty approval. J1 at+30deg needs about0.694Nm,
  leaving limited stall margin: keep that position unpowered until load testing.
- **MG90S:** no weight-bearing leg joints in this2kg design. Its1.8kgf·cm at4.8V
  is approximately0.177Nm, below both estimates. It is also much smaller and
  would need different mounts. Reserve only for a future lightly loaded sensor
  pan/tilt if one is needed; do not buy any for the current leg.

Public sources: [MG996R](https://towerpro.com.tw/product/mg996r/) and
[MG90S](https://towerpro.com.tw/product/mg90s-3/). The MG90S page's voltage
wording is inconsistent; confirm the chosen version before using it on a
shared rail. No supplier contact or hardware test is implied by these sources.

## Optional voltage-input comparison

ELEC-008:electronics/voltage-perfboard.md gives the removable perfboard divider,
GPIO8 diagnostic and multimeter comparison sequence. Check the divider output
before connecting GPIO8; keep servo rail OFF. Compare source and ADC estimates
at known positive test voltages within0..25.2V and record actual error/spread.
Disconnect sense positive before ESP32 USB power. No always-connected battery
monitor, protection threshold or physical accuracy is established yet.
