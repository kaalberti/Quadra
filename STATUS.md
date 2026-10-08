# Project status

Last updated: 2026-10-08

## Current milestone

**Stage 4 — Single-leg mechanical prototype**

The immediate objective is to complete a functional 3-DOF Rev A leg using the current hobby-servo architecture.

Current leg capability:

```text
J2 hip pitch
+
J3 knee pitch
=
supported 2-DOF pitch leg complete in CAD

J1 hip abduction/adduction
=
not yet designed
```

The robot has not yet advanced to chassis, complete four-leg assembly, electronics integration, or powered locomotion.

---

## Current prototype state

A printable supported 2-DOF pitch-leg assembly exists.

Current source:

`mechanical/prototype-pitch-leg.scad`

Current build documentation:

`docs/prototype-pitch-leg-build.md`

Current print manifest:

`mechanical/pitch-leg-print-manifest.json`

The assembly currently includes:

- approximately 70 mm upper-link geometry
- approximately 85 mm knee-to-foot reference
- hip-pitch servo
- knee servo
- passive opposite-side knee support
- foot
- cable guide
- removable bench adapter
- commodity 624 bearings
- standard fasteners
- hobby-servo mounting architecture

The current design is intended for printing and unpowered fit testing before more detailed optimization.

---

## Current Rev A direction

The active Rev A direction is:

- 4 legs
- 3 DOF per leg
- 12 actuators total
- FDM-printed structure
- maximum complete operating mass: **2.0 kg**
- approximately 180 × 110 mm body target
- approximately 70 mm upper-leg target
- approximately 85 mm lower-leg target
- commodity metal-geared hobby servos preferred
- MG996R-sized servo class currently used as a provisional packaging direction
- supplied/standard servo horns preferred
- passive opposite-side support where practical
- simple printable joint construction
- ESP32-S3 anticipated for control
- PWM hobby-servo architecture preferred for Rev A
- off-the-shelf electronics/modules preferred initially
- custom PCB deferred until the architecture is demonstrated

The earlier XC330 precision-servo/coupling architecture is archived and is not the active Rev A direction.

---

## Current budget

Preferred total Rev A budget:

**NZ$500–800**

Absolute ceiling without explicit approval:

**NZ$1,000**

Actuator target:

**NZ$25–35 each preferred**

Avoid actuators above approximately NZ$50 each unless a cheaper workable option cannot be found.

Current servo quantities and prices remain provisional until an actuator is selected and purchased.

---

## Current mass status

Maximum allowed complete operating mass:

**2.0 kg**

Current known/modelled information:

- two current pitch-leg servo placeholders: approximately 55 g each
- two-servo total: approximately 110 g
- current pitch-leg printed-solid model: approximately 156 g
- bench adapter model: approximately 20 g and is not part of the final robot

These are CAD/model values, not measured finished-part masses.

The complete robot mass remains unknown.

Actual printed masses should replace CAD solid-volume estimates once parts are printed.

The earlier 1.2 kg analyses are historical and must not be treated as qualification for the current 2.0 kg requirement.

---

## Current actuator status

No final servo model is approved yet.

Current Rev A packaging work assumes approximately MG996R-sized hobby servos.

Current simple torque screening suggests this class is plausible for representative bent-leg loading, but:

- continuous performance is not validated
- dynamic walking loads are not validated
- extended-leg loading may be more demanding
- actual current draw is not measured
- actual servo temperature is not measured
- actual robot mass distribution is not known

These are prototype-validation items rather than blockers for continuing mechanical design.

Do not restart detailed actuator qualification unless physical testing identifies a problem.

---

## Current geometry

Current target leg dimensions:

```text
UPPER_LEG_LENGTH ≈ 70 mm
LOWER_LEG_LENGTH ≈ 85 mm
```

Historical candidate hip/root geometry includes:

```text
J1 root rectangle ≈ 150 × 110 mm
J1-to-J2 lateral offset ≈ 25 mm
```

The 25 mm offset is provisional and may be changed as required for J1 servo packaging.

Current candidate joint ranges remain useful design references:

```text
J1 abduction/adduction ≈ -25° to +30°
J2 hip pitch ≈ -40° to +85°
J3 knee ≈ +20° to +130°
```

These are desired geometric ranges, not validated physical operating limits.

---

## What has been validated

Current CAD-level checks indicate that:

