# FW-007 — measured calibration profile tooling

Inspect existing joint calibration records and tools, then provide the missing
bounded workflow that converts actual first-leg measurements into validated
offline calibration profiles. Preserve unset/unmeasured records and existing
1450..1550us bench motion limits. Reject incomplete, inconsistent or unsafe
inputs; independently check valid/reversed profiles and failure cases. Reuse
existing tools where adequate instead of duplicating them. Do not flash boards,
invent measurements, enable multi-servo motion, change power architecture or
implement gaits. Update status/test instructions and stop before another stage.
