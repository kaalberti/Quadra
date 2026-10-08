# ELEC-002 — provisional12-servo harness and channel plan

Completed:2026-10-09. Named FL/FR/RL/RR joints use channels0..11;15 remains
board-only timing and12..14 unused. Three AHCT125N buffers use all12 gates;
public TI14-pin assignments and NXP OE/output behavior verified. One connection
table, Mermaid power/signal diagram and machine-readable plan agree.

Independent check confirms unique leg/joint channels/gates, manufacturer pin
map, component totals, external power boundaries and provisional sizing math.
Signal BOM totals/deltas distinguish reused bench parts.2A per servo plus25%
capacity margin gives30A target; actual demand and full robot power hardware
remain unselected. No bench wire/feed rating is applied to the24A main path.

Sources:https://www.ti.com/lit/ds/symlink/sn74ahct125.pdf and
https://www.nxp.com/docs/en/data-sheet/PCA9685.pdf.
Check:node electronics/check-four-leg-harness.mjs.
No supplier contact, firmware activation, manufacturing change or physical test.
FIT-001 remains pending; next offline task is commodity power feasibility/cost.
