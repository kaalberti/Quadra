# Active ST3215 bench firmware

Read [the wiring and operation guide](../../docs/st3215-feedback-bench.md).
This separate ESP32-S3 project supports single-servo ping, feedback and explicitly
acknowledged torque-off with readback. UART starts disabled. No motion, torque-enable,
broadcast or EEPROM command is exposed. Hardware testing and flashing remain pending.

Build: `./build.ps1`. Independent mock checks: `./test.ps1`.
Both reuse existing tools under parent `firmware/`; neither uploads firmware.
