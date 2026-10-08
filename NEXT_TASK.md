# ELEC-003 — board-only PWM loopback diagnostic

Prepare an explicitly requested timing diagnostic for the owned ESP32-S3/PCA9685.
Use one unused PCA output at3.3V looped to a verified ESP32 input, servo rail OFF
and no servos connected. Keep actuator channels full-off throughout, restore
all-off/OE disabled afterward on every path. Measure nominal PWM period/pulse
with bounded waits; report failure instead of fabricating timing or calibration.
Test sequencing/cleanup with mocks and compile the N16R8 target. Document wiring
and limitations; no flash or physical test unless the user performs it.
Physical validation remains deferred in PHYSICAL_TESTS.md.
