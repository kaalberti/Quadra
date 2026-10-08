// Attachment prototype derived from MEC-155, not a four-leg print release.
include <hobby-joint-common.scad>
use <prototype-four-leg-study.scad>
use <prototype-chassis-mount.scad>
include <prototype-j1-layout.scad>
use <prototype-bench-base.scad>
use <hobby-joint-assembly.scad>
mode="assembly"; // assembly, deck, mount-leg-collision
module chassis_deck() {
    difference() {
        translate([-90,-55,155]) cube([180,110,4]);
        for(f=[-1,1],s=[-1,1],x=[-28,-16],y=[-25,-10])
            translate([f*(75+x),s*(55+y),154]) cylinder(d=3.5,h=6,$fn=32);
    }
}
if(mode=="assembly") {
    for(f=[-1,1],s=[-1,1]) multmatrix(placement(f,s)) {
        local_leg();
        color("tomato") chassis_mount_world();
    }
    color([0.5,0.5,0.5,0.5]) chassis_deck();
    color("teal") translate([-70,-20,159]) cube([70,35,20]);
    color("darkgreen") translate([5,-15,159]) cube([65,30,15]);
}
else if(mode=="deck") translate([0,0,-155]) chassis_deck();
else if(mode=="mount-leg-collision") intersection() {
    // Exclude the intended zero-thickness x=-3 support mating face.
    intersection() {chassis_mount_world();translate([-100,-100,-100]) cube([96.999,200,200]);}
    local_leg();
}
else if(mode=="bench-support-collision") intersection() {
    multmatrix(j1_point_to_world()) translate([-shaft_x,0,-10]) bench_base();
    multmatrix(j1_point_to_world()) fixed_prints();
}
else assert(false,"Unknown chassis assembly mode");
