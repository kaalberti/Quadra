# First bench test — one unmounted servo

Use electronics/bench-wiring.md and firmware/README.md. Keep the horn removed
and secure one servo. This is independent of the printed leg; neither a
successful trial nor software checks approve an assembled or loaded leg.

Record actual board/servo/PSU identities and observations in
electronics/bench-commissioning.json. Leave unknowns null. Verify the delivered
servo's voltage range from public documentation. Identify the actual PSU's
current rating; set a modest initial limit up to0.5A. If it current-limits,
stop and investigate rather than increasing it to overcome binding.

With servo power disconnected, verify actual GPIOs,3.3V logic/pullups, polarity,
common ground and external rated distribution/fuse. With no servo connected,
measure rail voltage and OE high at startup/reset; verify disabled signals are
low. OE high must exceed0.7×logic voltage and2V; low must be below0.8V.
Test the physical cutoff: it must remove both servo and buffer power. The
checker uses0.2V as a discharged-rail screen, not instantaneous response timing.

An oscilloscope or suitably rated logic analyser can measure nominal20ms PWM
period and1500us centre. Those fields are optional for the first horn-off
trial, but measure timing before wider or mounted motion. A basic multimeter
does not establish pulse width or catch fast voltage dips. No extra instrument
purchase is required just to begin the horn-off test.

After setup checks, connect one servo, enable its permitted rail, explicitly
arm one channel and try a few1450..1550us commands. Record observed rail voltage
and PSU current, current-limiting/reset behavior, response, noise and heating.
Do not put a multimeter in current mode across the supply; use the PSU display
or a correctly fused series measurement. These readings do not qualify stall
current, sustained loaded duty, transients or a three-servo supply.

Run `node electronics/evaluate-bench-commissioning.mjs`. Tests:
`node --test electronics/evaluate-bench-commissioning.test.mjs`.
The supplied record is unmeasured. Synthetic tests never populate it.
Next physical work remains four fit coupons and an unpowered leg assembly.
