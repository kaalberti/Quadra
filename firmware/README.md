> ST3215 redesign: this is preserved MG996R/PCA9685 PWM firmware. It cannot control the selected serial-bus servos. Do not deploy it for the new leg. See ../electronics/st3215-power-plan.md.

# Individual-servo bench controller

FW-001 supports one explicitly armed servo at a time. This has been compiled
for the user-reported ESP32-S3 N16R8 (16MB flash/8MB OPI PSRAM), not flashed
or tested on hardware. The generic DevKitC pin mapping remains provisional.
Read ../electronics/bench-wiring.md first. Verify your actual board pins,
servo voltage and PSU capacity. Keep the servo rail OFF during setup/reset.

## Build and tests

The build wrapper refuses by default. For intentional MG996R/PCA9685 reference work only, use `firmware/build.ps1 -AllowLegacyPwm`; host tests remain `firmware/test.ps1`. The PowerShell console requires `-AllowLegacyPwm`, and direct Python console use requires `--allow-legacy-pwm`. These do not make this firmware compatible with ST3215. Direct PlatformIO/custom tools can bypass these entry-point guards.
For a new checkout on this Windows workstation, run
`firmware/setup-local-tools.ps1` first. It copies the existing PlatformIO
platform/packages locally and downloads the pinned, checksum-verified host
compiler if absent. It does not install PlatformIO globally. A different
workstation needs an existing compatible PlatformIO installation first.
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

## Supervised host console

Use the existing PlatformIO Python environment, for example:

```powershell
$env:PYTHONDONTWRITEBYTECODE='1'
& C:\Users\Kyle\.platformio\penv\Scripts\python.exe firmware/bench_console.py --port COM5 --allow-legacy-pwm
```

Substitute your verified port. Keep servo power OFF when opening the port:
some boards reset on serial connection despite DTR/RTS settings. The console
accepts a disarmed/faulted device and never arms automatically. A FAULT requires
diagnosis and the explicit operator command `reset rail-off`; this text is an
operator acknowledgement, not a voltage measurement.

Once `arm 0` is explicitly entered, the console sends keepalive every0.4s
while replies match the expected channel/pulse/state. `pulse 1450..1550`,
`status`, `disarm`, and `quit` are supported. Stay at the bench; console
keepalives continue while waiting for keyboard input. Use quit/disarm or the
physical cutoff before leaving. Loss of a reply within0.35s, unexpected state,
device reboot, invalid armed command or exit stops this session and attempts
disarm. It never reconnects or automatically recovers. If disarm cannot be
delivered, the MCU's1.5s command timeout remains the fallback.

Test without hardware:
`python -m unittest discover -s firmware/test -p test_console.py -v`.
These12 transport tests complement the12 C++ controller tests. The console
uses pyserial already present in the existing PlatformIO environment; it does
not enumerate/open ports during testing. No real serial session was performed.

## Offline calibration — FW-003

`include/joint_calibration.h` maps degrees to pulse width from two measured
anchors, in either direction. Usable angular limits must lie inside the anchor
interval; no extrapolation or silent clamping. Invalid/unmeasured profiles fail
without changing output. `joint-calibration.json` remains an unset recording
template, not loaded by firmware. No angle command is enabled on hardware.
Generic500..2500us validation bounds are only an absolute software screen,
not approved servo travel. Tests use synthetic profiles; never copy them to
hardware. Physical calibration and limits are listed in ../PHYSICAL_TESTS.md.

FW-007 adds `calibration_profiles.py` for measured JSON validation, offline
pulse previews and optional C++ header export. It requires all three measured
profiles and keeps every anchor/limit within1450..1550us. It never connects to
hardware or changes the firmware. The current unset template is rejected.
Workflow and commands: ../docs/measured-calibration-profiles.md.

FW-008 adds `offline_leg_plan.py` to run the existing C++ calibrated planner
against a requested foot reference position and explicit branch policy. It
returns a complete offline plan only if measured profiles, trial bounds and
bench pulse limits pass. Current unset records are rejected. No board connection
or powered commands are added. Workflow: ../docs/offline-leg-planner.md.

## Board-only diagnostic

`timing rail-off no-servos` is a manual serial-monitor command while DISARMED.
It temporarily drives only channel15 for3.3V timing capture on GPIO7, then
restores disabled/full-off outputs. FW-009 supports this explicit command in the
supervised console only while disarmed, with optional new-file `--timing-log`
JSONL capture. Do not run a serial monitor and console together. Wiring and limits:
../docs/board-pwm-timing-test.md. No physical capture or flash was performed here.

## Removable voltage diagnostic — ELEC-008

Manual serial command `voltage rail-off no-servos` works only while DISARMED.
GPIO8/ADC1_CH7 uses the provisional150k/10k perfboard divider and100nF filter.
Sixteen readings report nominal input voltage, ADC millivolts and sample spread;
no servo output is enabled and no battery cutoff is implemented. An armed
request trips the command fault. The input is not calibrated against physical
measurements and must be disconnected before ESP32 power is removed.
Wiring, voltage limit, buying delta and later comparison procedure:
[voltage input](../electronics/voltage-perfboard.md). No upload or powered test.
