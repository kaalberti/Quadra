# First physical fit check — MEC-154

Print the four fit coupons from manufacturing/coupons before the full leg.
Record the actual servo, supplied horn, centre screw, bearing and print material
in mechanical/prototype-fit-record.json. No values are filled from CAD.

Cradle pocket reference is41.5 x20.5mm. Check that the halves clamp the actual
case without damage or cable trapping. Measure the mounted shaft x relative
to the cradle centre and horn-face z relative to its base: CAD references
are -10.35mm and50mm. Deviations beyond0.4mm trigger CAD review rather than
force-fitting the fork. This is a prototype screening allowance, not a
manufacturing tolerance certification.

Bearing coupon dots correspond to13.0/13.2/13.4mm seats. Select a seat that
accepts the actual bearing without force and retains it without obvious play.
The current rear-arm STL is13.2mm; a different selected fit needs a regenerated
part. Check the horn coupon and knee-ear coupon against the delivered parts.

After coupon fit, follow the current assembly guide and record each boolean
only from actual observation. Weigh the assembled leg separately from the
bench board/standoffs. Check bearing inner-ring contact, screw tips, passive
alignment, carrier rib relief, fixture rigidity, all three joints and cable slack.
Move gently while unpowered; do not force a geared servo or its stops.

Run with the existing Node runtime; no packages are needed:

```
node mechanical/evaluate-prototype-fit.mjs
node --test mechanical/evaluate-prototype-fit.test.mjs
```

The untouched record reports NOT_MEASURED. READY_FOR_UNPOWERED_ASSEMBLY means
only that the recorded fit prerequisites are complete; it does not qualify
powered movement, current capacity or load capability. Synthetic unit tests
are separate from the real record and never populate it.
