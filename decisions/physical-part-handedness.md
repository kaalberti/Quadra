# Physical printed-part handedness

MEC-158 identified reflection matrices in the bench pitch-module and carrier
placements. Those reflect a printed shape instead of moving it rigidly.
The nominal geometry is retained, but physical print selection must respect
that handedness. Actual mesh checks identify the carrier and knee-ear saddle
as requiring mirrored variants for front-left/rear-right (and the intended
bench orientation). The other diagonal uses their original prints.

Common parts are reused through proper rotations, including swapping cradle
halves. All working printed-part and servo-envelope placement matrices have
determinant+1. The new assembly has the same nominal geometry as the reflected
study; no root/foot/link dimensions or actuator strategy change.

The working chassis mount print transform was also made a proper rotation;
its updated left/right exports retain dimensions and hole patterns. The bench
checkpoint is preserved for a separate handed-print correction. Actual servo
horn/ear/cable asymmetry remains a physical test, not a CAD assumption of fit.

MEC-159 packages the intended bench orientation as three-dof-bench-3 with the
two mirrored prints and a physically placeable self-contained assembly. Hardware
and nominal geometry remain unchanged; bench-2 is retained intact in ARCHIVE.
