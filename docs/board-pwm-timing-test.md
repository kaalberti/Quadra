# Board-only PWM timing check — ELEC-003

This can be prepared using the owned ESP32-S3 N16R8 and Adafruit PCA9685,
without servos, a battery or the bench supply. No physical test has been run.
Verify the actual board labels and3.3V rail with the multimeter first.

## Wiring with power disconnected

| ESP32 board | Adafruit PCA9685 |
|---|---|
|3V3 | VCC, logic only |
|GND | GND |
|GPIO4 | SDA |
|GPIO5 | SCL |
|GPIO6 through220ohm | OE, with1kohm pull-up from OE to3V3 |
|GPIO7, input only | PWM/signal pin of channel15 |

GPIOs are provisional DevKitC mappings: use GPIO numbers, not guessed header
positions. Leave V+, the servo terminal block, all servo connectors and the
5V signal buffer disconnected for this check. Channel15's signal pin must
be distinguished from its V+ and GND pins. Never loop5V buffer output into GPIO7.

[Adafruit's pinout guide](https://learn.adafruit.com/16-channel-pwm-servo-driver/pinouts)
states that VCC supplies logic/pullups/output voltage, OE is pulled low by
default, and V+ is separate. The pull-up establishes disabled startup;
verify it against the actual PCB revision. Existing bench passives/jumpers
cover this connection; no new controller, PWM module or scope purchase.

## Procedure after reviewing/uploading the firmware yourself

Use the UART/programming USB connection appropriate to the actual dev board.
Open a115200baud serial monitor; do not run the automatic bench console at
the same time. Confirm DISARMED and no connected servo or servo power, then type:

```text
timing rail-off no-servos
```

The words acknowledge your setup; they are not a voltage sensor. The command
is rejected while armed/faulted. It clears all16 channels, then temporarily
enables only channel15 at nominal1500us/50Hz. All actuator channels stay full-off.
After measurement it raises OE before cleanup writes and clears all channels.
Bus/configuration/cleanup failures latch FAULT; missing or out-of-range timing
is reported without inventing a measurement. No automatic retry or oscillator
correction is performed.

Three high/low pairs are measured using the installed Arduino-ESP32 pulseIn
implementation. Each call has a50ms timeout, at most300ms total acquisition
wait. The reported period is high+low from periodic waveform portions, not
a simultaneous two-edge capture. Each pair must have1400..1600us high time
and19000..21000us summed period to pass. These are coarse bring-up screens,
not servo calibration tolerances or a precision scope replacement.

Record actual high_us/period_us in electronics/bench-commissioning.json optional
PWM fields, together with date/operator and setup observations. This verifies
logic timing only: it does not measure amplitude,5V buffer behavior, motor
current, servo response, physical fit or loaded duty. If timing fails, check
logic voltage, channel/pin wiring, OE and configured oscillator before motion.
