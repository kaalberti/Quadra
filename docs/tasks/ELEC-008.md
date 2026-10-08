# ELEC-008 — Perfboard voltage input and disarmed diagnostic

Complete: optional divider/filter and placement in unused existing board pads,
plus explicit disarmed firmware acquisition. Positive input limit25.2V is a
manual bench boundary, not a battery selection. Nominal150k/10k5% divider,
100nF filter,GPIO8; worst tolerance node1.7294V and powers under4.34/0.30mW.
No unpowered isolation: sense positive disconnects before ESP32 power off.

Independent172-pad overlay/divider checks, host scale/spread/failure/saturation/
state gating checks, full existing firmware regression and embedded build pass.
Firmware.bin is compiled, not uploaded. Sixteen samples report uncalibrated
input estimates and spread without enabling servo outputs or adding cutoff.
Wiring/buying/testing:electronics/voltage-perfboard.md; physical tests remain
NOT_PERFORMED. No battery/regulator, final SMT PCB or gait stage started.
