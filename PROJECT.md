# Quadruped Robot Project

## Project objective

Design and build an affordable, functional, 3D-printable quadruped robot for hobby and learning use.

The first priority is a working **Rev A physical prototype**, not a production-optimized or fully qualified robot.

Rev A should ultimately be capable of:

- standing under its own weight
- moving each leg independently
- commanding foot positions using inverse kinematics
- adjusting body height
- shifting body position and weight
- walking using a slow stable gait
- turning
- supporting later IMU-based stabilization and more advanced locomotion

The project should favor rapid physical iteration, commodity hardware, and reasonable engineering margins over exhaustive optimization.

---

# Core requirements

## Mechanical architecture

The robot shall have:

- 4 legs
- 3 independently actuated rotational DOF per leg
- 12 actuated DOF total

Each leg shall provide:

1. hip abduction/adduction
2. hip pitch
3. knee pitch

Baseline serial topology:

```text
Chassis
  -> J1 hip abduction/adduction
  -> J2 hip pitch
  -> upper leg
  -> J3 knee pitch
  -> lower leg
  -> passive foot
```

No active ankle is required for Rev A.

Left and right legs should share as many components as practical.

Front and rear legs should also use common components where practical.

---

# Size and mass targets

Nominal body planform target:

- body length: approximately 180 mm
- body width: approximately 110 mm

These dimensions are targets rather than hard packaging limits.

Maximum complete operating mass:

**2.0 kg**

This includes:

- actuators
- printed structure
- fasteners
- bearings
- battery
- electronics
- wiring
- onboard accessories required for normal operation

The 2.0 kg value is a hard upper limit for Rev A unless explicitly changed.

Lower mass is preferred when it can be achieved without significantly increasing cost, complexity, or development time.

There is no additional payload requirement for Rev A.

---

# Leg geometry

Current target kinematic lengths:

```text
UPPER_LEG_LENGTH = 70 mm
LOWER_LEG_LENGTH = 85 mm
```

Definitions:

- upper-leg length is measured from the hip-pitch axis to the knee-pitch axis
- lower-leg length is measured from the knee-pitch axis to the nominal ground-contact point

Current candidate body/root geometry is derived from the existing kinematic model.

The historical candidate includes approximately:

```text
J1 root rectangle = 150 × 110 mm
candidate J1-to-J2 lateral offset = 25 mm
```

The 25 mm hip offset is provisional and may be changed for actuator packaging.

Exact active dimensions belong in `DESIGN_PARAMETERS.md`.

Do not treat nominal project dimensions as immutable if prototype packaging demonstrates that a modest change materially simplifies the robot.

---

# Kinematic conventions

The established coordinate convention should be retained unless there is a compelling reason to change it.

Body frame:

```text
+x = forward
+y = left
+z = up
```

Positive joint conventions:

- positive hip abduction moves the leg outward
- positive hip pitch moves the upper leg forward from vertical-down
- positive knee flexion bends the lower leg backward relative to the upper leg

Zero joint angles represent a straight-down mathematical reference rather than the normal standing pose.

Detailed frame definitions and equations belong in the relevant kinematics documentation rather than this file.

---

# Standing geometry

The existing nominal standing configuration may be retained as a development reference:

- body-datum height approximately 120 mm
- feet approximately beneath the hip-pitch centres
- upper/lower geometry based on 70/85 mm links

This is a kinematic reference only.

It does not constitute:

- physical clearance validation
- actuator qualification
- stability qualification
- collision-free travel
- released servo limits

Physical testing takes precedence over analytical nominal poses once hardware exists.

---

# Joint travel

Current candidate geometric targets are approximately:

```text
Hip abduction/adduction:
q1 = -25° to +30°

Hip pitch:
q2 = -40° to +85°

Knee:
q3 = +20° to +130°
```

These are desired geometric ranges, not guaranteed servo limits.

Final usable ranges may be reduced based on:

- servo travel
- printed-part interference
- cable routing
- mechanical stops
- practical gait requirements

Rev A does not need to exploit the complete theoretical workspace.

---

# Actuator strategy

