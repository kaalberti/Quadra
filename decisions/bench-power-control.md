# Bench power/control preparation —2026-10-08

Use the existing bench supply before selecting a battery/BEC. Start with one
unmounted servo and narrow pulse commands. The three-servo planning target is
7.5A at5.2V, pending actual PSU and servo measurements. This does not select a
twelve-servo robot supply.

Keep servo current outside the ESP32 and unverified PWM-board tracks. Supply
the PCA9685 logic from3.3V and use a low-cost AHCT125 buffer for5V servo signals
because the candidate servo's input threshold is unpublished. A physical
cutoff switches both servo and buffer power. OE plus software full-off controls
signals but does not establish power isolation or a certified stop.

The prototype controller stays at individual-servo testing. No mechanical
angle calibration, IK or locomotion is enabled before actual fits and limits
are known. See electronics/bench-wiring.md and firmware/README.md for sources
and connections. The proposed bench parts allocate NZ$55 inside other-parts
budget; existing equipment is reused, actual purchases/prices remain pending.
