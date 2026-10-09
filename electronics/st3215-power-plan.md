# ST3215 power and control plan

Use the **12V ST3215**,6..12.6V permitted input. Conventional3S LiPo is
11.1V nominal,12.6V full; no LiHV pack/overcharging substitution.

Battery -> correctly sized main fuse near pack -> rated accessible servo-power
switch/disconnect -> rated distribution -> parallel leg/servo power branches.
Battery also feeds an independently fused5V logic buck -> ESP32/auxiliary logic.
ESP32 UART -> compatible half-duplex TTL adapter -> signal bus to12 servo IDs.
Common signal/power ground; motor current returns through distribution,not MCU.
Adapter needs appropriate supply as documented; never put12.6V on UART/5V pins.

Separate data chaining from current distribution. Supplied three-wire cables
can combine both; final harness must avoid backfeeding duplicate positives and
must establish actual connector/pinout/current capability. Verify polarity with
meter,not wire colour. Do not carry32A through adapter,DC barrel,perfboard or
first daisy-chain lead. Adapter current rating is not documented for that duty.
Power-injection harness and connector selection remain a subsequent bounded task.

Planning checks:2.7A per stalled servo at 12 V;8.1A per leg,32.4A all12.
40A main capacity screen provides provisional headroom; actual gait demand
must be measured. Main/branch fuse and wire sizes remain TBD until pack and
connector ratings and cable lengths are known. A fuse must protect the wires,
not merely equal an estimated motor total.

60 Wh nominal energy implies about5.4 Ah at11.1V. Pack must have a documented
appropriate discharge rating,healthy cells,balance connector and undamaged
leads. Example10C x5.4 Ah=54A advertised; verify manufacturer's continuous/peak
ratings and real voltage sag. Pack envelope120 x50 x20 mm is user-provided provisional;mass and actual fit remain TBD.
Illustrative80% usable60 Wh gives48 Wh: at40W average ~72min,at80W ~36min.
Neither is a measured runtime; weight and gait materially affect demand.

Start one unmounted servo at12.0V from current-limited bench PSU,with proper
fuse and known adapter wiring. Existing5A PSU can serve this initial trial;
three-servo stall screen8.1A exceeds it. No connected-leg motion before calibrated
angles,mechanical range and bus startup/shutdown behavior are verified.

Battery operating protection is not implemented. Plan pack warning10.8V and
controlled stop10.5V loaded provisionally,plus individual-cell balance-lead
monitoring; pack voltage cannot reveal an imbalanced weak cell. Thresholds need
pack-specific trials. A supported controlled stop precedes power removal because
cutting torque can collapse the robot. Provide a manual power disconnect regardless.
Do not rely on servo minimum6V to protect a3S battery from overdischarge.

Full charge sits at servo's12.6V stated maximum. Check bus transients during
starts/deceleration,local bulk capacitance and regenerative behavior before
unrestricted motion. Do not assume an arbitrary TVS clamp guarantees12.6V.
Use compatible balance charger/storage settings; bench PSU is not a balance charger.

Existing150k/10k voltage input can measure3S within its25.2V screen, but it is
manual/disarmed and requires disconnecting sense positive before ESP power-off.
An always-connected battery input needs revised off-state isolation/protection.
Old PWM firmware must not be flashed for ST3215 control; bus firmware is pending.

References:
https://www.waveshare.com/wiki/ST3215_Servo
https://docs.waveshare.com/Bus_Servo_Adapter_A
https://docs.waveshare.com/Bus_Servo_Adapter_A/Product-Wiring-Example
