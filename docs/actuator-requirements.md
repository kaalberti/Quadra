# TOR-002: actuator performance-requirements brief

Date: 2026-10-08. Stage: servo torque validation.

This brief defines the evidence needed to size actuators. It does not approve
an actuator, transmission, voltage, or final torque rating. TOR-001 remains
the nominal contact-load benchmark; sustainable support is unresolved.

## Fixed references and known benchmarks

Preserve the below-1.2 kg total operating-mass target, twelve rotary actuators,
70/85 mm candidate links, 25 mm outward hip offset, and 120 mm nominal
hip-datum height. Sources: [PROJECT.md](../PROJECT.md),
[standing pose](standing-pose.md), and [joint ranges](joint-ranges.md).
The desired geometric ranges remain q1 [-25,30], q2 [-40,85], and q3
[20,130] degrees, with spans of 55, 125, and 110 degrees respectively.
They are analysis targets, not measured servo travel or collision-free limits.

The following magnitudes are copied from
[TOR-001 results](../mechanical/static-torque.json), using 1.2 kg,
g = 9.80665 m/s^2, vertical upward foot reactions, massless moving links,
and ideal 1:1 drive at the unchanged nominal pose. Units are joint-output Nm.

| Load case | Weight share | q1 abduction | q2 hip pitch | q3 knee |
| --- | ---: | ---: | ---: | ---: |
| quarter_weight | 1/4 | 0.073550 | 0.000000 | 0.143183 |
| third_weight | 1/3 | 0.098067 | 0.000000 | 0.190911 |
| half_weight | 1/2 | 0.147100 | 0.000000 | 0.286367 |

Independent reconstruction uses Fz = share * 1.2 * 9.80665 N and lever
arms of 0.025, 0, and 0.048668802572 m. Multiplying N by m gives Nm.
The underlying signed balancing torques are negative q1 and q3, with q2
zero to numerical precision, on all four legs under the geometric convention.

These are contact contributions, neither guaranteed upper nor lower bounds
on complete actuator demand. In particular, zero hip-pitch contact torque
does not imply zero actuator demand. The third-weight case requires a
matching COM projection; the half-weight case is a redistribution screen,
not a stable two-leg gait or a time-qualified peak event. Four feet do not
guarantee equal loads. See [TOR-001 derivation](static-servo-torque.md).

## Performance requirements and closure evidence

All items below are requirements for later evaluation, not claims of completed
validation. No arbitrary fraction of stall torque substitutes for sustained
capability. No numeric reserve factor, duty duration, or speed is selected here.

| ID | Requirement / current status | Evidence needed to close |
| --- | --- | --- |
| AR-01 Load envelope | All three joints need signed total load histories; nominal contact benchmarks alone are insufficient. Full envelope OPEN. | Mass/COM inventory, feasible stance/step poses, support reactions satisfying whole-body equilibrium, horizontal forces, gravity, acceleration, friction and transmission losses; report assumptions and sensitivity bounds. |
| AR-02 Sustained holding | Capability must cover the maximum total holding demand in approved sustained poses. Torque and duration OPEN. | Define longest uninterrupted hold, total session length, ambient range, mounting/cooling, voltage at actuator terminals, permitted position error and temperature limits. Obtain a supported continuous rating or a representative thermal hold test, including thermal equilibrium for indefinite holding. |
| AR-03 Repeated motion | Capability must cover torque and speed simultaneously through the intended repeated cycle. Cycle and speed OPEN. | Joint angle/time profile with stance/swing duration, repetitions, rest periods, loaded speed, tracking error and thermal response. A no-load speed or RMS torque alone does not close this requirement. |
| AR-04 Peak load | Capability must cover defined transient torque at its required speed, duration and repetition. Peak magnitude and duration OPEN. | Define acceleration/contact events and permitted pulse length, recurrence and recovery; substantiate overload/current and mechanical limits at those conditions. Stall torque alone is insufficient; half-weight is not automatically a short pulse. |
| AR-05 Reserve | Retain explicit allowance for uncertain loads and capability variation. Numeric allowance OPEN. | Quantify mass/COM, friction, force and temperature uncertainty; select and justify load margin separately from capability derating. Report included allowances so they are not counted twice. |
| AR-06 Travel | Desired output spans are 55/125/110 degrees for q1/q2/q3. Hardware feasibility OPEN. | Verify usable loaded actuator travel, neutral alignment, end reserves and transmission mapping. Check combined-angle interference, cable clearance, mechanical stops and backlash after packaging exists. |
| AR-07 Mass and placement | Complete operating robot must remain below 1.2 kg. Allocation OPEN. | Count all twelve actuator assemblies plus battery, structure, bearings, fasteners, wiring, electronics and feet. Record each moving component's mass, mounting link, COM and uncertainty; reconcile to one total. |
| AR-08 Drive and support | Ideal 1:1 is only the existing analysis reference. Actual ratio, efficiency and support OPEN. | Establish ratio and direction, efficiency versus load/direction, static holding behavior, backlash, drive mass and inertia. Verify structural bearings/support so servo shafts are not the sole unsupported load path. |
| AR-09 Supply evidence | Torque evidence must identify actual terminal voltage under simultaneous load. Voltage/current OPEN. | Candidate torque-speed-current and duty data at the intended voltage, supply droop, transient/holding currents and credible simultaneous-load assumptions. Later power architecture must keep servo current separate from ESP32 power paths. This brief does not design that architecture. |

