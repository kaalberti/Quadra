include <hobby-joint-common.scad>
use <prototype-bench-base.scad>
use <hobby-joint-support.scad>
// Same relative transform used by the bench assembly. Exclude only the
// intended zero-thickness support base contact at adapter-print z=7.
intersection() {
    intersection() {bench_base();translate([-100,-100,-1]) cube([200,200,7.999]);}
    translate([0,0,10]) rotate([180,0,0]) joint_support();
}
