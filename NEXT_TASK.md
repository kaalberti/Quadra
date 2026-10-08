# FW-009 — supervised board-only timing capture

Integrate the existing disarmed board-only timing diagnostic into the supervised
host console with its explicit rail-off/no-servos acknowledgement. Handle its
bounded diagnostic reply separately from normal state replies, preserving fault,
disconnect and no-auto-recovery behavior. Make it easy to retain actual timing
results without inventing measurements or treating operator acknowledgements as
voltage measurements. Test valid capture, refusal while armed, malformed/timeout
and cleanup/fault responses. Do not connect to boards, flash firmware, widen
motion limits, add multi-servo motion/gaits or start another stage. BOM and
manufacturing remain unchanged.
