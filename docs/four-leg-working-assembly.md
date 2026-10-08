# Four-leg working assembly and handed parts — MEC-158

Open `mechanical/prototype-four-leg-working-assembly.scad` for the assembly.
Its preview has the same stem. This working plan is not a manufacturing release
or a claim that the robot stands. Physical servo, horn, cable and printed fit
remain untested. The supported bench checkpoint stays in manufacturing/.

The working plan uses22 unique STLs/117 printed pieces:112 leg pieces, four
chassis mounts and one deck. No bench adapter or bench standoffs are included.
`mechanical/four-leg-working-print-manifest.json` records counts, exact STL
hashes and per-piece rigid placements. These placements are nominal only.

## Handed assignments

| Corner | J1 carrier and knee-ear saddle | Chassis mount |
| --- | --- | --- |
| Front left | New `-mirrored.stl` variants | Left |
| Front right | Original STLs | Right |
| Rear left | Original STLs | Right, rotated180deg |
| Rear right | New `-mirrored.stl` variants | Left, rotated180deg |

Only two additional leg print files are required. Each original carrier/saddle
and each mirrored carrier/saddle has quantity2. Other leg parts reuse existing
prints through rotation; cradle halves may swap roles, with8 left and8 right
halves overall. The working mount print orientation has also been corrected
to use a proper rotation for its original hand. Use its current STLs/labels.

The mirrored parts export with their existing flat z=0 face on the bed. Carrier
tabs and saddle posts remain upright. Other print guidance follows the existing
part guides; do not infer actual fit from a preview. Editable mirror source:
`mechanical/prototype-handed-parts.scad` (`part="carrier"` or `"saddle"`).

## Why the old bench view was insufficient

The J1 joint frame is right handed, but the pitch and carrier placement matrices
in the bench view have determinant-1: they reflect geometry. A reflection can
make a convincing CAD view without establishing how an actual print is fitted.
The asymmetric saddle and carrier require mirrored prints for that intended
bench orientation; this cannot be repaired by servo direction settings.

The current bench-2 checkpoint fixes adapter ribs but still needs its handed
carrier/saddle print selection corrected in a separate build checkpoint. Hold
off printing those two bench parts from that release. Unaffected coupons and
other parts remain useful; existing physical-fit flags remain false.

## Servo cases and verification

All12 MG996R case envelopes use proper rotations. For the assumed rectangular
case, reflection of its symmetric short axis can be replaced by a rigid
orientation with the same case corners and output-shaft axis. The knee case is
clocked90deg, matching the original design. No physically mirrored servo is
required. Actual ears, supplied horns and lead exit may break that simplification;
verify them before purchasing a full set or locking the mounts.

`node mechanical/build-four-leg-working-plan.mjs` regenerates the plan and view.
It checks24 axis-aligned rigid reuse orientations against actual STL vertices,
then verifies every selected mesh at its proper placement against the intended
study geometry at0.001mm coordinate resolution. The two new meshes pass closed/connected/bed checks.
`node mechanical/check-chassis-mount.mjs` checks the corrected mount exports.

`node mechanical/check-handed-correspondence.mjs` independently compares fresh
source CAD exports with the placed carrier/saddle meshes, in both directions,
within0.002mm and0.01% volume, allowing ASCII STL coordinate rounding. This avoids coplanar Boolean failures. See
the task report for the measured result. The bench manufacturing integrity check
continues to pass; integrity must not be confused with physical fit.

The root geometry and link lengths remain unchanged. Rear local pitch remains
opposite global forward; no powered body-to-leg mapping or gait is introduced.
