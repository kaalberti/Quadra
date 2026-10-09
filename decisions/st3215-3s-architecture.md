# ST3215 and3S power architecture — MEC-170

User selected ST3215 and inexpensive60Wh3S LiPo. Choose the standard12V
variant,not7.4V or HS. This supersedes MG996R,PCA9685 leg PWM,and the5.2V
servo BEC/buffer direction. Existing hardware remains owned; previous firmware
and manufacturing files remain historical references,not active ST3215 outputs.

Direct3S power is within the manufacturer's6..12.6V input range. Use a separate
5V logic buck and compatible half-duplex TTL adapter. Avoid high servo current
through the adapter/barrel jack; use external protected distribution.
60 Wh/11.1V =5.405 Ah nominal,not verified capacity or discharge capability.
12 x2.7A=32.4A stall sum at 12 V;40A distribution capacity is a provisional screen,
not a measured continuous load or chosen fuse. Check actual pack current rating
before use. A genuine10C5.4 Ah pack would advertise54A; a low-rate pack might
be unsuitable despite equal energy. Fuse selection waits for real ratings.

Dual-side wheels permit shorter output forks and removal of old external624
bearings/pivots. Adjustable split clamps avoid undocumented case screw threads.
The manufacturer's2022 drawing downloaded from the ST3215 wiki is titledSCS215:
use it provisionally,then verify selected servo and supplied wheels physically.
The rear wheel/bearing behavior and support capability are untested.

Keep70/85 mm links and85 mm forward hip spacing initially; pitch/foot plane is
now0 mm axial rather than the MG996R32 mm outward datum. Offline kinematics must
use the new datum; old CAD/calibration/source correspondence is not transferable.
A0.751Nm earlier2.2 kg demanding-pose estimate is below2.942Nm advertised12V
stall,but revised mass,voltage,stance and thermal duty remain unmeasured. No
maximum mass,loaded range or continuous torque is approved by this comparison.

Battery mass is unknown;120 x50 x20 mm envelope user-provided provisionally: retire the old150g allowance and2.178 kg
estimate as current estimates. Do not build a tight battery tray from60 Wh alone.
No actuator buying quantity or physical success inferred. Obtain/test one servo
first; exact twelve-unit landed cost remains TBD under existing budget.

Sources accessed2026-10-09:
- https://www.waveshare.com/wiki/ST3215_Servo
- https://www.waveshare.com/product/st3215-servo.htm
- https://files.waveshare.com/upload/0/08/ST3215-2D.zip
- https://files.waveshare.com/upload/5/59/ST3215-3D.zip
- https://docs.waveshare.com/Bus_Servo_Adapter_A
