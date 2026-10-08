# Supported bench-joint print kit

MEC-123–132 produces one supported servo joint for cheap mechanical testing.
It is **not yet a complete 3-DOF leg**. The oversized kit tests case grip,
horn mounting and rear-bearing alignment before making integrated leg mounts.

## Print the fit samples first

Use the existing cradle coupon, new horn coupon and bearing coupon before
printing the full kit. Verify the actual servo body, output-shaft position,
horn face height, available horn holes, cable exit and mounting-ear clearance.
The assumed shaft is 10 mm from the short body end and the horn face is
50 mm above the cradle base. Adjust `shaft_x`/`horn_z` in the common source
and layout JSON if measurements differ; recompile affected parts.

Bearing coupon dots identify seats: one =13.0 mm, two =13.2 mm, three =13.4 mm.
Choose a seat that accepts the actual 624 bearing without force and retains it
without obvious radial movement. Change `seat_d` and layout JSON to match.
Do not hammer the bearing into a printed arm. The 4 x13 x5 mm bearing boundary
is from [SKF's public product data](https://www.skf.com/ro/products/rolling-bearings/ball-bearings/deep-groove-ball-bearings/productid-624-2RS1?failover=true).
Use a commodity bearing; no brand or purchase has been locked.

## Parts for one joint

| Item | Quantity | Notes |
| --- | ---: | --- |
| MG996R-sized positional servo with supplied horn/centre screw | 1 | Packaging candidate; verify actual unit |
| Cradle left/right | 1 each | Existing MEC-122 STLs |
| Support, front arm, rear arm, bridge, retainer | 1 each | New STL parts |
| Front spacer / rear spacer | 1 each | Nominal8 mm /3 mm; metal substitutes permitted |
| 624 bearing, 4 x13 x5 mm | 1 | Actual fit checked with coupon |
| M3 x40 bolts with washers/nuts | 2 | Cradle clamp |
| M3 x16 bolts with washers/nuts | 6 | Four base mounts, two bearing-retainer mounts |
| M3 x90 bolts with washers/nuts | 2 | Or cut M3 threaded rods to suit; bridge stack78.2 mm |
| M4 x35 socket-head screw, washer and locking nut | 1 | Retains stationary bearing inner ring; verify head fits7.5 x4.5 mm pocket |
| M2 horn through bolts with nuts | 2–4 | Start with10 mm; actual horn thickness/access sets length |

No printed spline or structural printed threads. Use the supplied servo centre
screw for its original horn. Do not substitute an M2 screw for an unknown spline
thread. Horn nuts and tips must clear the case during hand rotation.

## Printing

All manifest STLs sit on z=0. PLA+ or PETG, 0.4 mm nozzle, 0.2 mm layers,
four walls and about30% infill are starting settings. Arms print flat;
the bridge prints upright with a brim. Check adhesion on its tall columns.
Clear horizontal cradle holes carefully with a drill if needed. The support's
recessed head pocket has a short7.5 mm bridge: inspect the roof in the slicer.
Small spacers need thin-wall slicing; their0.75 mm wall is intentional. Common
metal M4 spacers with suitable inner-ring contact are preferable if these fail
to print cleanly. The assembly STL is a reference scene, not a print part.

## Unpowered assembly sequence

1. Fit the actual bearing into the rear arm and bolt on its retaining plate.
   The plate contacts the outer ring; the central10 mm opening clears the
   inner-ring spacer and M4 washer. Use two M3 x16 through bolts and nuts.
2. Insert the M4 bolt into the support's recessed head pocket while it is
   accessible. Put the8 mm front spacer, rear-arm bearing,3 mm rear spacer,
   washer and locking nut onto the bolt. The spacers touch only the inner
   ring. Tighten lightly enough to retain the stack, then check smooth rotation.
   If the shield or rotating arm rubs a spacer/washer, correct that contact.
3. Join rear arm,66.2 mm bridge and front arm with the two long M3 bolts.
   Their nominal centre pitch is14 mm. Keep both arms parallel.
4. Clamp the servo in the cradle gently. Mount the cradle onto the support
   with four M3 x16 bolts through the base slots. This closes access to the
   recessed M4 head; assemble its bearing stack first.
5. Attach the supplied horn to the front arm through matching radial slots,
   then fit it to the servo using the original centre screw. The10 mm centre
   opening provides driver access. Actual horn geometry determines screw
   count and length; the printed coupon checks this cheaply.
6. Gently move the unpowered assembly through a small useful arc, staying
   away from servo end stops. Check binding, case slip, bearing retention,
   exposed fasteners and cable clearance. Do not force a geared servo.
   If alignment binds, adjust the case position/datum rather than loading it.

Powered loading is a later physical task after the actual supply, polarity,
voltage and current capacity have been checked. Servos must never be powered
through an ESP32 board. No powered-test results are claimed here.

## Checks and limits

Run `powershell -File mechanical/check-hobby-joint.ps1`. It verifies nine new
closed connected STL meshes, print-bed placement, common-source/layout values,
the nominal stack and conservative local rotating clearance. Minimum modeled
radial margin is2.67 mm after0.8 mm allowance. This excludes actual horns,
cables, fastener envelopes and downstream links; hand fit remains essential.
The nominal assembly preview was visually inspected.

Printed solid volume corresponds to83.5 g using assumed PETG density1.27 g/cm3.
A rough65% material fraction gives54.3 g printed plus55 g servo per joint;
twelve such copies total about1.31 kg before bearings, fasteners, battery,
chassis and electronics. **Do not replicate this bench kit twelve times for
the robot.** Slicer mass and weighed prints supersede this rough estimate.
The next leg design needs lighter integrated mounts, retaining the passive
support concept. The1.2 kg target is unchanged and is not currently met by
this replication scenario.

The existing NZ$25–35 servo cap still multiplies toNZ$300–420 for twelve;
the NZ$680–800 whole-project allocation is a planning cap, not verified retail
pricing. Buy/test one positional servo and one bearing first, rather than
committing to twelve. No purchasing or supplier contact occurred.

Next suggested stage-4 task: create one70 mm upper-leg mount joining the hip
fork to the knee servo with an integrated lighter holder. Use fit-coupon
results if available; keep unmeasured interfaces explicitly provisional.
No following major stage was started in this batch.
