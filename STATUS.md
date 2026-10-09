# Project status
Last updated:2026-10-09

## Current milestone
ST3215 four-leg working chassis layout; first-leg interfaces remain untested.
User selected standard12V ST3215 and inexpensive60 Wh conventional3S LiPo.
No hardware ordered,tested,flashed or physically validated.

## Active mechanical design
- Assembly/source:mechanical/st3215-leg.scad; preview:st3215-leg.png.
- Build guide:docs/st3215-leg-build.md; buying BOM:docs/purchasing-bom.md.
- Three dual-side wheel outputs,adjustable split case clamps; no old624/M4 stack.
-70/85 mm links,85 mm J1-to-J2 forward offset,0 mm axial foot plane provisionally.
- Eight leg STLs/sixteen prints per leg; front/rear spacers tune independently.
- Two alternative29 mm grip-band clamp coupons available before full printing.
- Link lengths/hip offset now drive mounting geometry; nominal dimensions retained.
- Fresh exports:closed connected bed meshes,proper placements,axis/contact and
  bore checks pass;three sampled case/printed-group intersections are empty.
- Coupon bores and independent link/hip/spacer mesh perturbations pass.
- Battery tray closed/connected,bed-oriented;dimensions and four mount bores pass.
- Assembly/tray previews visually inspected. No swept/loaded range released.
- Wheel faces/hardware/rear support and real cable clearance remain unverified.
- Old MG996R mass estimate2.178 kg is not a current ST3215 estimate; battery and
  servo mass await actual data.2 kg is preferred,qualified maximum TBD.

## Four-leg chassis layout
- Assembly:mechanical/st3215-chassis.scad; guide:docs/st3215-chassis-build.md.
- Provisional175 x160 mm floor/end-wall body,rotated rear legs; identical leg prints.
- Low central battery tray; removable140 mm deck on four51 mm printed risers.
- Matching J1 fixture holes and34 mm rotating-hub reliefs; commodity M3 bolts.
- Closed/connected bed meshes and bores checked; nominal and5 deg outward
  abduction clearances checked using conservative boxes and actual hip meshes.
- Electronics blocks reserve space only; real modules,leads,fasteners and COM TBD.
- Chassis/deck/risers solid-PETG estimate331 g; complete measured mass unknown.
- Current layout71 installed prints including battery tray; no manufacturing release.

## Power/control direction
Protected switched3S battery bus directly supplies ST3215; separate5V logic buck.
ESP32-S3 retained; half-duplex TTL bus adapter replaces PCA9685 leg PWM.
PCA9685 remains owned but unused for new actuators. Perfboard auxiliaries first,
SMT later,DigiKey preferred. Electronics plan:electronics/st3215-power-plan.md.
60 Wh/11.1V implies about5.4 Ah,not a verified current rating. Pack120 x50 x20 mm envelope is provisional;
mass,connector,condition and discharge rating pending. Battery tray source:
mechanical/st3215-battery-tray.scad; padded/strapped,actual chassis placement TBD.
32.4A all-servo stall sum
at 12 V gives provisional40A distribution screen; actual load/fuse/wires TBD.
No high-current bus through adapter,barrel jack,perfboard or unverified chains.
5A bench PSU permits staged one-servo tests at12.0V;3-servo screen is8.1A.

## Reference artifacts and limitations
The manufacturing/ checkpoint (MFG-003 integrated-bench-1) remains an unchanged MG996R reference
checkpoint,not a current ST3215 release. Do not print it for these actuators.
Legacy firmware controls PWM hobby servos and cannot control ST3215. Separate
firmware/st3215 now provides single-servo ping/feedback and explicit torque-off
with readback. UART starts disabled; no motion/enable/EEPROM commands exposed.
ESP32-S3 build and host checks pass; wiring, flashing and powered tests pending.
Guide:docs/st3215-feedback-bench.md. Joint angle calibration remains future work.
Existing MG996R CAD/fit/calibration/mass reports do not qualify this new assembly.
Voltage divider concept remains usable for manual3S readings,but always-connected
sense input/protection and low-battery control require revision. No cutoff works yet.

## Design review
Review:docs/design-review.md. Main gates are actual clamp/wheel fit, protected
power distribution and physical single-servo ST3215 commissioning. Proposed adapter is rated
5A, so external parallel servo power is required. Read-only artifact verification
now binds both CAD sources/generator/STLs; legacy PWM build/console requires
explicit opt-in. Physical fit, power qualification and powered bus commissioning remain open.

## Immediate objective
Check one servo/wheel/clamp fit and obtain real battery specifications. Continue
with physical feedback commissioning and protected harness design as bounded work;
no gait deployment or sensor implementation before reliable leg operation.
Sensor plan:IMU and power monitoring,then forward ranging; remote slow crawl
before obstacle avoidance or mapped navigation. Tests:PHYSICAL_TESTS.md.
No supplier contact. Current numerical values:DESIGN_PARAMETERS.md.
