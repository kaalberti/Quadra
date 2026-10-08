# FW-006 — offline one-leg request-to-pulse preparation

Combine validated IK and calibration into a side-effect-free one-leg planner.
Reject unmeasured profiles, unreachable/out-of-bound targets and singular or
ambiguous solutions unless an explicit branch choice is supplied. Produce
all three pulse values atomically only when every calibration/bound check passes.
Keep initial output limits at1450..1550us; wider limits remain a hardware task.
Test complete synthetic profiles and partial/failing requests; compile for N16R8.
Do not add servo transport, hardware foot commands, trajectories or gaits.
Physical validation remains deferred in PHYSICAL_TESTS.md.
