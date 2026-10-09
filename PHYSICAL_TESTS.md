# Physical tests pending — ST3215 /3S
No listed test has been performed. Current CAD is provisional.

1. Check one **12V** ST3215,its front/rear wheels and supplied screws. Measure
   case,shaft offsets,wheel faces and mounting pitch. Verify rear wheel rotates
   as an independent support,not a stationary case attachment.
2. Print one clamp pair/spacer: start with the29 mm fit coupons only if the
   measured grip band suits them; otherwise export the measured grip height.
   Measure front/rear wheel faces separately and set each spacer. Check gentle grip,case shape,connector access,
   spacers and wheel thread engagement. Do not force clamp or preload shaft.
3. Dry assemble complete secured bench leg. Check both wheel attachments,
   bolt/tool access,cables and low-angle travel before powered testing. Existing
   MG996R manufacturing pack/fit records do not apply.
4. Read actual battery label:3S conventionalLiPo,capacity,C/current rating,
   dimensions,mass,connector. Inspect condition and individual cell voltages.
   Check charger,main fuse,disconnect and distribution ratings before use.
5. One unmounted servo only:verified adapter wiring,12.0V current-limited PSU,
   horn removed initially. Read position/voltage; verify startup torque state,
   ID uniqueness,limits,communication-loss behavior and explicit torque-off.
6. Configure one servo ID at a time,then map joints1..12. Confirm position readback
   against physical angle; do not equate4096counts/revolution with joint accuracy.
7. Calibrate direction,centre and narrow safe ranges on supported leg. Validate
   every joint separately before simultaneous commands. Old PWM firmware is
   incompatible and must not be flashed to control these actuators.
8. Record individual and leg current,servo-bus voltage sag/transients,holding,
   horn slip,gear behavior and heating during representative duty.5A PSU supports
   staged trials,not the8.1A three-servo stall sum. Never deliberately stall.
9. Increase supported foot load gradually near intended stance. Three-leg
   representative load = actual robot mass x9.81 /3. Measure complete mass
   including60 Wh battery; old2.178 kg MG996R estimate is obsolete. Qualify actual
   standing/slow-motion duty before accepting heavier operating mass.
10. Before untethered operation,verify logic/servo power sequencing,individual
    cell alarm,low-battery controlled stop and manual disconnect. Test safe
    shutdown while robot is supported; removing torque can cause collapse.

Available:user-reported Creality K2 Pro,ESP32-S3 N16R8,PCA9685,multimeter,
load cells and60V/5A supply. Do not exceed12.6V servo input; initial12.0V.
Battery voltage diagnostic remains manual; automatic cutoff and off-state sense
protection have not been implemented.
