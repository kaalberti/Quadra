# MEC-157 — correct bench adapter rib clearance and build checkpoint

MEC-156 independently found127.65mm3 of bench-adapter/support-rib interference.
Add small clearance pockets to the existing adapter while preserving its bolt
slots, anchor locations and pivot opening. Check closed/connected print geometry,
fixing access and adapter/support intersection excluding only intended contact.
Update the affected bench manufacturing snapshot/STL, validation and hashes as
a corrected prototype build checkpoint; retain the prior release in ARCHIVE.
Keep the new chassis study separate. Update status and physical-test guidance;
do not add a full robot kit, powered operation or locomotion.
