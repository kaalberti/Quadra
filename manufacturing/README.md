# Manufacturing pack — pitch-leg-1 / MFG-001

Scope: one supported two-DOF pitch-leg mechanical prototype and bench adapter.
Ready for printing and unpowered fit assessment. Physical fit is unverified.
This is not a complete robot or a powered-operation release; J1 is absent.

- [BOM](BOM.md): current assembly quantities, fit-first purchases and separate future estimates.
- [Print quantities and dimensions](docs/print-list.md): 16 assembly STL files / 20 pieces, plus four fit coupons.
- [Assembly instructions and view](docs/assembly.md).
- Editable CAD snapshot: cad/prototype-pitch-leg.scad, with its dependencies.
- release-manifest.json: selectors, quantities and file/source hashes.
- validation.json: release verification and applicability of manufacturing checks.

STLs use millimetres. STEP is not supplied: the approved OpenSCAD workflow
produces STL and editable SCAD. No electronics, PCB, wiring, connector pinout
or firmware has been released; those checks are not applicable to this
unpowered mechanical scope. The 2kg robot limit is a design requirement,
not a tested capacity of this kit. Read the fit and loading limits before use.

Working verification exports and release tooling stay outside this folder.
Any manufacturing-affecting design change requires regenerating and checking
the affected outputs and manifest before updating this package. Superseded
release files must be moved to ARCHIVE rather than retained in this folder.