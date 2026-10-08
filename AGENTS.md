# Quadruped Robot — Codex Instructions

Read `PROJECT.md` and `STATUS.md` before beginning substantial work.

Refer to:

- `ROADMAP.md` for overall project direction.
- `DESIGN_PARAMETERS.md` for currently approved dimensions and components.
- `BACKLOG.md` for deferred improvements.
- `decisions/` for significant previous engineering decisions.

Do not treat every file as something that must be read for every trivial edit. Read additional files only when relevant to the current task.

# Primary objective

Build a functional, affordable Rev A quadruped prototype as efficiently as practical.

The objective is not to fully optimize, certify, or production-engineer the first revision.

Use this priority order:

1. Does it work?
2. Is it safe enough not to damage the battery or electronics?
3. Can it be printed, assembled, wired, and tested?
4. Is it easy to modify?
5. Is it robust enough for prototype use?
6. Is it reasonably compact and light?
7. Is it elegant or highly optimized?

Do not optimize lower-priority goals at the expense of higher-priority goals.

# Working style

Work incrementally, but do not subdivide the project unnecessarily.

Choose the next bounded task that materially advances the working prototype.

A good task should normally create a meaningful capability or unblock fabrication, assembly, electronics, or firmware.

Do not interpret "incremental" as meaning the smallest conceivable task.

Examples of appropriately sized tasks:

- define and validate the basic 3-DOF leg geometry
- design the complete printable upper-leg assembly
- select an affordable actuator and verify approximate torque suitability
- design the servo power architecture
- create and verify the battery-voltage measurement circuit
- implement servo calibration and limits

Avoid creating separate tasks for minor calculations or details that can reasonably be handled as part of a larger task.

# Bias toward building

Prefer:

1. reasonable engineering estimate
2. conservative design
3. prototype
4. physical test
5. revision

over prolonged theoretical analysis.

If a question can be answered cheaply and quickly by printing, assembling, wiring, or testing something, prefer the physical test.

Do not spend more engineering effort resolving an uncertainty than the likely cost of testing it.

# Analysis depth

Use engineering judgement proportional to the scale and risk of the project.

This is a small hobby quadruped robot, not an aerospace, automotive, medical, industrial, or safety-critical system.

For ordinary printed mechanical parts:

- use conservative geometry
- use sensible wall thicknesses, ribs, fillets, and fasteners
- use rough calculations when useful
- rely heavily on physical prototype testing
- do not perform detailed stress analysis unless there is a clear reason

Do not perform FEA unless:

- explicitly requested, or
- there is a genuine structural concern that cannot reasonably be resolved by simple calculation or testing.

For servo loading:

- perform enough calculation to establish approximate required torque
- consider realistic worst-case positions
- include a sensible prototype margin
- stop once it is clear whether the actuator is suitable

Do not calculate numerous nearly identical load cases if they will not affect the design decision.

For electronics, apply greater analytical care where mistakes could damage hardware, particularly:

- battery voltage and current
- regulators and BECs
- servo power supply sizing
- connector current
- PCB high-current paths
- polarity
- voltage limits
- thermal limits where relevant

Before continuing an analysis, ask:

**Will additional analysis materially change what we build?**

If no, stop and proceed.

# Blocking vs non-blocking uncertainty

Not every unknown must be resolved immediately.

Classify uncertainty as:

**Blocking**
- prevents the next useful prototype
- presents meaningful risk of damaging expensive hardware
- could force a major redesign if ignored

**Important later**
- should be resolved before a later revision or milestone
- does not prevent current prototype progress

**Nice to know**
- useful information but not necessary for current development

Only stop current work for blocking uncertainties.

Record non-blocking issues in `BACKLOG.md` where appropriate.

# Decision making

If two approaches are both likely to work adequately for Rev A:

- choose the simpler option
- prefer the cheaper option
- prefer standard commodity components
- prefer the option that is easier to modify
- proceed

Do not spend substantial effort optimizing between two acceptable solutions.

When exact information is unavailable:

- make a reasonable engineering assumption
- state the assumption briefly
- continue

Do not halt progress merely because an exact value is unavailable.

Flag assumptions that should later be physically verified.

# Cost discipline

Cost is a major engineering constraint.

Use the budgets defined in `PROJECT.md`.

Always consider quantity-adjusted cost.

For repeated components:

`TOTAL COST = UNIT COST × QUANTITY`

This is particularly important for the 12 actuators.

Once a component meets the required performance, do not automatically prefer a significantly more expensive component because it performs better.

If a proposed component significantly exceeds its target budget:

1. reconsider the requirement
2. reconsider geometry or loading
3. consider a cheaper component class
4. consider reducing performance requirements
5. only then recommend the expensive component

Any component exceeding the approval thresholds in `PROJECT.md` requires user approval before being treated as selected.

# Rev A philosophy

Rev A exists to prove the architecture.

Rev A may use:

- oversized printed parts
- exposed wiring
- off-the-shelf modules
- external regulators
- simple cable management
- conservative servo limits
- slow gaits
- temporary mounting solutions
- extra mass where it simplifies development

Do not prematurely optimize Rev A for:

- minimum mass
- minimum part count
- perfect appearance
- production assembly time
- highly integrated electronics
- sophisticated dynamic locomotion

