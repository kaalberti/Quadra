# FW-003 — offline joint calibration and limit mapping

Develop a reusable angle-to-pulse mapping with two measured anchors, direction
and separate usable limits. Reject missing calibration, invalid data and
extrapolation. Default all physical profiles to unmeasured MG996R assumptions.
Independently test both directions and rejection cases, compile for ESP32-S3.
No angle commands enabled on real hardware, widened pulse window or gait work.
Physical work is deferred explicitly in PHYSICAL_TESTS.md, not a development block.

Completion: offline mapping and host tests are implemented; N16R8 target build
is configured. Physical profiles remain unmeasured and no angle API is enabled.
Following task: an offline forward-kinematics model checked against the actual
three-DOF CAD frame transforms, retaining70/85mm links and current bench offsets.
Do not use the historical25mm skeleton or enable hardware IK before calibration.
