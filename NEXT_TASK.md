# FW-001 — individual-servo bench controller

Implement and compile an ESP32-S3/PCA9685 bench controller using existing
local tools. Startup must keep OE high and all channels off. Enable only one
explicitly armed channel, initially1450..1550us at50Hz. Disarm on command
timeout or I2C failure; do not automatically resume after a fault.

Independently check controller state transitions and pulse conversion with
host tests, and compile the actual embedded target. Document commands and
unpowered bring-up. No flashing, servo motion, calibration, IK or gaits.
Actual board/servo/PSU are pending, so pin and power assumptions stay provisional.
