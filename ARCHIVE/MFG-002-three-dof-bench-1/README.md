# Manufacturing pack — three-dof-bench-1 / MFG-002

One supported three-DOF bench leg, for printing and unpowered fit assessment.
No chassis, electronics, powered capacity or gait release is included.
Physical fit remains unverified. Start with four coupons before the full kit.

- [Assembly and view](docs/assembly.md)
- [Print quantities](docs/print-list.md): 18 unique assembly STLs / 29 pieces
- [Buying BOM](BOM.md): three servos/three bearings; benchmark costs only
- Editable assembly: cad/prototype-three-dof-leg.scad
- layout.json: prototype frame offsets and conservative trial envelope
- release-manifest.json: quantities and hashes
- validation.json: mesh, torque and sampled intersection evidence

STL units are mm. No STEP or printer-specific G-code is supplied. PLA+/PETG,
0.4mm nozzle, 0.2mm layers, four walls and 30% infill are starting settings.
Horizontal holes, bearing/horn fit and actual cables need physical inspection.
The prototype has an85mm forward pitch offset and32mm foot-plane offset;
it is not the old25mm-offset skeleton or a finalized four-leg chassis layout.
J1 torque is screened against stall, not certified continuous operation.
PCB/pinout/wiring/firmware checks are not applicable to this unpowered scope.
The previous two-DOF manufacturing pack is retained in ARCHIVE/MFG-001-two-dof-pack.
