include <hobby-joint-common.scad>
use <hobby-joint-assembly.scad>
use <hobby-joint-rear-arm.scad>
use <hobby-joint-bridge.scad>
use <hobby-joint-bearing-parts.scad>
use <prototype-upper-leg.scad>
q2=44;
mode="assembly"; // assembly, collision, saddle-collision
module upper_moving(a=q2) {
    rotate([0,0,a]) {
        translate([0,0,horn_z]) upper_plate();
        translate([0,0,rear_top]) rotate([180,0,180]) rear_arm();
        translate([bridge_r,0,rear_top]) joint_bridge();
        translate([0,0,rear_top-rear_t]) rotate([180,0,0]) bearing_retainer();
        translate([0,0,upper_leg_saddle_z()]) knee_ear_saddle();
    }
}
module knee_case() {
    rotate([0,0,q2])
        translate([upper_leg_knee_x()-9.85,-10,3]) cube([19.7,40.7,42.9]);
}
if(mode=="collision") intersection() {
    upper_moving();
    union() { fixed_prints(); servo_reservation(); }
}
else if(mode=="saddle-collision") intersection() { upper_moving(); knee_case(); }
else if(mode=="assembly") {
    color("orange") fixed_prints();
    color("royalblue") upper_moving();
    color([0.2,0.2,0.2,0.6]) { servo_reservation(); knee_case(); }
    color("silver") { bearing_envelope(); fixed_hardware(); }
    color("white") assumed_horn();
    rotate([0,0,q2]) color("white") translate([upper_leg_knee_x(),0,48]) cylinder(d=24,h=2);
}
else assert(false,"Unknown mode");
