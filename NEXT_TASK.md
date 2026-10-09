# RISK-001 — Guard active artifacts and incompatible legacy firmware

Reduce R12 and the accidental legacy-use portion of R9 without physical hardware.
Add a read-only current-artifact verifier; bind both CAD sources and the generator
to fresh validation evidence; require explicit legacy opt-in at PWM build/console
entry points. Preserve current geometry and all physical qualification caveats.

Acceptance: fresh existing mesh/clearance checks pass; read-only verification
passes without altering artifacts and rejects changed sources, meshes, generator
or incomplete manifests. Legacy entry points reject default use before tools or
serial I/O. Update review/status/backlog, commit and push the coherent checkpoint.

Scope excludes mechanical redesign, new bus firmware, powered tests, purchases,
and manufacturing release. Do not start the next engineering stage.

Completed: fresh seven-part/tray mesh and six sampled intersection checks pass; read-only verifier and twelve fault-injection tests pass without artifact writes; twenty-one console regressions, Python CLI refusal and both PowerShell preflight guards pass. No following stage started.
