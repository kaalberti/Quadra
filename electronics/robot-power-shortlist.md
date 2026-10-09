> Superseded MG996R/PWM design reference. Active design is ST3215 12V with3S power; see README.md,docs/st3215-leg-build.md and electronics/st3215-power-plan.md. These quantities,interfaces and mass estimates are not the current ST3215 design.

# Robot-power feasibility shortlist — ELEC-005

Checked public information2026-10-09. No supplier contact or purchase.
Retain the simple common5.2V servo-rail architecture provisionally and measure
one servo/leg before buying a full-robot supply. The30A allowance is a planning
capacity screen, not measured continuous draw. No shortlisted product is locked.

| Candidate | Quantity and price evidence | Relevant limit | Decision |
| --- | --- | --- | --- |
| Hobbywing30606000 UBEC25A HV | One; US$73.99 collection sale / US$107 product MSRP; shipping/tax extra |5.2V setting,25A continuous/50A peak,9–80V main input,74g | Below30A capacity screen; reconsider only after demand measurement |
| Hobbywing30603000 UBEC10A aircraft | Four isolated outputs; NZ$64.99 each =NZ$259.96 incl listed GST, freight extra; out of stock |5V setting,10A continuous/20A peak each,6–25.2V input,36g each | Electrically plausible7.5A-per-leg screen; too costly/complex to lock and not presently available |
| Pololu2881 D24V150F5 | Two isolated outputs; US$79.95 each =US$159.90 before shipping/tax |5V +/-4%,typical15A each depends on input/thermal conditions | Costly;4.8V low tolerance leaves no lead-drop margin; advertised current needs thermal verification |

Technical sources: [Hobbywing25A](https://www.hobbywingdirect.com/collections/storewide/products/ubec-25a-hv),
[Hobbywing aircraft10A](https://www.hobbywing.com/en/products/ubec-10a-2-6s152),
[Pololu2881](https://www.pololu.com/product/2881). Price/availability:
[Hobbywing collection](https://www.hobbywingdirect.com/collections/ubec) and
[RC Hobbies NZ](https://www.rchobbies.co.nz/hobbywing-30603000-10amp-ubec-2-6s/).
Prices are a dated comparison, not a quotation or a currency conversion.

Do not confuse30603000 with30603003: the latter is the10A-Car product with
6/7.4/8.4V outputs and does not fit the current5.3V buffer rail maximum.
[Current regional product](https://www.hobbywingdirect.com/products/ubec-10a).
Peak current cannot substitute for continuous capacity. Two15A outputs or
four10A outputs supply separate groups; they must not be joined in parallel.

A split-output alternative would require a revised signal-buffer power map:
the current three-chip plan crosses leg boundaries. Power each buffer/output
only from the associated servo domain and define disabled behavior for a missing
rail before adopting that architecture. Do not connect separately regulated
positive outputs through buffer VCC wiring. Grounds may be common as required
by control; load returns still belong at each distribution point.

The four-BEC price alone consumes26–52% of theNZ$500–1000 project range.
PROJECT.md's approximately10% repeated-component threshold requires explicit
approval before locking such a selection. No approval is needed to retain
this unselected comparison. A single25A unit is simpler, but buying it now
would silently discard the existing capacity margin. Neither is justified yet.

Main protection/cutoff, battery input wiring and post-regulator servo wiring
need actual ratings and voltage-drop checks with the chosen supply. A switch
on a BEC is not automatically rated power isolation. Battery protection,
polarity, regulator transient behavior and buffer rail voltage remain untested.
Do not copy the18AWG bench main path into a24A servo bus. Split supplies remove
a common high-current5V positive bus but add branches, regulators and fault cases.

Next power decision needs measured startup/loaded current and minimum servo
voltage for one real leg, actual regulator thermal behavior, landed price and
mass. Keep the battery/regulator/fuse/wire/connector fields TBD. The2kg mass
record remains unmeasured; regulator mass is part of its existing allowance,
not an extra mass to add twice. No new BOM purchase is released.
