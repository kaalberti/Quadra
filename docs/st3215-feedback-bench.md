# ST3215 single-servo feedback bench — FW-010

This separate project is `firmware/st3215`. It is compiled for the reported
ESP32-S3 N16R8, not flashed or physically validated. The generic DevKitC layout,
16 MB flash and 8 MB OPI PSRAM configuration still need board confirmation.
This stage reads feedback and permits explicit torque-off with register readback.
It cannot command position, enable torque, scan/change IDs or write EEPROM.
The selected servo is the standard **12 V ST3215**, not a 7.4 V variant.

## Wiring and initial setup

Use one unmounted servo with its horn removed and case restrained. It may hold
or move when power is applied: firmware startup does not change its stored state.
Keep it supported throughout. Use the adjustable PSU at **12.0 V**, with a current
limit suitable for this unloaded trial and the actual wiring. Confirm polarity,
wire protection and accessible manual power disconnect before enabling its output.
No battery or three-servo trial is covered by this procedure.

Use a compatible half-duplex TTL adapter; the candidate is Waveshare Bus Servo
Adapter A. Confirm the received board revision and electrical levels before
connection. With all power off, set its UART jumper to **A**, disconnect its USB,
and connect its labelled **RX to ESP RX**, **TX to ESP TX**, plus common GND, as
shown in the [manufacturer wiring example](https://docs.waveshare.com/Bus_Servo_Adapter_A/Product-Wiring-Example).
This board's labelling is significant; verify the actual adapter instructions.
Servo D/V/G connects to its bus socket using the confirmed cable pinout. Connect
external servo power according to that board's schematic/labels. Power the ESP
from its USB independently; never put servo supply voltage on ESP UART/5 V pins.
The adapter is a 5 A candidate for this one-servo bench only; full robot power
requires external protected distribution, as described in the power plan.

GPIO4 and GPIO5 are an example, not a finalized harness. Verify they are exposed
and unused on the actual board; remove old PCA9685 wiring sharing those pins.
The console accepts distinct pins only within GPIO4..7. UART is disabled at
startup. Select pins while the servo rail is off. Reconfigure only after closing
with the rail off. The textual acknowledgements do not sense electrical state.

## Console sequence

Use a 115200 baud console on the board's verified Arduino Serial interface.
Native USB CDC versus USB-UART bridge depends on the received board and remains
unverified. The build scripts never upload or open a serial port.

1. Boot/reset ESP with the servo supply OFF; check `BUS DISABLED`.
2. Enter `bus 4 5 rail-off one-servo` after confirming those actual RX/TX pins.
3. Enable the one-servo 12.0 V supply with the servo supported.
4. Enter `ping 1`, then `feedback 1` for a servo whose actual ID is 1.
   Use its known ID if different. Default baud/ID must be confirmed on hardware.
5. Enter `off 1 supported one-servo`. Success is `OK TORQUE_OFF_READBACK`:
   torque register 40 was read back as zero. Check physically that release behaves
   as expected. This is not proof of de-energization or a hardware emergency stop.
6. Turn servo supply OFF, then enter `close rail-off` before rewiring/reset.

`status` reports whether the UART is enabled and the last transaction fault.
It always reports torque UNKNOWN rather than a cached physical condition.
`feedback` publishes one fresh result only after both the feedback block and
separate torque-state read succeed. Any error discards the sample. There is no
automatic polling or retry. Read replies have a 25 ms timeout; a successful
feedback operation involves two transactions, not a synchronized snapshot.
Torque-off attempts a RAM write, waits 2 ms, drains a possible write reply and
reads back the register. A lost reply leaves torque unconfirmed: use the physical
disconnect. Communication loss does not automatically release torque.

## Protocol and result interpretation

The original implementation follows Waveshare's public
[SMS_STS register definitions](https://raw.githubusercontent.com/waveshare/Servo-Driver-with-ESP32/main/SCServo/SMS_STS.h),
[feedback decoding](https://raw.githubusercontent.com/waveshare/Servo-Driver-with-ESP32/main/SCServo/SMS_STS.cpp)
and [packet implementation](https://raw.githubusercontent.com/waveshare/Servo-Driver-with-ESP32/main/SCServo/SCS.cpp).
No servo library or new build dependency was added.

Packets use `FF FF ID LENGTH INSTRUCTION PARAMETERS CHECKSUM`; status replies
substitute an error byte for the instruction. The checksum is the one's complement
of the sum from ID through the final parameter. Only selected IDs 1..253 are
accepted; broadcasts are unavailable. Reply ID, payload length, checksum and device
error must all pass. Noise and decoder storage are bounded.

| Field | Register(s) | Console meaning |
|---|---|---|
| Position | 56–57 | Little-endian signed magnitude, sign bit15; uncalibrated counts |
| Speed | 58–59 | Signed magnitude, sign bit15 |
| Load | 60–61 | Signed magnitude, sign bit10; raw, not Nm |
| Voltage | 62 | Tenths of a volt |
| Temperature | 63 | Raw manufacturer feedback value |
| Moving | 66 | Raw status byte |
| Current | 69–70 | Signed magnitude, sign bit15; raw, not amperes |
| Torque state | 40 | Separate raw register read; zero is requested for off |

The feedback block is registers56..70 (15 bytes). Load/current scaling and physical
angle accuracy require measurements; counts are not a calibrated joint angle.
Direction, offsets, joint limits, goal writes, ID changes, multi-servo control and
communication-loss policy belong to later commissioning tasks.

## Build and independent checks

With existing project-local tool cache available, run `firmware/st3215/build.ps1`
and `firmware/st3215/test.ps1` from PowerShell on this workstation. If local script
execution policy prevents running wrappers, use the equivalent direct commands;
do not change global policy. See `firmware/README.md` for existing tool setup.
The wrapper uses parent `firmware/.pio-core` and Zig0.13.0; PlatformIO environment
`st3215-feedback-s3` pins espressif32@7.0.1. No upload is included.

Validation on 2026-10-09: ESP32 image compiled successfully; 86 protocol/command
checks and 10 console checks passed with warnings treated as errors. Tests cover
exact request packets, malformed replies, ID/device errors, truncation/noise,
timeout including clock wrap, signed decoding, discarded stale samples, off
readback with/without ACK, startup without UART traffic, command rejection,
line overflow/binary input and disabled-bus refusal. Mock tests cannot qualify
wiring, electrical levels, actual return settings, servo timing or torque release.
The physical tests in `PHYSICAL_TESTS.md` remain pending. No motion stage begun.
