# Current design review — ST3215 / 3S prototype

Reviewed: 2026-10-09. Scope: current printable one-leg CAD, provisional battery
tray, power/control plan, buying BOM, validation checker and physical-test plan.
This register records findings; it does not approve hardware for powered use.

The architecture is a plausible affordable prototype direction. Its main gaps
are real servo interfaces, protected electrical implementation and control
firmware. Additional detailed structural analysis is unlikely to help as much
as testing one servo kit and one printed leg. A complete walking robot has not
yet been designed or qualified.

## Evidence and limits

- [Leg CAD](../mechanical/st3215-leg.scad), [build guide](st3215-leg-build.md)
  and [validation report](../mechanical/st3215-leg-check.json): eight leg meshes and two alternative fit coupons, axis/contact checks and three sampled collision poses passed.
- [Battery tray](../mechanical/st3215-battery-tray.scad) and
  [tray guide](st3215-battery-tray.md): printable geometry, not verified pack fit.
- [Power plan](../electronics/st3215-power-plan.md), [BOM](purchasing-bom.md)
  and [physical tests](../PHYSICAL_TESTS.md): planned components and tests,
  not implemented protection, actual current measurements or completed tests.
- Current report hashes match both CAD sources, the validation generator, ten part/coupon STLs and tray STL.
  This checks artifact identity; it does not repeat or extend the CAD checks.
- No servo, battery, print, firmware or loaded leg has been physically validated.

## Risks and checks

Priority is the milestone affected, rather than a speculative numerical score.
A later-stage issue does not block current documentation or a cheap fit coupon.

| ID / resolve before | Evidence and risk | Consequence | Smallest useful check or action |
| --- | --- | --- | --- |
| R1 — bulk leg printing | Clamp pocket defaults to 35.8 mm while the referenced main shell band is about 29 mm; drawing-to-actual case shape remains uncertain. The 1 mm split cannot close that difference. Short tail grip also depends on friction and print creep. | Loose servo, crushed case if overtightened, or blocked connector. | Obtain one kit; measure the actual grip band and ports; print one clamp coupon. Adjust the grip parameter or use fitted liners, then check retention without case distortion. |
| R2 — assembled powered leg | Rear wheel/support behavior, wheel face positions and supplied screws are unverified. Front/rear spacers now adjust independently; their default 4.375 mm values still assume symmetric faces. | Binding, bearing preload, stripped threads or a fork attached to a stationary case feature. | Verify both output interfaces; measure each side separately; hand-assemble a fork with correct screw engagement and free movement before power. |
| R3 — motion beyond sampled poses | Collision checks cover three poses and simplified bodies; they omit real cable bends, protruding fasteners and spacer-ring interactions. | Cable damage or a hard mechanical stop while the motor drives. | Route actual cables; move the supported unpowered leg through a conservative intended range; establish limits from observed clearance. Check additional CAD poses only where useful. |
| R4 — loaded leg | Long hip bridge, fork plates and tail clamps have no printed/load evidence. Layer direction, support removal, bolt tightening and warm plastic can affect stiffness. | Deflection, slipping joints or print failure despite a valid STL. | Slice with suitable orientation/supports; inspect the first prints, then apply representative supported foot load and check movement/loosening. Revise locally if needed; no FEA required now. |
| R5 — battery-powered multi-servo test | 60 Wh and the assumed pack size do not establish discharge rating, cell balance, mass or condition. | Excessive sag, hot wiring or damaged cells. | Read the actual label/specification, inspect and balance-check the pack; verify connector ratings and measure staged load/sag. Use a compatible balance charger. |
| R6 — any powered test; scale before multiple servos | Harness, fuses, switch and buck are not selected. The proposed adapter is rated only 5 A; one-leg stall reference is 8.1 A. Three-wire injection can accidentally put aggregate current through small cables. | Overheated connectors/board, shorts or MCU damage. | Fuse the initial single-servo setup; verify polarity/pinout. Design rated parallel power branches with a shared signal ground and explicit injection wiring before scaling. Do not use adapter/perfboard as the main power distributor. |
| R7 — unrestricted battery motion | Full 3S charge is 12.6 V, equal to the published servo upper operating limit. Regeneration/transients and logic supply behavior are untested. | Servo overvoltage, resets or uncontrolled commands after brownout. | Start at current-limited 12.0 V on the bench; verify separate logic regulation and USB/power paths. Investigate supply excursions during starts/stops before unrestricted battery use; a multimeter alone cannot establish fast peak voltage. |
| R8 — unattended or prolonged battery operation | No low-battery protection works yet. Pack voltage can hide a weak cell. Existing manual ADC sense requires sense-positive disconnection before MCU power-off. | Overdischarge or back-powering an unpowered ESP32 input. | Use individual-cell monitoring and manual observation initially; implement supported low-battery stop and safe off-state sensing before leaving the pack connected. Qualify thresholds against the actual pack. |
| R9 — first commanded motion | Existing firmware drives PWM servos; ST3215 firmware, direction, offsets, limits and fault handling are absent. Default IDs may conflict; lost communication behavior is unqualified. | Unexpected movement, continued holding/heating, or collapse on torque removal. | Commission one unmounted servo and one unique ID at a time. Verify feedback, startup, timeouts, recovery and torque release; support the leg/robot during calibration and shutdown. |
| R10 — choosing final mass or walking duty | Stall torque is not a continuous torque rating. Current total robot mass and sustained demand at discharged-pack voltage are unknown. | A robot that stands briefly but overheats, sags or cannot walk reliably. | Weigh the actual assembly; perform one useful stance torque estimate and supported loaded-leg duty test. Adjust stance/geometry or mass if measurements require it; do not treat 2 kg as a qualified limit. |
| R11 — standing on four legs | No complete ST3215 chassis, handed leg layout, battery/board packaging or centre-of-mass/support check exists. Flat foot contact is aligned to the nominal stance only. | Inter-leg interference, tipping, insufficient ground clearance or edge contact/slip. | Lay out four legs and actual masses, revise kinematics for the new datum, and check a simple supported stance/weight shift before crawl. Test inexpensive foot pads if slipping appears. |
| R12 — relying on automated qualification | Link/hip dimensions now drive geometry and parameter perturbations are checked. Nominal pose qualification and some fixed interface dimensions remain deliberately specific to this revision. Tray source and generator are now hash-bound; full swept and physical qualification remain outside these checks. Existing legacy firmware/release outputs remain in the repo. | A future edit or old workflow can appear valid while describing different hardware. | Read-only artifact verification and explicit legacy build/console guards are implemented. Keep geometry/checks coupled when revising CAD; use fit checks after exports. Direct PlatformIO invocation or custom serial tools can bypass these entry-point guards. |
| R13 — ordering all twelve servos | Exact variant, kit contents and landed NZ cost are not confirmed. Quantity multiplies small price differences; power hardware and charger add cost. | Budget overrun or twelve incompatible kits. | Confirm standard 12 V variant and wheel kit with one sample, then price the complete quantity-adjusted BOM including freight/tax before bulk ordering. No supplier contact is needed for this review. |

