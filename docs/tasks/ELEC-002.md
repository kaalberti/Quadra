# ELEC-002 — commissioning evidence preparation

Completed2026-10-08. Added an unset operator measurement record and checker
for actual hardware identity, voltage limits, OE behavior, physical cutoff and
an optional subsequent horn-off servo trial. Seven tests pass; the actual
record evaluates NOT_MEASURED. No measurements were inferred or written.

The checker distinguishes missing evidence, failed setup/trial, readiness for
one unmounted-servo trial and a recorded trial. It never approves assembled-leg
motion or a three-servo supply. PWM timing is optional for the first horn-off
trial; measurement is required before wider/mounted motion. A scope purchase
does not block that initial test.

Reproducible local firmware setup was exercised; embedded build and the
54-file MFG-002 release check pass. Actual hardware/printing information and
physical tests now gate meaningful prototype advancement. No calibration,
IK, robot battery/BEC or gait stage started.