Evidence records must identify source or test unit, configuration, date,
measurement uncertainty, operating conditions, and pass/fail limits. Missing
data yields an unresolved evaluation, not a pass. Candidate-specific tests
must use manufacturer limits where substantiated; absent thermal or overload
limits must be resolved before an approval test is defined.

## Load accounting and reserve convention

For joint j, include only components downstream of that joint in its gravity
sum, using their actual placement rather than assuming every servo is distal:

```text
tau_static_j = -a_j dot [(P-J_j) cross F
                         + sum_i ((C_i-J_j) cross (0,0,-m_i*g))]
```

Positions are metres, masses kg, forces N, and torques Nm. The contact-force
balance already uses total robot mass, including these components. Adding
their local gravity moments must not add their mass to the total again.
Gravity can reduce one moment while increasing another: do not presume
favourable cancellation without bounded component data.

For later sizing, construct a signed total torque history including dynamics
and losses, then maximize its magnitude over the approved operating set and
parameter uncertainties. Apply a separately justified reserve to that result.
Neither the uncertainty set nor reserve is established here; multiplying the
nominal table by an invented factor would not establish the missing envelope.
Keep stationary, repeated, and transient cases separate until their durations
and thermal conditions are specified. A prolonged redistributed stance belongs
in sustained capability assessment, even if its load is the largest case.

## Transmission and mass feasibility relationships

Define r = actuator rotation / joint rotation for a constant-ratio reduction,
using magnitudes, and eta as motoring mechanical efficiency (0 < eta <= 1).
Then, in motion under that model:

```text
T_actuator = T_joint / (r * eta)
omega_actuator = r * omega_joint
travel_actuator = r * travel_joint
P_actuator_mechanical = P_joint_mechanical / eta
```

Thus reduction trades actuator torque against speed and travel. r and eta
are dimensionless; rad/s times Nm is W. Static holding, reverse power flow,
nonconstant linkages and joint friction need their own characterized model;
do not infer holding efficiency or self-locking from motoring efficiency.
The identity r = eta = 1 reproduces TOR-001's ideal comparison only.

With four of each joint actuator, the mass constraint is
4*(m_q1 + m_q2 + m_q3) + m_other < 1.2 kg, provided all assembly masses are
counted exactly once. For identical assemblies this becomes
m_actuator < (1.2 kg - m_other)/12. Since m_other is unresolved, no per-servo
mass allowance is released. Any heavier actuator or drive changes distal
gravity and possibly geometry; recalculate these before claiming feasibility.

## Evaluation gates and stop point

1. Preliminary comparisons may tabulate the known benchmarks, desired travel,
   mass and available evidence, with unresolved fields explicit. A candidate
   cannot receive full approval from that comparison alone.
2. Performance approval requires AR-01 through AR-05 and AR-09 closed for an
   explicitly bounded operating set. Compare required torque/speed/duty with
   supported capability at the same voltage and thermal conditions.
3. Detailed mechanical commitment additionally requires credible AR-06 through
   AR-08 feasibility. Packaging sketches may support future evaluation, but
   this task releases no brackets, bearings, physical travel or print geometry.

MG90S remains a historical packaging reference and is not approved for direct
drive at the design ceiling. No new product claims or online rating updates
are introduced by this brief. The architecture, geometry, pose, angle ranges,
and TOR-001 findings remain unchanged.

Next bounded task: create a provisional component mass/COM inventory template
and accounting model for the nominal leg, showing how mounting location
determines each joint's downstream gravity terms. Preserve unknown masses as
unknowns and validate with clearly marked synthetic fixtures, without selecting
actuators or changing geometry. This next task is not executed in TOR-002.
