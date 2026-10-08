# Side-on fork fit coupon

Print `mechanical/prototype-fork-fit-coupon.stl` on the K2 Pro in its supplied
orientation. It is36 x78.2 x32mm. The long connector sits on the bed; do not
lay either round interface plate flat, because this test concerns the new
side-on fork printing orientation.

The coupon contains the actual upper fork's horn plate and rear bearing seat,
cropped around the interfaces and joined by a smaller coupon-only connector.
The seat is13.2mm diameter x5.2mm deep for a nominal13 x5mm624 bearing. Retainer
holes are3.5mm diameter on22mm centres. Horn slots and centre opening retain
the fork geometry. The connector does not reproduce the full fork's stiffness.

Use your normal PETG material preset. As a provisional starting profile, use
0.2mm layers and four walls; use the same layer/material/wall profile later
when printing the forks. Inspect the slicer preview for local supports under
the curved plates and horizontal bores. Keep support interfaces accessible for
removal and add a brim if needed. Record actual support settings rather than
assuming this is a support-free print. The CAD estimate is17.6g solid PETG;
infill, support and brim change filament use. No slicing or printing was performed.

1. Inspect the slicer layer preview, print, and remove supports without enlarging
   the bores. Check for sagged slots, cracks or damaged seat lips.
2. Once available, insert a624 bearing from the outer rear face. It should seat
   flat without splitting the print or needing destructive force. Record any
   looseness; do not glue it before assessing fit.
3. Fit the existing `hobby-joint-retainer.stl` with the existing specifiedM3
   fixings. Verify hole alignment and access. Check that the bearing is retained
   and that the centre opening clears the intended pivot/spacer stack.
4. Once the actual MG996R horn is available, check the horn plate's centre and
   fixing slots, fastener/head access and horn seating. The guessed horn pattern
   is not qualified by a successful bearing test.
5. Record material, settings, support removal, mass, bearing/retainer fit and
   actual horn fit before printing a complete experimental fork. Revise fit
   dimensions from this evidence only if needed.

Current results: print/support removal **NOT_PERFORMED**; bearing/retainer fit
**NOT_PERFORMED**; horn fit **NOT_PERFORMED**. Bearing, servo/horn and fixing
hardware are already on the first-leg buying list; no extra purchase is added.
The coupon does not qualify loaded strength. Full-fork and gradually loaded
assembled-leg tests remain separate, and the supported manufacturing kit stays
unchanged.

Regenerate the STL with the project-local OpenSCAD, then run
`node mechanical/check-fork-fit-coupon.mjs`. The check independently verifies
closed/connected surfaces, bed bounds and27 clear/blocked mesh rays through
the actual fixing slots, seat wall/floor and centre openings. Its report is
`mechanical/fork-fit-coupon-check.json`.
