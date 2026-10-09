# Experimental integrated four-leg assembly

Open `mechanical/prototype-integrated-four-leg-assembly.scad` or its PNG preview.
The print/placement list is `mechanical/integrated-four-leg-print-manifest.json`:
93 pieces across21 unique STLs,12 proper servo-case poses and unchanged bench
geometry/body layout. This is working CAD, not a replacement manufacturing kit.

New part hands:

| Leg diagonal | Integrated hip | Upper/lower pitch forks |
| --- | --- | --- |
| Front-left / rear-right | Original | Mirrored |
| Front-right / rear-left | Mirrored | Original |

Other printed pieces retain their previous physical placement and hand choices.
In particular, front-left/rear-right still use mirrored knee saddles. Select
the actual supplied STL hand; a reflection matrix is not a physical placement.
All placement matrices have determinant+1 and orthonormal axes. The integrated
hip's hand names differ from the old separate carrier because its source already
contains the intended world-frame carrier geometry.

Regenerate with `node mechanical/build-integrated-four-leg-plan.mjs`. The builder
verifies baseline and new hip evidence hashes, checks all21 meshes for closed,
connected bed-sized geometry and reconciles the93-piece count. It creates the
variant mass input only if absent, preserving subsequent entered measurements.

Run `node mechanical/check-integrated-four-leg.mjs` for fresh source/placement
correspondence and nominal new-part/chassis checks. The checker covers all60
new hip/fork versus deck/mount pairs: disjoint actual-mesh bounds prove52 clear;
the eight remaining pairs are individually checked with CGAL. A combined union
export failed CGAL and was not counted. `--reuse-source-exports` is allowed only
for existing successful exports newer than every source dependency. Reports bind
input and source-export hashes. This does not qualify a continuous motion sweep,
actual servo ears/horns/leads, printing, structural strength or loaded operation.

## Variant mass recording

Use `mechanical/integrated-robot-mass-inputs.json` for slicer or measured unit
weights, actual servos/bearings/fasteners, selected power hardware and complete
measured robot weight. Fields are null until evidence exists. Run:

```text
node mechanical/check-robot-working-mass.mjs --integrated
```

The source-bound report is `mechanical/integrated-robot-mass-check.json`. The
default command still checks the old117-piece reference model unchanged.
The variant currently screens2.178kg:782g assumed prints,367g estimated
fasteners,660g servos,40g bearings and330g other allowances. Solid PETG CAD
prints total1203g; the65% material fraction is an example, not an infill setting.
Only604g remains for prints under those other assumptions, corresponding to
50.2% of solid CAD. Actual status remains NOT_MEASURED;2kg is preferred,qualified maximum TBD.

Buying quantities are in docs/purchasing-bom.md. Verify one printed/assembled
leg and actual servo duty before bulk purchases. The supported bench pack,
physical-test list and current offline firmware gates remain in place.

Current [mass policy](servo-qualified-mass.md):2kg is preferred;heavier is allowed within demonstrated servo/power duty. No physical qualification is recorded.
