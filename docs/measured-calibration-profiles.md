# First-leg measured profiles — offline only

`firmware/calibration_profiles.py` validates a completed copy of
`firmware/joint-calibration.json`, previews angle-to-pulse mappings and optionally
exports a C++ header for offline tools. It does not connect to boards, modify
the bench firmware or authorize powered motion. Current project profiles remain
unmeasured and are deliberately rejected.

After the physical checks in PHYSICAL_TESTS.md, record two measured pulse/angle
anchors for each joint. Angles must use the project's joint datum and signs,
not arbitrary servo-shaft markings. Put the lower angle in angleA and the higher
in angleB; pulses can increase or decrease. Record conservative usable angle and
pulse limits inside the measured anchors, channel0/1/2 forJ1/J2/J3 and measured
true only after actual measurement. Keep the blank template intact and use a
separate recording file. Do not copy synthetic test profiles into a real record.

The tool requires all three joints and finite values, rejects missing fields,
wrong units/order/channels, equal anchors, extrapolation and inconsistent limits.
Every pulse anchor and pulse limit must remain within1450..1550us. This preserves
the present software bench window, which itself is not proof of safe motion in
an assembled leg. Wider travel requires a later measured/reviewed change; the
generic C++500..2500us absolute screen is not a travel recommendation.

Using the existing PlatformIO Python environment:

```powershell
& C:\Users\Kyle\.platformio\penv\Scripts\python.exe firmware/calibration_profiles.py firmware/measured-first-leg.json
& C:\Users\Kyle\.platformio\penv\Scripts\python.exe firmware/calibration_profiles.py firmware/measured-first-leg.json --angles 0 44.0486 78.9786
& C:\Users\Kyle\.platformio\penv\Scripts\python.exe firmware/calibration_profiles.py firmware/measured-first-leg.json --header firmware/test-output/measured-first-leg.h
```

These examples require your actual measured file; the nominal angle example is
accepted only if all three measured usable intervals contain it. Validation
and any requested mapping happen before export. An existing header is never
overwritten; choose a new filename for a revision. The header is not included
by firmware automatically. The tool previews requested microseconds, not the
physical PCA9685 tick-quantized or measured pulse widths.

Angles are normalized to float32 to match the existing C++ mapper. Anchors
that collapse at that precision are rejected; positive pulse rounding matches
C++ lround. The JSON preview shows the values used and any mapped pulses.
Passing validates mathematical consistency of the entered record; it cannot
verify that the stated measurements were physically taken.

Run `firmware/test.ps1` for the existing controller/geometry/calibration tests
and five new tool tests, including compilation of an exported synthetic header
against the actual C++ mapper. No new package dependency or hardware purchase.
