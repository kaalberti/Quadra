# Quadra — current requirements

Build an affordable FDM-printed Rev A quadruped for hobby use. Prioritize a
working physical prototype, straightforward assembly and inexpensive standard
parts. Use conservative geometry and physical trials rather than detailed
structural optimization.

## Architecture and geometry
- Four legs, three DOF each: hip abduction, hip pitch, knee pitch.
- Passive replaceable feet; indoor flat-floor testing first.
- Retain70 mm upper and85 mm lower links where practical.
- Provisional ST3215 chassis175 x160 mm; packaging may change after real fit tests.
- Preferred complete operating mass2 kg. Heavier is acceptable within measured
  servo/power load and duty capability; qualified maximum remains TBD.
- Body frame+x forward,+y left,+z up. Existing joint signs retained.
- Joint limits and standing poses require physical calibration/clearance tests.

## Actuators and power
User selected twelve ST3215 **12V/30 kg.cm variant**, conventional TTL serial-bus
servos with magnetic position feedback. Do not substitute7.4V or HS variants.
Use supplied front and opposite-side wheels; exact hardware and wheel faces
must be checked before final printing or bulk hardware purchase.

Use the user's inexpensive **60 Wh conventional3S LiPo** provisionally:
11.1V nominal,12.6V fully charged,approximately5.4 Ah if60 Wh is nominal energy.
Provisional pack envelope120 x50 x20 mm. Mass,connector,discharge rating,condition and cell balance are
unknown. Do not assume60 Wh proves sufficient current capability.

Servo power comes from the protected switched battery bus; no large servo BEC
is required for the selected voltage range. ESP32 logic needs its own regulated
5V supply. Never put battery voltage on ESP32,PCA9685 or former AHCT buffers.
Use rated main distribution,parallel leg power branches and a readily accessible
servo-power disconnect. Do not route all twelve-servo current through the small
bus adapter,barrel jack,perfboard or a chain of unverified servo cables.

## Electronics and development
Owned ESP32-S3 N16R8 remains the controller. Use a compatible single-wire
half-duplex TTL UART bus adapter. PCA9685 is owned but not used for leg control.
Prototype auxiliary circuits on perfboard; consider SMT after architecture works.
DigiKey preferred for electronic components; public documentation only; no
supplier emails. No custom PCB needed for Rev A.

Planned sensor progression: voltage/current monitoring,one 6-axis IMU,then
forward obstacle ranging. Remote-controlled slow walking precedes autonomous
avoidance; mapping/cameras/foot sensing remain optional later work.

## Cost and fabrication
Total targetNZ$500–800,ceilingNZ$1,000. Actuator targetNZ$25–35 each,
NZ$300–420 total; flag landed prices aboveNZ$50 each or material budget changes
before purchase. Surface any individual/repeated selection consuming over approximately 10% of the project budget before locking it. Exceeding NZ$1000 requires explicit approval. User approved ST3215 architecture; exact landed quote remains TBD.
Creality K2 Pro available;0.4 mm nozzle,0.2 mm layers,PLA+/PETG.
Prefer through M3 bolts,commodity wheels and removable modules.
User has multimeter,load cells and adjustable 60 V/5 A PSU. Start with one servo
at 12.0 V and appropriate current limiting,never 60 V;5A is not a three-servo supply.

## Progression
One-servo feedback and fit -> unpowered 3-DOF leg -> calibrated powered leg ->
four-leg standing -> weight shifts -> slow crawl -> turning -> IMU corrections ->
obstacle avoidance. Physical reliability precedes advanced locomotion.
Existing PWM firmware and MFG-003 manufacturing pack are MG996R reference
artifacts and do not control or fit ST3215. New manufacturing release follows
working CAD review and actual interface checks.
