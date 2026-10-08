include <hobby-joint-common.scad>
use <hobby-joint-assembly.scad>
use <prototype-upper-leg.scad>
use <prototype-upper-leg-assembly.scad>
use <prototype-knee-support.scad>
use <prototype-lower-leg.scad>
use <prototype-foot.scad>
use <hobby-joint-rear-arm.scad>
use <hobby-joint-bridge.scad>
use <hobby-joint-bearing-parts.scad>
use <prototype-cable-guide.scad>
use <prototype-bench-base.scad>
q2=44.0486;
q3=78.9786;
mode="assembly"; // assembly, knee-collision
module knee_fixed_prints() {
    translate([0,0,-8]) knee_support();
}
module knee_output(a=q3) {
    rotate([0,0,-a]) {
        translate([0,0,50]) lower_front_link();
        translate([0,0,rear_top]) rotate([180,0,0]) rear_arm();
        translate([-bridge_r,0,rear_top]) joint_bridge();
        translate([0,0,rear_top-rear_t]) rotate([180,0,0]) bearing_retainer();
        translate([-76,0,47]) foot_carrier();
    }
}
module knee_case_reservation() {
    translate([-9.85,-10,3]) cube([19.7,40.7,42.9]);
}
module knee_hardware() {
    translate([0,0,-18]) bearing_spacer(10);
    translate([0,0,-26]) bearing_spacer(3);
    bearing_envelope();
    translate([0,0,-39.5]) cylinder(d=4,h=35);
    translate([0,0,-4.5]) cylinder(d=7,h=4);
    rotate([0,0,-q3]) translate([0,0,48]) cylinder(d=24,h=2);
}
if(mode=="knee-collision") intersection() {
    knee_output();
    union() {
        knee_fixed_prints(); knee_case_reservation();
        translate([70,0,50]) upper_plate();
        translate([70,0,upper_leg_saddle_z()]) knee_ear_saddle();
    }
}
else if(mode=="assembly") {
    color("gray") translate([-shaft_x,0,-10]) bench_base();
    color("orange") fixed_prints();
    color("royalblue") upper_moving(q2);
    color("orange") rotate([0,0,q2]) translate([-24.5,0,55]) cable_guide();
    color([0.25,0.25,0.25,0.6]) servo_reservation();
    color("silver") { fixed_hardware(); bearing_envelope(); }
    rotate([0,0,q2]) translate([upper_leg_knee_x(),0,0]) {
        color("orange") knee_fixed_prints();
        color("seagreen") knee_output(q3);
        color([0.25,0.25,0.25,0.6]) knee_case_reservation();
        color("silver") knee_hardware();
        color("black") rotate([0,0,-q3]) translate([-85,-9,47]) cube([1,18,8]);
    }
}
else assert(false,"Unknown pitch-leg mode");
