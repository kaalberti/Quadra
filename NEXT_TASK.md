# FW-005 — bounded offline inverse kinematics

Implement inverse solving for the current CAD-matched contact reference.
Use the unpowered trial envelope as an explicit provisional search bound.
Reject unreachable/nonfinite targets and report multiple branches explicitly.
Verify round trips against forward kinematics, boundaries and branch cases;
compile the offline library for N16R8. Do not clamp an unreachable target into
a reachable one or enable foot-position commands on hardware.
No gait, chassis mirroring or physical-workspace qualification in this task.
Physical validation remains deferred in PHYSICAL_TESTS.md.
