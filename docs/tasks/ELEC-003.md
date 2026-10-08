# ELEC-003 — board-only timing diagnostic

Completed2026-10-09. Added a manual, DISARMED-only diagnostic with explicit
rail-off/no-servos acknowledgement. Only PCA channel15 is driven, at3.3V,
with GPIO7 input loopback. Servo channels remain full-off; OE goes high before
cleanup writes on every acquisition/preflight/write failure path.

Tests cover valid sequence, missing/stuck input, first-write/preflight errors,
out-of-range samples, a single bad pulse, cleanup failure, acknowledgement
parsing and channel15 isolation. Each pulseIn wait is50ms; three high/low
pairs bound acquisition wait to300ms. The original40ms wait was increased
because pulseIn waits out an existing pulse before measuring a complete one.
Coarse timing is checked per pair, not merely on the average.

All host checks and N16R8 compile pass (19,476bytes RAM;299,965bytes flash).
No hardware flash, timing capture, voltage reading or servo motion. Existing
owned boards and bench passives cover the test; no new component purchase.