The robot requires 12 actuators, so actuator cost, mass, and power are major system-level constraints.

## Rev A direction

Prefer:

- commodity hobby servos
- metal gears
- conventional PWM control where practical
- easily sourced replacement units
- standard servo horns

Do not use expensive smart/bus servos unless cheaper hobby-class actuators cannot provide acceptable Rev A performance.

The earlier XC330 precision actuator/coupling direction is deferred and is not required for Rev A.

MG996R-sized servos are currently a **provisional packaging candidate**, not an approved final actuator.

Selection requires enough evidence to establish:

- adequate approximate torque
- acceptable mass
- acceptable cost
- workable dimensions
- appropriate operating voltage
- practical power requirements
- acceptable mechanical fit

Physical prototype testing should ultimately determine whether the selected actuator is satisfactory.

## Servo selection priority

Use this priority order:

1. adequate torque and basic performance
2. cost
3. availability
4. mechanical compatibility
5. acceptable backlash
6. speed
7. premium features

Once an actuator provides adequate Rev A performance, significantly better performance does not justify significantly higher cost by itself.

---

# Servo loading philosophy

Servo loading analysis should be proportional to the project.

Use simple static calculations to establish whether an actuator is obviously unsuitable or plausibly adequate.

Consider representative demanding conditions such as:

- normal standing
- three-leg support
- temporary uneven load distribution
- useful crouched poses

Do not perform large numbers of nearly identical load cases unless the actuator is close to an important limit.

Stall torque is not the same as continuous usable torque.

Physical thermal/current testing may be used later if actuator performance is uncertain.

The goal is to select a servo that works reliably enough for Rev A, not fully characterize the actuator.

---

# Mechanical construction

Primary manufacturing method:

**FDM 3D printing**

Default fabrication assumptions:

```text
Nozzle = 0.4 mm
Layer height = 0.2 mm
Typical dimensional capability = approximately ±0.2 mm
Primary materials = PLA+ or PETG
```

## Mechanical preferences

Prefer:

- M3 fasteners where practical
- through bolts where useful
- heat-set inserts for repeatedly serviced interfaces
- commodity bearings or bushes
- replaceable modules
- accessible fasteners
- common/symmetric printed parts
- straightforward print orientations
- limited support material
- conservative wall thickness
- ribs and fillets rather than unnecessary solid mass
- replaceable feet
- integrated cable-routing features where useful

Avoid:

- printed structural threads when conventional hardware is practical
- inaccessible fasteners
- excessive unique left/right parts
- unnecessarily intricate precision mechanisms
- relying on unsupported servo output shafts as structural bearings where a simple support can be added
- custom-machined parts unless clearly justified

Rev A parts may be oversized if that reduces design risk and development effort.

---

# Joint construction philosophy

For Rev A, prefer mechanically simple joint arrangements.

Where practical:

- servo horn transmits torque
- opposite side of the joint is independently supported
- inexpensive bearings, bushes, bolts, or printed pivots provide radial support
- printed parts locate components without requiring unnecessarily tight tolerances

Do not pursue precision couplings, elaborate floating mechanisms, or finely tolerance-controlled interfaces unless testing demonstrates they are necessary.

A functional hobby-grade joint is preferred over a theoretically superior but expensive or difficult-to-manufacture joint.

---

# Feet

Rev A feet should be:

- passive
- replaceable
- suitable for indoor testing
- reasonably tolerant of small floor irregularities

Provision for TPU or rubber contact surfaces is desirable.

Foot force sensing is not required for Rev A.

Future sensors may be considered later without blocking initial development.

---

# Electronics architecture

Rev A should initially use commodity electronics rather than a custom integrated controller PCB where practical.

Expected architecture:

- ESP32-S3 microcontroller
- PCA9685 or equivalent PWM servo controller where appropriate
- 6-axis IMU
- battery-voltage monitoring
- Wi-Fi
- optional Bluetooth
- USB programming/debugging

Initial prototypes should use perfboard. Consider SMT components for the final
design after the basic mechanical, actuator, and power architecture has been demonstrated.
DigiKey is the preferred supplier for electronic components.
A custom PCB remains deferred until the architecture is demonstrated.

