include <hobby-joint-common.scad>
use <hobby-servo-cradle.scad>
use <hobby-joint-support.scad>
use <hobby-joint-front-arm.scad>
use <hobby-joint-rear-arm.scad>
use <hobby-joint-bridge.scad>
use <hobby-joint-bearing-parts.scad>
angle=0;
mode="assembly"; // assembly, printed, collision
module fixed_prints() {
    translate([-shaft_x,0,0]) {
        half(-1); half(1);
        rotate([180,0,0]) joint_support();
    }
}
module moving_prints(a=angle) {
    rotate([0,0,a]) {
        translate([0,0,horn_z]) front_arm();
        translate([0,0,rear_top]) rotate([180,0,0]) rear_arm();
        translate([-bridge_r,0,rear_top]) joint_bridge();
        translate([0,0,rear_top-rear_t]) rotate([180,0,0]) bearing_retainer();
    }
}
module servo_reservation() {
    // Case only: actual ears, spline, horn and cable are prototype checks.
    translate([-20.35-shaft_x,-9.85,3]) cube([40.7,19.7,42.9]);
}
module fixed_hardware() {
    color("silver") {
        translate([0,0,-18]) bearing_spacer(8);
        translate([0,0,-26]) bearing_spacer(3);
        translate([0,0,-39.5]) cylinder(d=4,h=35);
        translate([0,0,-4.5]) cylinder(d=7,h=4);
        translate([0,0,-30]) cylinder(d=7,h=3,$fn=6);
    }
}
module assumed_horn() {
    rotate([0,0,angle]) translate([0,0,48]) difference() {
        cylinder(d=24,h=2);
        translate([0,0,-1]) cylinder(d=5,h=4);
    }
}
module bearing_envelope() {
    translate([0,0,-23]) difference() {
        cylinder(d=13,h=5);
        translate([0,0,-1]) cylinder(d=4,h=7);
    }
}
if(mode=="collision") intersection() {
    moving_prints();
    union() { fixed_prints(); servo_reservation(); }
}
else if(mode=="printed") { fixed_prints(); moving_prints(); }
else if(mode=="assembly") {
    color("orange") fixed_prints();
    color("royalblue") moving_prints();
    color([0.3,0.3,0.3,0.5]) servo_reservation();
    color("gray") bearing_envelope();
    color("white") assumed_horn();
    fixed_hardware();
}
else assert(false,"Unknown mode");
