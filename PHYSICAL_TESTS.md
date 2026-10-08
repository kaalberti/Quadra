# Physical tests to do

No servos or mechanical hardware have been ordered. Development may continue with
provisional parts; revise CAD and calibration after actual parts are chosen.
Available: Creality K2 Pro printing access, adjustable60V/5A bench supply,
multimeter, basic load cells, ESP32-S3 N16R8 and Adafruit PCA9685 dev boards.
The supply's model/transient behavior and board header/revision remain unknown.

## Before buying a full set

Use the corrected MFG-002 / three-dof-bench-3 adapter with support-rib pockets;
the older bench-1 adapter had a CAD clash and is archived. Confirm free seating
on the actual printed support before tightening. Working chassis mounts also have rib pockets.
Bench-3 also corrects carrier/saddle handed selection. Use its mirrored carrier
and mirrored saddle, not the original files in archived bench-1/bench-2 kits.
Working handed assignments: docs/four-leg-working-assembly.md. Verify actual
servo ear/horn/lead orientation for each hand; a symmetric case box is insufficient.
When trying a chassis mount, verify the four existing fixing slots, pivot access,
flange fasteners and actual servo cable route; test stiffness with support first.

1. **Servo identity and fit:** buy one positional MG996R with supplied horn and
   original centre screw. Measure case, mounting ears, shaft/horn height and
   horn bolt pattern. Print the four manufacturing fit coupons; check624
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
   Enter slicer/scale masses in mechanical/robot-mass-inputs.json. The current
   full working BOM's example is2.360kg, so actual print and power masses may
   change the robot design. Weigh fasteners and supplied horns/leads as well;
   do not infer printed mass from the infill percentage alone.

## Provisional servo choices

Experimental MEC-161 forks: print one upper/lower pair side-on, inspect support
removal, bearing-seat fit, horn/retainer and saddle/foot assembly access. Gradually
load the assembled pair and inspect the web/plate junctions for flex or cracking.
These tests are NOT_PERFORMED; the flat-print coupons do not qualify this new
orientation. Use docs/tasks/MEC-161.md; wait for whole-leg clearance integration
before replacing the supported bench parts.
First use the smaller side-on coupon: mechanical/prototype-fork-fit-coupon.stl.
Print/support, bearing/retainer and actual horn fit are NOT_PERFORMED; procedure
is docs/fork-fit-coupon.md. The coupon does not qualify loaded strength.

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
