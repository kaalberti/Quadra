# MEC-169 — Servo-qualified operating mass policy

Apply the user's revised requirement:2kg is a preferred complete-mass target,
not a hard ceiling. Heavier is acceptable only within physically demonstrated
servo load/current/duty capability; qualified maximum remains TBD.

Update active requirements,parameters,mass inputs/report semantics and physical
load instructions. Preserve actual CAD/STL quantities and existing mass totals.
Use only one brief existing-pose torque scaling comparison if it informs the
MG996R direction; do not derive an arbitrary safe maximum from stall torque.

Completion: independent mass checks still produce the same estimated totals,
clearly separate target margin from unqualified allowable mass,and keep all
physical measurements unset. Add regression checks for unknown/measured mass
and target-vs-qualified semantics. Budget,servo rail and travel unchanged.
No hardware purchase,servo upgrade,manufacturing rebuild or powered trial.
