# ELEC-008 — Perfboard voltage input and disarmed diagnostic

Design an inexpensive, removable perfboard divider/filter for an explicitly
limited0..25.2V positive test input, using GPIO8 provisionally after actual
board pin verification. Check divider tolerance, ADC range and power-off wiring
sequence against public Espressif data. Do not select a battery or treat this
manual bench interface as an always-connected battery monitor.

Implement a bounded, explicit disarmed voltage diagnostic in existing firmware,
reporting ADC/input estimates and sample spread without enabling servo outputs,
changing calibration, extending armed sessions or adding a cutoff threshold.
Add meaningful host checks for scale, limits, sample failure and state gating;
compile using existing project tools. Record perfboard wiring, modest buying
parts and the later multimeter comparison procedure.

Completion: independently checked input geometry/rating, host regressions and
embedded build pass. All physical voltage/accuracy tests remain NOT_PERFORMED.
No flash, powered test, final SMT PCB, battery selection or gait work.
