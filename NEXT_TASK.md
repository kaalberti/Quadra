# ELEC-002 — provisional12-servo harness and channel plan

Extend the verified bench wiring architecture to a provisional four-leg harness:
assign12 PCA9685 channels to named leg/joint connections, use the existing
buffer/distribution approach, and define separate signal/power branches and
physical cutoff access. Reconcile conditional component counts in the buying BOM.
Use public manufacturer documentation; no supplier contact. Leave measured
servo current, battery/regulator selection and exact board headers provisional.

Completion: one consistent connection table, diagram, commodity component
counts and independent channel/pin/power-boundary checks. Keep the existing
one-servo commissioning harness/firmware and MFG-003 unchanged. No powered
four-leg commands, gait work, premium part selection or following stage.
FIT-001 physical coupon and first-leg assembly remains pending in parallel.
