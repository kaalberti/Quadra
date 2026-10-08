# ELEC-001 — bench servo power and wiring preparation

Completed2026-10-08. Defines a separate proposed5.2V servo rail, external
distribution/cutoff,3.3V I2C and AHCT buffering for one-servo-first tests.
Source data and assumptions: electronics/bench-power.json and bench-wiring.md.

Validation: `node electronics/check-bench-power.mjs` passes. Three-servo
planning allowance6A;25% supply margin gives7.5A. Proposed wires give0.189V
wire-only drop and5.011V at a branch before unverified connector/lead losses.
No battery/BEC chosen, no physical measurements, no powered qualification.
Bench shopping allocation NZ$55 is provisional and inside the existing budget.

Next independent work: single-channel control with disabled startup,
explicit arming, narrow pulse limits, timeout and latched I2C faults.
