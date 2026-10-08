# Offline first-leg planner

`firmware/offline_leg_plan.py` validates an actual measured profile record,
exports an offline header into ignored test-output, and compiles/runs the existing
C++ leg planner using the approved local Zig compiler. It opens no serial port,
does not flash firmware and sends no PWM commands. Generated test artifacts
remain in test-output; no existing profile/header is overwritten.

Example after completing physical calibration:

```powershell
& C:\Users\Kyle\.platformio\penv\Scripts\python.exe firmware/offline_leg_plan.py firmware/measured-first-leg.json --target 85 32 -120 --branch auto
```

Target coordinates are millimetres in the existing first-leg bench/J1 frame:
+x forward, +y outward, +z up. This is the foot contact reference with axial
offset50mm, not the rubber pad centre (51mm), a body-frame command or a servo
shaft position. Current geometry is70/85mm links and pitch offset[85,-18,0]mm.

You must explicitly choose `--branch auto` or a candidate index0..3. Auto accepts
only a unique nonsingular solution; an index selects among solutions that have
already passed the current geometric bounds. Indices are not persistent gait
branches. Current trial bounds remainJ1[-25,30],J2[20,55],J3[60,90]degrees;
they are unpowered geometric screens, not validated hardware travel.

Success returns one complete JSON plan with angles, requested microsecond pulses,
selected branch and singular flag. All measured usable limits and the current
1450..1550us bench window must pass. Failure returns a reason and no angle/pulse
plan. Profile validation happens before compiling; the current blank project
record is deliberately rejected. Actual PWM timing, load and collision safety
are not established by an offline success.

Run `firmware/test.ps1`. Five CLI tests independently check the existing CAD
reference target, expected reversedJ2 mapping, unreachable/geometrically excluded
targets, bad branch/nonfinite input, calibration-limit rejection and the actual
unmeasured template. Synthetic test profiles are not real calibrations.

No new dependency, purchase, firmware activation or manufacturing revision.
