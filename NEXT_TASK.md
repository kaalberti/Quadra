# MEC-171 — Fit-tunable ST3215 leg interfaces

Retain current nominal leg geometry and hardware architecture. Make upper/lower
lengths and hip offset drive the CAD, allow separate front/rear wheel spacer
thicknesses, and provide small 29 mm grip-band clamp coupons alongside the
conservative 35 mm default. Avoid guessing the actual case/ports or rear support.

Check default and coupon meshes/bore access, independently check spacer fit and
that parameter changes move the intended interfaces. Regenerate source-bound
validation and preview; update build guide, parameters, risk register and status.
No new power/control stage, purchases or manufacturing release.

Acceptance: existing three sampled collision poses pass; all current print parts
and coupons are connected, closed and bed-oriented; adjustable parameters affect
actual geometry. Actual servo fit remains provisional until tested.

Completed: ten default/fit-coupon meshes and tray pass; six sampled intersections are empty; grip-coupon bores and five mesh parameter perturbations pass; fourteen artifact regression tests pass. Preview visually inspected. No following stage started.
