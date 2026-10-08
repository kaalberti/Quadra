# TOR-005: provisional nominal-standing duty test requirements

2026-10-08. Status: requirements defined; NOT RELEASED for hardware execution.
This sheet defines a finite-duration holding screen for an individual actuator
at a nominal joint angle. It does not qualify a standing robot, continuous
duty, walking, transient overloads or an actuator selection.

Sources are the existing [requirements brief](actuator-requirements.md),
[nominal torque screen](static-servo-torque.md), [mass accounting](mass-accounting.md)
and [candidate evidence](../ARCHIVE/2026-10-08-superseded-design/docs/actuator-candidates.md). No manufacturer ratings are
added or refreshed in this task. All numerical test targets below are new,
provisional engineering choices, not user requirements or product ratings.

## Bounded scenario and rationale

| ID | Provisional test requirement | Rationale / interpretation |
| --- | --- | --- |
| DT-01 | Hold for 600 s without unloading after settling; three runs per released joint/load configuration on the same identified unit. | A practical ten-minute standing demonstration screen; repeats check repeatability, not production variation. |
| DT-02 | Ambient 25 +/-2 degC throughout; no forced cooling. Record mounting, enclosure and airflow. | A reproducible indoor scenario, not outdoor or maximum-temperature qualification. |
| DT-03 | Before each run, actuator case within 2 degC of ambient for 300 s; also use internal temperature if available and include its sensor uncertainty. | A reproducible cooled start; not proof every internal part has equilibrated. Do not use a fixed short rest interval instead. |
| DT-04 | Allow up to 10 s for settling after the prescribed load application ramp. Thereafter absolute joint-output angle error <=2 degrees for the full 600 s. | A provisional static accuracy target to expose droop, not a foot-placement or gait accuracy specification. |
| DT-05 | Applied torque within +/-5% of the released nonzero target throughout the hold. | Controls test comparability; target itself must include a justified uncertainty allowance. |
| DT-06 | Log angle, command, applied torque, terminal voltage and current at >=50 samples/s; case and ambient temperature at >=1 sample/s. | Resolves gross holding behavior and thermal trends. Faster current protection/acquisition is separately required if transients demand it. |

The minimum recorded full holds total 3*600 = 1800 s (30 minutes) per
configuration. Settling, ramping and cooling are additional and cannot count
toward this total. A future deployed use profile involving warm restarts or
longer sessions requires another qualification scenario. Passing these three
cooled-start runs must not be described as a continuous half-hour session.

Use the unchanged geometric nominal angles (q1,q2,q3) =
(0,44.048625674,78.978550364) degrees as reference joint positions. Servo
neutral and direction mapping must be calibrated for the eventual fixture;
these values are not direct servo commands. Use independent output-angle
measurement, not only command or internal feedback.

## Load definition: required before release

For each joint/configuration record the signed resisting torque, direction,
angle, applied-load mechanism, calibrated uncertainty, load ramp and verified
mechanical support. The actuator must balance that torque at the joint output.
No external reduction is assumed approved. A transmission requires explicit
mapping and losses; record which shaft is measured.

TOR-001 quarter/third/half-weight knee magnitudes are
0.143183/0.190911/0.286367 Nm; corresponding q1 values are
0.073550/0.098067/0.147100 Nm. These may label contact-only characterization
points, but they are not released total test torques. Hip-pitch contact zero
is not a zero-load qualification requirement. Use TOR-003 signed distal
gravity corrections with a complete, justified inventory and compatible
contact reactions; then bound load uncertainty and losses. Do not add distal
mass twice or assume the half-weight case is brief. No target load is selected
by this sheet, and no loaded run is released while it is unknown.

A zero-load baseline is diagnostic only; the percentage load criterion cannot
apply at zero. A future zero-load run needs an absolute torque tolerance.
Fixture calibration must include its own gravity, friction and lever-arm
variation with angle; hanging mass alone does not prove constant torque.

## Instrumentation and record requirements

Use synchronized timestamps and record raw values, units, calibration dates,
sensor location and uncertainty bounds. Keep internal telemetry separate from
independent angle, torque and case-temperature measurements. Document the
case sensor attachment and the surface monitored; case temperature is not
automatically winding, electronics or gear temperature.

