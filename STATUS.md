# Project status
Last updated:2026-10-09

## Current milestone
ST3215 /3S architecture redesign and first-leg working CAD.
User selected standard12V ST3215 and inexpensive60 Wh conventional3S LiPo.
No hardware ordered,tested,flashed or physically validated.

## Active mechanical design
- Assembly/source:mechanical/st3215-leg.scad; preview:st3215-leg.png.
- Build guide:docs/st3215-leg-build.md; buying BOM:docs/purchasing-bom.md.
- Three dual-side wheel outputs,adjustable split case clamps; no old624/M4 stack.
-70/85 mm links,85 mm J1-to-J2 forward offset,0 mm axial foot plane provisionally.
- Seven unique STLs/sixteen prints per leg,including six wheel spacer rings.
- Fresh exports:closed connected bed meshes,proper placements,axis/contact and
  bore checks pass;three sampled case/printed-group intersections are empty.
- Battery tray closed/connected,bed-oriented;dimensions and four mount bores pass.
- Assembly/tray previews visually inspected. No swept/loaded range released.
- Wheel faces/hardware/rear support and real cable clearance remain unverified.
- Old MG996R mass estimate2.178 kg is not a current ST3215 estimate; battery and
  servo mass await actual data.2 kg is preferred,qualified maximum TBD.

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
Existing firmware controls PWM hobby servos and cannot control ST3215; bus
firmware,feedback commissioning and angle calibration are the next software work.
Existing MG996R CAD/fit/calibration/mass reports do not qualify this new assembly.
Voltage divider concept remains usable for manual3S readings,but always-connected
sense input/protection and low-battery control require revision. No cutoff works yet.

## Immediate objective
Check one servo/wheel/clamp fit and obtain real battery specifications. Continue
with ST3215 bench interface/feedback and protected harness design as bounded work;
no gait deployment or sensor implementation before reliable leg operation.
Sensor plan:IMU and power monitoring,then forward ranging; remote slow crawl
before obstacle avoidance or mapped navigation. Tests:PHYSICAL_TESTS.md.
No supplier contact. Current numerical values:DESIGN_PARAMETERS.md.
