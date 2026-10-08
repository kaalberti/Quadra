# Provisional hardware and deferred tests —2026-10-09

User authorizes development using MG996R/MG90S before final parts selection.
Use MG996R for all weight-bearing joints: existing CAD fits its size class.
MG90S torque is below existing joint estimates; reserve only for optional
light accessories. Published stall torque does not establish continuous duty.
PHYSICAL_TESTS.md holds the deferred checks; measured results will drive rework.

Reuse the owned5A supply for individual/staged tests, not as a qualified
three-servo or whole-robot supply. Available electronics are ESP32-S3 N16R8
and Adafruit PCA9685, so remove those purchases from the immediate BOM.
Printing access is a Creality K2 Pro. Keep calibration unset and real commands
narrow while developing offline functions.
