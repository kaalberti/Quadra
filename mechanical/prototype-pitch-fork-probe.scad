use <prototype-pitch-fork.scad>
use <hobby-joint-assembly.scad>
use <prototype-pitch-leg.scad>
use <prototype-upper-leg.scad>
kind="upper";
angle=44.0486;
// Exclude intended bearing/retainer and saddle mating surfaces.
intersection() {
    rotate([0,0,kind=="upper"?angle:-angle]) pitch_fork(kind);
    if(kind=="upper") union() {
        fixed_prints(); servo_reservation();
        rotate([0,0,angle]) translate([-70,0,0]) {
            knee_fixed_prints(); knee_case_reservation();
        }
    } else union() {
        knee_fixed_prints(); knee_case_reservation();
        translate([70,0,50]) upper_plate();
        translate([70,0,28]) knee_ear_saddle();
    }
}
