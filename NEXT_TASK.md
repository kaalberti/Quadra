# FW-008 — offline calibrated leg planning CLI

Expose the existing C++ leg planner as an offline command-line tool using the
FW-007 measured-profile validator/exporter and existing geometry/IK libraries.
Accept a requested first-leg foot reference position and explicit branch policy;
return a complete angle/pulse plan only when all measured and existing trial
limits pass. Independently check a known CAD target, reversed mapping and
unreachable/out-of-limit/unmeasured failures. No serial/board connection,
firmware activation, invented physical measurements, wider pulse limits,
multi-servo motion, gait or following stage. Keep BOM/manufacturing unchanged.
