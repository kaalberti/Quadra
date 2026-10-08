# Three-DOF bench prototype layout — 2026-10-08

Retain commodity hobby-servo horns and opposite-side 624 bearings for J1.
A separate print-flat carrier replaces the J1 fork's bridge and connects
its two arms to the unchanged pitch-leg cradle/support mounting pattern.

The bench prototype places the pitch floor at [85,-18,0]mm in the J1 frame,
giving a nominal foot plane 32mm outward. The generous forward offset separates
the large hobby-servo cases without precision coupling or a new actuator.
This is prototype packaging, not a final chassis attachment or a claim that
the old 25mm hip-offset skeleton is mechanically implemented.

Consequences: use the three-DOF assembly transform for this physical prototype;
do not command it using the old offset model. Update the final four-leg model
when chassis attachments are selected. Initial mechanical trial ranges are
conservative and powered motion is not approved by sampled CAD checks.
The existing bench adapter moves to J1; one additional servo/bearing is needed.
The complete robot mass and fit must be checked on hardware before replication.