Rev B and later revisions can improve these.

# Commodity components

For Rev A, prefer readily available standard components when suitable, including:

- servos
- servo horns
- bearings
- bushes
- fasteners
- connectors
- BEC/buck modules
- ESP32 development boards
- PCA9685 modules
- batteries
- wiring

Do not design a custom replacement for a cheap commodity component without a meaningful reason.

# Scope control

Do not create unrelated sub-projects during a task.

When a useful improvement or idea is discovered but does not block current progress:

- add it to `BACKLOG.md`
- continue the current task

Do not silently expand project scope.

# Design changes

Do not silently change an established major design parameter, architecture decision, or selected component.

If an established decision needs to change:

1. explain why
2. update the relevant source files
3. update `DESIGN_PARAMETERS.md` if applicable
4. record significant decisions in `decisions/`
5. identify important downstream consequences

Minor implementation details do not require a formal decision record.

# File responsibilities

Use files according to these roles:

`PROJECT.md`
Stable project requirements, constraints, budgets, and design goals.

`STATUS.md`
Current project state, current prototype stage, major blockers, and immediate next objective.

`ROADMAP.md`
High-level development sequence and milestones.

`DESIGN_PARAMETERS.md`
Current approved dimensions, components, voltages, interfaces, and other design values.

`BACKLOG.md`
Non-blocking improvements, future ideas, and deferred issues.

`decisions/`
Records of significant engineering decisions and their rationale.

`mechanical/`
Mechanical source design and prototype work.

`electronics/`
Electronic design source files and relevant calculations.

`firmware/`
Firmware source and testing.

`manufacturing/`
Build/release outputs only.

# Manufacturing pack

Do not continuously regenerate the manufacturing pack during ordinary design work.

Update `/manufacturing` only when:

- explicitly requested
- required to build the next physical prototype
- preparing a prototype build checkpoint
- preparing a formal design release

Do not place temporary working files or experimental versions in `/manufacturing`.

Source files belong in their respective development folders.

# Firmware progression

Do not prematurely implement advanced locomotion.

Progress approximately through:

1. individual servo control
2. servo direction and limits
3. servo calibration
4. one-leg joint control
5. one-leg inverse kinematics
6. four-leg control
7. static standing
8. weight shifting
9. simple crawl gait
10. turning
11. improved trajectories
12. IMU stabilization
13. faster/dynamic gaits

Do not implement advanced gait optimization or dynamic stabilization before the underlying hardware and kinematics work reliably.

## Documentation governance

Project files have strict roles.

### PROJECT.md
Purpose:
- stable project requirements
- major constraints
- architecture
- budgets
- design philosophy

Rules:
- do not use as a work log
- do not append completed-task history
- do not record superseded investigations
- change only when a real project requirement or major architecture changes

Target size:
- preferably <300 lines

### STATUS.md
Purpose:
- current stage
- current prototype state
- immediate objective
- current blockers
- recent meaningful progress

Rules:
- summarize current state, do not append history
- replace outdated information instead of preserving it
- remove obsolete assumptions
- keep only the most recent major work
- historical task details belong elsewhere

Target size:
- preferably <150 lines
- hard warning at 250 lines

Before adding to STATUS.md, ask:
"Does this help answer what we are doing now?"
If no, put it elsewhere.

### DESIGN_PARAMETERS.md
Purpose:
- current approved numerical parameters and selected components

Rules:
- values only
- no investigation history
- no long explanations
- superseded values should be replaced, not retained inline

### BACKLOG.md
Purpose:
- non-blocking future work and ideas

Rules:
- keep entries short
- remove items when completed or intentionally abandoned

### decisions/
Purpose:
- important decisions and rationale

Use for:
- servo architecture changes
- major geometry changes
- power architecture changes
- component family selections

Do not create decision records for trivial implementation choices.

### ARCHIVE/
Purpose:
- historical and superseded work

Move obsolete investigations here instead of retaining them in active project files.

### Task history
Detailed task results, test commands, analysis outputs, and validation logs must not be appended to PROJECT.md or STATUS.md.

Store them in:
- task-specific docs
- archive files
- git history
- generated validation reports

Git history is the project history. Active Markdown files should describe the current state.

## DESIGN_PARAMETERS.md rules

Use DESIGN_PARAMETERS.md as the active numerical source of truth.

When a parameter is approved:
- update the existing value
- do not append a historical note

If a value is uncertain:
- mark it PROVISIONAL or TBD

Do not duplicate detailed calculations, rationale, or investigation history here.

If a parameter changes significantly, record the reason in decisions/ and update the value here.

# Repository safety

Only modify files within this repository.

Do not:

- delete files unless explicitly instructed
- modify Git history
- force push
- run destructive filesystem commands
- modify Windows registry settings
- install global packages unless explicitly approved
- run administrator-level operations without approval

Prefer local project dependencies and virtual environments where practical.

Do not make unnecessary system-level changes.

# Completion

After meaningful project work:

- briefly summarize what changed
- identify meaningful validation performed
- mention blockers or important unresolved issues
- update `STATUS.md` if project state changed
- update `DESIGN_PARAMETERS.md` if approved parameters changed
- record major decisions when appropriate

Do not generate process documentation for trivial edits.

Do not automatically start another major project stage unless instructed to continue.