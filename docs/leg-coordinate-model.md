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