Manufacturer basis for R6: [Bus Servo Adapter A FAQ](https://docs.waveshare.com/Bus_Servo_Adapter_A/FAQ)
states 5 A maximum board current, no onboard voltage regulation and unique servo
IDs. This supports the existing separate power-distribution direction.
Manufacturer basis for R7/R10: [ST3215 documentation](https://www.waveshare.com/wiki/ST3215_Servo)
and [product specifications](https://www.waveshare.com/product/st3215-servo.htm).
The standard 12 V model lists 6–12.6 V operation, 30 kgf.cm stall torque and
2.7 A stall current at 12 V. These are reference limits, not measured robot duty.

## Assumptions to keep explicit

| ID | Working assumption | How it will be resolved |
| --- | --- | --- |
| A1 | Standard 12 V ST3215, not the 7.4 V or HS variant; published drawing/model matches the purchased kit. The downloaded drawing is labelled SCS215 despite its ST3215 filename. | Compare one actual kit with the drawing and CAD before repeated prints/orders. |
| A2 | Both sides provide compatible wheel interfaces usable for the supported fork; actual kit includes suitable wheels/fasteners. | Inspect rear support behavior and supplied hardware; do not infer it from the case boss alone. |
| A3 | Conventional 3S LiPo, about 60 Wh; 120 x 50 x 20 mm is only the provisional pouch envelope. | Measure label, pack, leads and connector; record mass, condition and discharge rating. No LiHV substitution. |
| A4 | 70/85 mm links and 85 mm hip forward offset provide useful first-leg geometry; nominal foot axial datum is now 0 mm. | Test one leg and then check complete chassis packaging and calibrated kinematics. |
| A5 | Printer/material tolerances, support removal and plain bolt hardware allow the proposed fit. | Slice and print coupons/first parts; inspect actual clearances and tightening stack. CAD fit is not printer fit. |
| A6 | Extra weight is acceptable only where loaded servo/current/temperature tests support it. | Maintain an actual mass tally. Old MG996R mass estimates do not qualify the new robot. |
| A7 | Initial operation is remotely commanded, slow and on a level indoor surface. | Validate static stance and crawl before adding terrain or autonomous operation. |
| A8 | Joint feedback improves control but does not provide calibrated foot force or room position. 4096 counts/revolution is resolution, not guaranteed angular accuracy. | Check measured angles/load behavior; allow for backlash, compliance and foot slip. |
| A9 | Owned 5 A PSU is adequate for staged individual-servo tests, not simultaneous leg stall demand. Runtime estimates are illustrative. | Measure actual supported motion current; qualify supply behavior and battery runtime later. |

## Future work, in useful order

1. **Verify one servo kit and first printed interfaces.** Measure case/wheels,
   revise clamp/spacers if needed, and hand-assemble a supported unpowered leg.
   Pass: snug retention, free output movement and usable screw/cable access.
2. **Bring up one ST3215 safely.** Define the adapter wiring and implement minimal
   ESP32 bus control, feedback, unique IDs and safe startup/fault handling.
   Pass: repeatable commanded/measured positions and intentional supported shutdown.
3. **Complete protected power and battery implementation.** Select affordable
   rated distribution, fuses, disconnect, logic buck and cell monitoring; keep
   high-current paths off perfboard. Pass: checked wiring/polarity and staged
   current/sag/temperature tests using the actual pack specifications.
4. **Prove one leg under representative load.** Calibrate limits and new kinematics,
   measure stiffness, slip, servo heat and duty current. Pass: a useful repeated
   supported movement cycle without binding, brownout or progressive loosening.
5. **Integrate the four-leg chassis.** Place actual battery/electronics, establish
   handed assemblies, weight/support geometry and wiring access, then prepare a
   current manufacturing checkpoint. Pass: assembleable layout and supported stance.
6. **Progress through standing, weight shifts and slow crawl.** Prove stop/recovery
   behavior first. Pass: repeatable remote movement on the intended floor.
7. **Add sensors when movement is dependable.** Start with IMU and power monitoring,
   then forward ranging for simple obstacle avoidance. IMU yaw drift, foot slip
   and a narrow forward range view limit navigation; mapping needs a separate
   localization plan if it becomes a real requirement.

These are future milestones, not tasks executed by this review. Detailed physical
acceptance checks already live in [PHYSICAL_TESTS.md](../PHYSICAL_TESTS.md).

## Practical improvements

**At the next relevant build:** make clamp grip and each side's spacer thickness
match measured hardware; retain easy screw/tool access; add simple cable strain
relief; smooth tray/strap edges and keep bolt heads away from the pouch. The tray
is an open holder, not an impact enclosure. Include lead clearance, soft padding
and accessible removal/disconnect in chassis placement.

**After the first leg works:** consider cheap locking nuts if joints loosen,
standardize fasteners where the real stack permits, tune supports/orientation
from slicer results and add replaceable grippy foot pads if needed. Shorten the
hip offset or add a local rib only if packaging or observed deflection warrants
it. Reduce duplicated CAD/checker dimensions and separate exports from read-only
verification to avoid accidental changes during a review.

**Defer:** exhaustive load cases, mass shaving, appearance, integrated SMT/PCB
hardware, active ankles, foot-force sensors and mapped navigation. They should
follow a demonstrated need. Perfboard auxiliaries, commodity modules and one-kit
experiments remain the cheaper path to a working first prototype.

## Mitigations implemented without hardware — RISK-001

- **R12 partially mitigated:** `node mechanical/verify-st3215-artifacts.mjs`
  checks both CAD sources, the generator and every expected STL against the
  fresh report, including exact part names, paths and quantities. It is read-only;
  stale or incomplete evidence fails. The generator checks both sources again
  after the final export before recording their hashes. These hashes establish
  recorded artifact identity, not physical safety or correctness of every checker.
- **R9/R12 accidental legacy entry-point use reduced:** PowerShell build/console
  wrappers now refuse unless `-AllowLegacyPwm` is explicit. The Python console
  independently requires `--allow-legacy-pwm` before importing serial or opening
  a port. Intentional legacy work remains possible. Direct PlatformIO/custom
  serial tools are outside these guards; ST3215 firmware is still absent.
- Geometry and power architecture are unchanged. R1–R11 physical/electrical
  qualification and R13 landed-price checks remain open; physical geometry/fit assumptions still need measured verification.

Validation: fresh mesh/bore/contact checks and all six sampled intersections passed.
Twelve artifact tests, twenty-one mocked console regressions, Python CLI refusal
and both PowerShell preflight refusals passed. Verifier execution left all source,
report and STL bytes unchanged. No serial port was opened or hardware flashed.

## Mechanical refinement — MEC-171

R1 has a cheap printable check: two29 mm grip-band clamp halves with the same
mounting pattern as the default35 mm version. This reduces fit iteration cost;
it does not establish the actual band shape, port clearance or retention force.
R2 no longer requires equal front/rear spacer thicknesses: each is derived from
its separately configurable wheel face. Both defaults remain provisional.
R12 link/hip dimension drift is reduced by shared CAD parameters and independent
mesh perturbation checks. Nominal geometry, bought hardware and sixteen installed
prints remain unchanged; the coupons are alternatives, not additional leg parts.
