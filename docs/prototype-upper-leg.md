# MEC-133:70 mm upper-leg mount

Created a flat upper plate and a separate knee-ear saddle. They replace the
hip fork's old front arm with a plate extending to the knee axis70 mm away.
The knee servo body is clocked90 degrees to the link and is supported by its
mounting ears, avoiding another complete case clamp. This is still a provisional
single-leg mechanical design, not a complete3-DOF leg or a tested mechanism.

## Interfaces and assembly changes

In the local assembly, the hip axis is the z line through(0,0); the knee axis
is the parallel line through(-70,0). Both assumed horn faces lie at z=50 mm.
The source preview rotates the upper link44 degrees around the hip axis.
This retains70 mm centre distance; it does not silently change25/70/85 mm
historical kinematics or desired ranges.

Move the hip bridge from x=-58 to x=+58. Rotate the existing rear arm180
degrees in its plane so its two bridge holes follow that change. Use the new
upper plate instead of the old front arm. Existing hip bearing, retainer,
spacers, cradle/support and long bridge bolts are reused. This is a new upper-leg
assembly variant; the older bench-joint source and exports remain unchanged.

Print `prototype-upper-leg-plate.stl` flat and
`prototype-upper-leg-saddle.stl` on its ring base. Both exports sit at z=0;
no supports are intended. Use the existing PLA+/PETG0.4 mm nozzle /0.2 mm layer
settings and four walls. The ring is3 mm thick, plate5 mm, and saddle post7 x16
mm. The saddle post is22 mm high including the ring; its two mounting bolts
pass vertically through the post and upper plate. Use two M3 x40 bolts,
washers and nuts. Mount the actual knee ears with four M3 x12 bolts, washers
and nuts; adjust length for actual ear thickness.

## Fit first

Print `prototype-upper-leg-ear-coupon.stl` before the full saddle. The assumed
body window is21.1 x42.1 mm (0.7 mm clearance per side). Assumed ear holes
are10 mm across and49.5 mm along the case, with3.5 mm holes and2 mm total slot
travel. Ear underside is assumed31 mm above the common servo floor datum.
The source parameter `ear_face_z` changes saddle height if the actual unit
differs. Verify shaft offset, horn face, ear dimensions and cable exit on the
actual servo. Keep screw tips and nuts clear of the case and output horn.

The next knee output fork must include a passive opposite bearing support
before the shaft is loaded. Neither that support nor the85 mm lower leg is
created in this task. Reserve a provisional initial knee range20–90 degrees
for that next design; historical desired20–130 degrees remains unvalidated.
The knee fork's motion around this saddle still needs CAD and physical checking.

## Validation

All three new exports compile and independently pass closed-edge, connected-part
and print-bed checks. `mechanical/check-prototype-upper-leg.ps1` regenerates
the saved JSON report. A conservative saddle rectangle clears the hip cradle
and clamp reservation at one-degree samples across q2=-40 to85 degrees;
minimum separating-axis gap is10.48 mm. This is sampled nominal geometry,
not a continuous proof or a real horn/cable/fastener clearance guarantee.
The plate is4.1 mm above the assumed case face; the bridge retains the previous
radial bound. The assembled preview was visually inspected.

Assuming PETG density1.27 g/cm3, the knee saddle is7.8 g at fully solid density
versus26.2 g for the former case clamp alone, about70% less case-holder volume.
The new rear bearing support is still required and is excluded from that
comparison. The new upper plate is17.7 g solid. Slicer and measured mass supersede
these estimates. The55 g knee servo plus saddle has a maximum gravity moment
of about0.043 Nm at70 mm; full lower-leg loads and sustained servo capability
remain unverified. No detailed structural stress optimization performed.

The maintained buying list is [purchasing-bom.md](purchasing-bom.md). It gives
current upper-assembly hardware counts and separately labels future leg/robot
quantities. No parts were bought and no physical test results were invented.

Next suggested bounded task: create the knee's passive rear support for this
saddle. The85 mm lower-leg fork follows afterward. Stay in stage4; no chassis
or electronics stage started.
