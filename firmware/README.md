# Individual-servo bench controller

FW-001 supports one explicitly armed servo at a time. This has been compiled
for a provisional ESP32-S3-DevKitC-1-N8, not flashed or tested on hardware.
Read ../electronics/bench-wiring.md first. Verify your actual board pins,
servo voltage and PSU capacity. Keep the servo rail OFF during setup/reset.

## Build and tests

From the repository, run `firmware/build.ps1` and `firmware/test.ps1`.
The embedded build uses PlatformIO Core6.2.0 and project-local copies of
Espressif platform7.0.1, Arduino-ESP32 package3.20017.241212 and Xtensa
8.4.0. No third-party servo library is required. Wire is bundled with Arduino.
The local cache is ignored by Git; a clean checkout needs these build tools.

Host tests execute the same C++ controller, parser and PCA driver through
mock I/O. Portable Zig0.13.0 is used solely as a host C++ compiler, downloaded
from [the official distribution](https://ziglang.org/download/index.json).
Archive SHA256: d859994725ef9402381e557c60bb57497215682e355204d754ee3df75ee3c158.
All compiler/build caches stay in firmware/.pio-core or firmware/test-output.
Generated target: .pio/build/bench-s3/firmware.bin. No upload command is run.

## Serial commands —115200 baud, newline termination

| Command | Effect |
|---|---|
| `status` | Report state/fault/last channel and pulse; does not extend timeout |
| `arm 0` / `arm 1` / `arm 2` | From DISARMED, full-off all outputs, set selected channel1500us, then lower OE |
| `pulse 1450` .. `pulse 1550` | Change the armed channel within the narrow initial window |
| `keepalive` | Extend armed session if configuration and I2C are healthy |
| `disarm` | Raise OE immediately and write full-off; never clear a latched fault |
| `reset` | Raise OE and reinitialize; leave DISARMED if successful; rail OFF first |

An armed session requires a valid pulse or keepalive at least every1.5s.
Timeout, bus failure or invalid command while armed latches FAULT. Configuration
is checked every100ms while armed and before every move/keepalive. Recovery
requires diagnosis, physical power cutoff, then explicit reset and arm.
An arm command cannot change channels during an armed session; disarm first.
There are no joint-angle commands, calibration, IK, Wi-Fi or gait control.

Startup raises OE before I2C setup. The driver uses3.3V I2C at100kHz,
address0x40, MODE1=0x20 and MODE2=0x04. It programs prescale121 while asleep,
waits600us after waking, and individually full-offs all16 outputs before arm.
These sequences follow the [NXP PCA9685 datasheet](https://www.nxp.com/docs/en/data-sheet/PCA9685.pdf).
An existing sticky EXTCLK setting requires a PCA logic power cycle.

With a nominal25MHz oscillator, prescale121 yields50.0288Hz and4.88us/tick.
Requested1450/1500/1550us map to297/307/318ticks (1449.36/1498.16/1551.84us).
These are nominal values; measure actual PWM before widening travel or
attaching a horn. The narrow window is for an unmounted servo, not a known
safe range for the assembled leg. Register readback cannot verify physical
OE wiring, output pulse voltage, MCU lockup, or servo power/current.

Removing signals can leave a digital servo holding. Use the physical power
cutoff for isolation. No physical safety, fit or loaded-duty result is claimed.