For acceptance, use conservative interval comparisons: abs(angle error) plus
its uncertainty <=2 degrees; abs(torque-target) plus torque uncertainty
<=0.05*abs(target). Apply the same containment principle to ambient, cooled
start and all released safety limits. Define uncertainty bounds before testing;
instrument resolution alone is not a measurement uncertainty estimate.

Record unit ID, model/revision, firmware/settings, supply and current limit,
terminal voltage range, fixture/support details, load target/ramp, channel
rates, ambient, initial temperatures and per-run result. Save continuous raw
logs and a summary containing max angle error, torque extrema, current peak
and mean, voltage extrema, temperature maxima and final five-minute trend.
Trend is descriptive; a small observed slope is not a thermal-equilibrium proof.

Within scored intervals, gaps >0.04 s in fast channels or >2 s in temperature
channels invalidate that run's acceptance evidence. Missing required channels,
uncertainties or timestamps cannot yield a pass. Average log rates alone do
not demonstrate these gap requirements. Logging does not replace protective
monitoring; shutdown response must be established independently.

## Release inputs and stop conditions

| Required release input (currently OPEN) | Evidence / rule |
| --- | --- |
| Exact unit and permissible supply range | Resolve conflicting manufacturer voltage statements for that unit; choose test voltage and terminal tolerance within supported limits. |
| Signed load, uncertainty and ramp | Complete the load calculation and fixture calibration above; record duration and load direction. |
| Temperature stop thresholds | Obtain applicable internal and/or case limits with sensor locations, uncertainty and response margin. Ambient operating ranges are not case or winding limits. No universal numeric temperature threshold is invented here. |
| Current and electrical protection | Justify continuous/pulse limits and trip response for actuator, supply, wiring and connectors. Stall-current figures are not sustained-current limits. |
| Mechanical containment and isolation | Verify fixture/load capacity, supporting bearings and controlled unloading after power removal. Provide accessible independent power isolation; do not route servo power through an ESP32 board. |
| Measurement/protection implementation | Verify calibration, bandwidth, timestamps, independent stop response and all threshold values before a loaded run. |

Stop on any released thermal/electrical threshold, loss of critical monitoring,
fixture movement, uncontrolled motion, binding, visible damage or abnormal
operation. Stop when post-settling tracking error exceeds the target after
accounting for uncertainty; do not run to stall to complete the timer. Record
all events even if the unit later cools or recovers. Protection-trip limits
must include uncertainty, sensing lag and shutdown overshoot; a successful
600 s timer never overrides a trip. A safe load-retention/unloading method
must be in place before cutting actuator torque.

Ambient/load tolerance departures terminate scoring and require investigation;
do not silently delete those samples. Loss of safe monitoring requires stopping
the load as well. Candidate selection, fixture design and execution remain
separate future tasks; the table is a release dependency, not an approval request.

## Result classification and limits of the claim

- **Scoped pass:** all release inputs closed, all three complete runs satisfy
  measured criteria including uncertainty, no trips or damage, and a post-run
  unloaded function check shows no new fault relative to its recorded baseline.
  State exact unit, joint/load, voltage, mounting, ambient and cooled-start duty.
- **Fail:** tracking, thermal/electrical protection or physical integrity fails
  under otherwise valid specified conditions. An early stop is not a shorter pass.
- **Invalid/inconclusive:** missing evidence, calibration, release inputs,
  incorrect load/environment or logging gaps prevent evaluation. Preserve any
  observed failures; an invalid setup is not proof of actuator inadequacy.
  Correct the cause before a new complete run; retain the original record.

There is no result yet. Three runs on one unit provide no reliability or
manufacturing-variation guarantee. After an alarm, also meet the unit-specific
recovery requirements in [TOR-006](../ARCHIVE/2026-10-08-superseded-design/docs/actuator-protection-evidence.md); ordinary
cooled-start conditions alone do not permit restart. The reviewed ROBOTIS
manuals require at least 20 minutes cooling after an overheating alarm.
There is no automatic restart or retry authorization.
Even a scoped pass leaves TOR-002 full
load envelope, repeated motion, peaks, assembly support and whole-robot power
requirements open. Finite holding does not establish indefinite holding.

## Next bounded task (not executed)

Create a manufacturer-evidence gap closure matrix for the three TOR-004
candidates: available temperature/current limits with their precise meanings,
sensor locations and missing confirmations needed for this test. Use primary
sources; do not send inquiries, select a winner, design the fixture or run
hardware. If limits remain undocumented, report them as unresolved rather
than substituting operating ambient or stall ratings.