- the existing 2-DOF pitch-leg parts compile successfully
- current printable meshes pass basic mesh/manifold checks
- nominal knee geometry does not show obvious interference in the checked poses
- the supported knee arrangement is mechanically plausible
- commodity bearing/horn/fastener construction can replace the archived precision-coupling concept
- the pitch leg can be packaged as a printable prototype
- a manufacturing pack exists for printing and unpowered assembly assessment

These are CAD/prototype-readiness checks only.

They do not establish:

- real printed fit
- real servo fit
- full cable motion
- powered joint performance
- continuous servo duty
- complete robot mass
- walking performance

---

## Manufacturing pack

Current manufacturing pack:

**MFG-001**

Scope:

**2-DOF pitch-leg prototype only**

It is intended for:

- printing
- unpowered assembly
- fit inspection
- identifying mechanical changes before the 3-DOF leg is finalized

It is not a complete robot manufacturing release.

Current pack does not include:

- complete 3-DOF leg
- chassis
- PCB
- wiring release
- firmware release
- full robot BOM

Do not continuously regenerate the manufacturing pack during ordinary CAD work.

Update it when the next physical prototype is ready to build.

---

## Immediate objective

Design the **J1 hip abduction/adduction carrier** and integrate the third servo with the existing pitch-leg assembly.

The result should create a complete printable **3-DOF leg prototype**.

This task should include only the level of analysis needed to avoid an obviously poor design.

Minimum useful checks:

- third servo physically fits
- required joint axis is correctly oriented
- existing J2/J3 assembly can attach
- useful abduction range is possible
- obvious collisions are avoided
- approximate J1 torque is reasonable for the candidate servo
- assembly remains practical to print and service

Do not turn this into another detailed precision-joint investigation.

---

## Next physical milestone

**Print and assemble one complete 3-DOF leg.**

The purpose of the prototype is to answer:

- Do the servos fit?
- Do the horns fit?
- Do the bearings fit?
- Does the leg articulate through useful motion?
- Do cables route adequately?
- Are brackets stiff enough?
- Are any clearances obviously wrong?
- Does the real mass look reasonable?

Physical prototype findings should take priority over additional analytical refinement.

---

## Current blockers

There are no known blockers preventing J1 design.

The following are open but **not blocking**:

- final servo model
- actual printed-part mass
- exact servo current
- continuous-duty capability
- final battery selection
- final power supply/BEC selection
- final chassis design
- exact cable routing
- exact final joint limits
- complete robot centre of gravity
- custom PCB architecture

Resolve these when they become necessary for the next prototype stage.

---

## Important deferred work

Record these in `BACKLOG.md` rather than stopping current progress:

- final actuator validation
- detailed cable management
- weight reduction
- improved feet
- optimized bearings/pivots
- custom PCB
- current sensing
- IMU stabilization
- faster gait development
- cosmetic covers
- precision coupling concepts
- production-quality wiring

---

## Recently completed

### MEC-122 onward — Hobby-servo direction

The project transitioned away from the archived XC330 precision-coupling investigation toward inexpensive hobby servos and simple printed joints.

A split hobby-servo cradle, commodity bearing support, supplied-horn interface, upper-leg structure, lower-leg structure, foot, cable guide, and bench fixture were developed.

### MEC-134–143 — Supported pitch leg

A supported 2-DOF pitch-leg prototype was completed and packaged for printing.

Current outcome:

- J2/J3 geometry exists
- printable parts exist
- basic interference checks pass
- manufacturing pack MFG-001 exists
- physical fit has not yet been tested
- J1 remains to be designed

Historical task-by-task details remain available in project documentation and archive files and should not be duplicated here.

---

## Repository state

Superseded precision-joint investigations have been moved under:

`ARCHIVE/2026-10-08-superseded-design/`

Active Rev A files remain outside the archive.

Historical archived work should be treated as reference only unless deliberately reactivated.

---

## Status-file rule

Keep this file concise.

This file should answer:

1. What are we building right now?
2. What already works?
3. What is the next physical milestone?
4. What is genuinely blocking progress?
5. What important design direction is currently active?

Do not use `STATUS.md` as:

- a complete project history
- a test log
- a list of every completed task
- a repository changelog
- a record of every numerical analysis
- a place for superseded engineering details

Detailed history belongs in `ARCHIVE/`, `decisions/`, or task-specific documentation.