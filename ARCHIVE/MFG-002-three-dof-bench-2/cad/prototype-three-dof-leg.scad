include <hobby-joint-common.scad>
include <prototype-j1-layout.scad>
use <hobby-joint-assembly.scad>
use <hobby-joint-front-arm.scad>
use <hobby-joint-rear-arm.scad>
use <hobby-joint-bearing-parts.scad>
use <prototype-j1-carrier.scad>
use <prototype-pitch-leg.scad>
use <prototype-bench-base.scad>
q1=0; q2=44.0486; q3=78.9786;
mode="assembly"; // assembly, fixed-collision, carrier-collision
module j1_fixed() {
    multmatrix(j1_point_to_world()) {fixed_prints();servo_reservation();}
}
module j1_fork() {
    multmatrix(j1_point_to_world()) rotate([0,0,90]) {
        translate([0,0,horn_z]) front_arm();
        translate([0,0,rear_top]) rotate([180,0,0]) rear_arm();
        translate([0,0,rear_top-rear_t]) rotate([180,0,0]) bearing_retainer();
    }
}
module moving_module() {
    j1_fork();carrier_world();
    multmatrix(pitch_point_to_world()) pitch_leg(q2,q3,false);
}
if(mode=="fixed-collision") intersection() {j1_fixed();rotate([q1,0,0]) moving_module();}
else if(mode=="carrier-collision") intersection() {
    union() {j1_fork();carrier_world();}
    multmatrix(pitch_point_to_world()) pitch_leg(q2,q3,false);
}
else if(mode=="assembly") {
    multmatrix(j1_point_to_world()) {
        color("orange") fixed_prints();
        color([0.25,0.25,0.25,0.6]) servo_reservation();
        color("silver") {fixed_hardware();bearing_envelope();}
        color("gray") translate([-shaft_x,0,-10]) bench_base();
    }
    rotate([q1,0,0]) {
        color("mediumpurple") j1_fork();
        color("gold") carrier_world();
        multmatrix(pitch_point_to_world()) pitch_leg(q2,q3,false);
    }
}
else assert(false,"Unknown three-DOF mode");