Electronics may initially be assembled using:

- development boards
- breakout modules
- prototype wiring
- simple carrier/perfboard arrangements

Rev A packaging does not need to be elegant.

---

# Power architecture

Servos must not be powered through the ESP32 development board.

Expected high-level architecture:

```text
Battery
 |
 +--> high-current servo supply / BEC
 |
 +--> logic power supply
      |
      +--> ESP32
      +--> control electronics
```

Grounds must be connected appropriately for the chosen control architecture.

Power design must adequately consider:

- battery voltage
- servo voltage
- regulator/BEC current
- servo transient current
- connector current rating
- wire size
- PCB current capacity where relevant
- polarity
- expected operating temperature where relevant

Power electronics should receive more rigorous engineering attention than lightly loaded printed mechanical parts because errors can damage hardware.

---

# Battery

Battery chemistry, voltage, and capacity remain selectable until actuator and power architecture are established.

The battery should provide:

- appropriate voltage for the selected power architecture
- adequate current capability
- practical runtime
- acceptable mass
- safe charging using readily available equipment

Do not optimize runtime before basic locomotion works.

---

# Firmware goals

Firmware should ultimately provide:

- individual servo control
- configurable servo centre offsets
- configurable servo directions
- safe joint-angle limits
- smooth motion commands
- calibration storage
- battery-voltage monitoring
- IMU acquisition
- single-leg inverse kinematics
- whole-body foot positioning
- standing pose
- sitting/rest pose
- body-height adjustment
- body translation
- body pitch and roll
- slow crawl gait
- turning

Later features may include:

- gait trajectory refinement
- trot gait
- IMU stabilization
- dynamic gait control
- browser-based configuration
- OTA firmware updates

Advanced locomotion must not block basic walking development.

---

# Firmware development order

Preferred approximate order:

1. control one servo
2. control all servo channels
3. servo centre/direction configuration
4. joint limits
5. calibration storage
6. one-leg joint control
7. one-leg inverse kinematics
8. four-leg control
9. static standing
10. body height adjustment
11. weight shifting
12. lift and place one foot
13. crawl gait
14. turning
15. gait refinement
16. IMU stabilization
17. faster/dynamic gaits

The order may change if prototype results justify it.

---

# Cost constraints

This is a hobby prototype and cost is a major engineering requirement.

## Total project budget

Preferred Rev A total:

**NZ$500–800**

Absolute ceiling without explicit user approval:

**NZ$1,000**

The total should include the major hardware required for a functional prototype.

## Actuator budget

Preferred actuator cost:

**NZ$25–35 each or less**

Avoid actuators above:

**NZ$50 each**

without explicit justification and approval.

For 12 actuators:

```text
NZ$25 each = NZ$300
NZ$35 each = NZ$420
NZ$50 each = NZ$600
```

Actuator selection must consider total quantity cost, not just unit cost.

## Component approval threshold

Any individual component or repeated component selection that consumes more than approximately 10% of the total project budget should be explicitly surfaced before being treated as locked.

## Cost optimization rule

If a component exceeds the desired budget, investigate in this order:

1. determine whether the requirement is genuinely necessary
2. reduce loading or performance requirements if practical
3. modify geometry if that permits a cheaper component
4. consider a different component class
5. consider readily available commodity alternatives
6. only then recommend the expensive solution

Do not optimize for premium hardware when a cheaper component is good enough for Rev A.

---

# Rev A design philosophy

Rev A exists to prove that the robot can work.

Acceptable Rev A characteristics include:

- oversized printed brackets
- visible fasteners
- exposed wiring
- external BEC/regulator modules
- development boards
- basic cable ties
- conservative motion limits
- relatively slow movement
- extra structure
- slightly higher mass
- temporary covers or mounts
- manual calibration steps

Rev A does not need:

- minimum possible mass
- fully custom electronics
- production-quality wiring harnesses
- cosmetic enclosures
- optimum gait efficiency
- precision-machined joints
- highly integrated electronics
- polished industrial design

