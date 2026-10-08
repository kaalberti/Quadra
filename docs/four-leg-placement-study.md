# Four-leg placement study — MEC-155

Editable view: `mechanical/prototype-four-leg-study.scad`; preview beside it.
This arranges the existing supported bench-leg design, omitting bench adapters.
The raised deck is a space claim, not an attached, printable chassis. No new
manufacturing parts or hardware purchases are released by this study.

## Placement

Body axes are +x forward, +y left, +z up. Root rectangle is provisionally
150 x110mm at z120mm; the deck is180 x110 x4mm with its underside at z155mm.
ESP32 and PCA placeholders are70 x35 x20mm and65 x30 x15mm, respectively.
These are unmeasured space reservations, not actual board dimensions or holes.

For a bench-frame point `[x,y,z]`, the body point is
`[f*(75+x), s*(55+y), 120+z]`. `f` is +1 front/-1 rear; `s` is +1 left/-1 right.

| Leg | f,s | Geometry transform | Nominal foot reference, mm |
| --- | --- | --- | --- |
| Front left | +1,+1 | Original | [160,87,0] |
| Front right | +1,-1 | Mirror local y | [160,-87,0] |
| Rear left | -1,+1 | Mirror local x | [-160,87,0] |
| Rear right | -1,-1 | Rotate180deg about z | [-160,-87,0] |

Rounded reference footprint is320 x174mm. Pad centres are at y=+/-88mm;
the distinction follows the existing1mm reference/centre offset. Four nominal
points have the same height within0.001mm. This is not a standing/load result.

The front/rear arrangement deliberately points each bench leg's85mm offset
away from the body centre. Rear local pitch directions therefore reverse
relative to the project's global forward convention. Firmware must implement
explicit body-to-leg transforms and servo direction calibration before using
this arrangement; this study does not change the global convention.

## Common and mirrored parts

The original leg geometry can be reused on front-left/rear-right via rotation.
Front-right/rear-left need a mirrored assembly variant. Symmetric bearings,
spacers and commodity fasteners remain common. Do not order mirrored servos:
CAD reflection of the case is only a packaging envelope. Actual servo orientation,
horn indexing, clamp/support relationship and cable relief need to be resolved
with the physical servo. Each asymmetric printed part must be checked for
whether rotation suffices or a mirrored print is required. Current released
STLs remain a single bench-leg set, not a four-leg kit.

## Checks and next action

`node mechanical/check-four-leg-study.mjs` checks nominal reference symmetry
against the independently CAD-checked compiled FK tool, and CGAL intersections
of the12 case envelopes with the deck and between different legs. Run
`firmware/test.ps1` first if the FK executable is absent.

Those nominal case intersections are empty. The assembly preview was inspected.
Complete printed-leg/deck intersection is checked separately using
`mode="leg-deck-collision"` and is empty at the nominal pose. The checker
includes this slower check when run with `--full`.
Cable, ears, horns, actual board fit, all swept joint angles and actual servo
handedness remain unverified. Board placeholders are fully above the deck.

The next design unit is a removable chassis attachment for the existing J1
cradle/support mounting slots. Retain service access, use common M3 fasteners,
and resolve the unsupported deck height and mirrored variants before releasing
a body print. No structural optimization or gait is needed at this point.
