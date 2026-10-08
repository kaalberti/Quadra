# FW-002 — supervised single-servo bench console

Provide a host console for the FW-001 protocol: explicit operator arming and
pulse commands, periodic keepalive only during an acknowledged armed session,
and immediate shutdown on protocol failure, device reboot, fault or exit.
Test with a fake serial transport, including dropped replies and unexpected
state/channel changes. Do not auto-arm, auto-reset, flash or move hardware.

Keep actual hardware commissioning pending. No wider servo limits, calibration,
assembled-leg control, IK or locomotion in this task.
