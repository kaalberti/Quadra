# MEC-170 — ST3215 / 3S architecture and printable leg redesign

Replace the MG996R working direction with twelve ST3215 12V serial-bus servos
and a user-provided conventional 60 Wh 3S LiPo (11.1V nominal,12.6V maximum).
Verify public mechanical drawing and power/interface limits. Produce editable
three-DOF working CAD, printable mounting/link parts and an assembly preview.
Retain70/85 mm links where practical; use supplied dual-shaft hardware rather
than the previous external-bearing stack if the drawing supports it.
Update active requirements,parameters,BOM,status and physical-test plan.
Independently check meshes,axis spacing and nominal clearances. No powered
trial,advanced locomotion or manufacturing release. Existing PWM firmware and
manufacturing pack must be clearly labelled incompatible reference material.
Battery envelope120 x50 x20 mm is user-provided provisionally; actual dimensions,mass,discharge rating and condition remain unverified. Include a simple removable padded tray.

Completed:source-bound mesh/axis/contact and three sampled collision checks pass. Details:docs/tasks/MEC-170.md. Physical fit remains untested; no following stage started.
