# Bench leg coordinate model — FW-004

`firmware/include/leg_geometry.h` computes knee-axis reference, nominal foot
reference and rubber-pad centre for the current three-DOF CAD. Millimetres and
degrees. Origin: J1 axis datum. +x forward, +y outward in this bench assembly,
+z up. This is the unmirrored bench frame, not a four-leg/body mounting model.

At J1=0, the pitch frame maps local(x,y,z) to(85-y,-18+z,x).
Upper/knee translations are-70mm and-85mm along localx. J2 rotates positive
about localz; J3 rotates negative relative to J2. Then J1 rotates the entire
moving module about world+x. Increasing J1 moves the hanging foot outward;
increasing J2 moves the upper link forward; J3 flexes the knee backward.

The nominal reference uses local axial50mm, matching the horn plane. The
actual rubber patch spans axial47..55mm and therefore has centre51mm.
Both are points on the existing contact face. At nominal0/44.0486/78.9786deg,
reference is approximately[85,32,-120]mm and pad centre[85,33,-120]mm.
Use one convention consistently when solving foot positions; geometry and
the previously documented32mm reference have not been changed.

The function rejects nonfinite inputs and nonpositive link lengths, leaving
output unchanged. It intentionally permits mathematical poses beyond trial
ranges for offline exploration; it does not establish mechanical clearance,
servo limits, reachable loaded workspace or physical accuracy. The controller
does not accept foot-position commands. Calibration and physical checks remain
unset under PHYSICAL_TESTS.md.

`firmware/test.ps1` executes compiled C++ special-pose/invariant checks and five
independent OpenSCAD comparisons. The SCAD probe uses current layout transforms
and upper-leg datum functions; the runner extracts the actual pad dimensions
from pitch CAD. Agreement tolerance0.001mm accounts for OpenSCAD echo precision.
This verifies model/transform agreement, not the assembly's physical fit.

## Offline inverse solver — FW-005

`firmware/include/leg_inverse.h` solves a requested nominal reference point,
not the pad centre. It returns up to four branches from the two possible
abduction-plane heights and two planar knee directions. Default bounds are
the provisional unpowered envelope: J1 -25..30, J2 20..55, J3 60..90deg.
A unique solution is distinguished from ambiguous, unreachable, outside-bounds,
invalid-input and indeterminate-abduction results. No branch is silently chosen.

The solver keeps the target unchanged and checks every candidate through FK
with residual at most0.0000001mm. Machine-roundoff guards handle cosine/square-root
domain noise; angle estimates within0.00000001deg of a bound may be snapped
to that bound, then checked again. These are numerical tolerances, not permission
to project an unreachable target into a physical workspace.

Straight/folded chains and tangent abduction geometry are flagged singular
even when finitely many angle solutions exist. When the target lies on the
J1 axis and its nominal outward offset is zero, abduction is indeterminate;
the solver returns Singular with no arbitrarily chosen angle.

These are geometric solutions only. Bounds do not establish collision-free,
loaded or servo-calibrated motion. There are no hardware IK commands. Host
tests cover36 envelope round trips, four wide-bound branches, straight/folded
deduplication, altered geometry, out-of-reach targets and invalid data.

## Offline request-to-pulse preparation — FW-006

`leg_plan.h` combines calibration and inverse solving without I/O. It first
requires three valid measured profiles, then solves the nominal reference target.
A unique non-singular branch can be used directly. Multiple branches or finite
singular poses require an explicit index into that request's returned IK branches.
Indeterminate abduction has no selectable branch. An explicitly selected finite
singular pose retains its singular flag; it is not a qualified motion request.

Each selected angle must lie inside its own calibrated usable range and every
mapped pulse must stay within the initial1450..1550us bench window. Wider
calibration anchors do not widen this output window. All three pulses are
prepared locally; output is assigned only after every check succeeds. Diagnostics
identify IK/mapping status, branch count and failing joint. On failure, the prior
output remains unchanged and must not be mistaken for a newly authorized command.

The library neither loads the unmeasured JSON record nor sends commands to the
PWM controller. Synthetic host profiles demonstrate the integration only.
Physical profile collection, measured supply capability and hardware enablement
remain separate tasks. No trajectory, gait or three-servo power approval is implied.
