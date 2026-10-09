# FW-010 — ST3215 single-servo feedback bench firmware

Create a separate ESP32-S3 build using existing local tools. Implement validated
ST3215 ping/feedback requests, torque-state read and explicit supported torque-off
with readback. UART stays disabled until operator selects confirmed pins while
rail is off; no motion, torque-enable, broadcasts or EEPROM writes are exposed.
Verify the protocol/register map against public manufacturer source.

Acceptance: host tests cover exact packets, framing/checksums/IDs/lengths, device
errors, timeouts, feedback decode, command rejection and torque-off verification.
Build for ESP32-S3 N16R8 without flash/upload. Document adapter wiring and staged
one-servo use; update status/BOM as needed. No powered test, full-leg controller,
gait, battery-harness implementation or next major stage.

Status: complete. Separate build, 96 host checks and operating guide completed;
no flash or powered test. Result: docs/st3215-feedback-bench.md.
Following stage not started.