Those are potential Rev B/Rev C objectives.

---

# Validation philosophy

The primary Rev A validation method is:

```text
estimate
→ design
→ build
→ test
→ revise
```

Analytical work should primarily answer questions that could materially change what is built.

Examples worth calculating:

- approximate servo torque
- power supply current
- battery current
- voltage-divider limits
- major geometry/interference
- important PCB current paths

Examples generally better resolved by prototype:

- exact printed-joint stiffness
- minor bracket deflection
- small assembly clearances
- cable routing details
- printed fit tolerances
- minor structural optimization

Do not treat a calculation as necessary merely because it can be performed.

---

# Safety scope

Rev A is a low-mass hobby robot but contains a battery and multiple powered actuators.

Pay particular attention to:

- battery handling
- short-circuit protection
- connector polarity
- appropriate regulators
- wire and connector current capability
- accidental servo motion during setup
- mechanical pinch points
- safe servo angle limits

The project is not intended for safety-critical operation.

---

# Current Rev A direction

Current approved/high-confidence direction:

- 4 legs
- 3 DOF per leg
- 12 actuators
- 2.0 kg maximum operating mass
- approximately 180 × 110 mm body target
- approximately 70 mm upper-leg length
- approximately 85 mm lower-leg length
- FDM printed structure
- commodity metal-geared hobby servos preferred
- MG996R-sized class currently under consideration for packaging
- standard servo horns preferred
- opposite-side joint support where practical
- ESP32-S3 anticipated
- PWM servo control architecture preferred for Rev A
- commodity electronics/modules preferred
- custom PCB deferred until architecture is demonstrated
- NZ$500–800 preferred total budget
- NZ$1,000 absolute budget ceiling without approval

Not currently approved/locked:

- exact servo model
- exact servo supply voltage
- exact battery
- final hip offset
- final chassis structure
- exact bearings
- final joint hardware
- custom PCB
- final wiring architecture
- final servo travel limits
- final robot mass
- advanced gait architecture

---

# Design authority and project files

Use the repository files according to these roles.

## PROJECT.md

This file.

Contains:

- stable project requirements
- major architecture
- overall constraints
- cost limits
- Rev A philosophy

It should change relatively infrequently.

Do not use this file as a running work log.

## DESIGN_PARAMETERS.md

Contains the latest approved numerical values and selected components.

Examples:

- dimensions
- servo model
- servo mass
- servo voltage
- battery
- regulator
- bearing sizes
- connector types

This is the numerical source of truth for the current design.

## STATUS.md

Contains:

- current milestone
- what has been completed
- current prototype state
- immediate objective
- genuine blockers
- important unresolved questions

Keep STATUS.md concise.

It should describe where the project is now rather than recounting its full history.

## ROADMAP.md

Contains high-level milestones and development sequence.

Do not use it for detailed engineering tasks.

## BACKLOG.md

Contains non-blocking:

- improvements
- ideas
- future investigations
- optimization opportunities
- later-revision features

Items should go here rather than interrupting current prototype work.

## decisions/

Contains significant design decisions worth preserving.

Use decision records for changes such as:

- selecting a servo family
- changing leg lengths
- changing power architecture
- changing battery voltage
- adopting a custom PCB
- abandoning a major mechanical architecture

Do not create decision records for trivial implementation choices.

## ARCHIVE/

Contains superseded investigations and historical analyses that may remain useful for reference but no longer represent the active design.

Historical TOR/MEC investigations should remain available here without cluttering the active project requirements.

## manufacturing/

Contains actual build/release outputs.

Do not use it as a working directory.

---

# Scope boundaries

The project should advance through physical capability rather than analytical completeness.

A reasonable progression is:

```text
architecture
↓
functional 3-DOF leg
↓
four-leg mechanical robot
↓
standing robot
↓
controllable feet
↓
slow walking robot
↓
electronics refinement
↓
Rev B optimization
```

Do not delay a physical prototype solely to resolve issues that can more efficiently be tested on hardware.

When a design is good enough to answer the next important physical question, build it.