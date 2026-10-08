$fn=48;
include <hobby-joint-common.scad>
use <hobby-joint-support.scad>
module bench_base() {
    difference() {
        // Compact adapter stays inside the rotating bridge radius. Negative-x
        // anchors avoid the rear-arm sector; mount40mm ahead of a vertical board.
        linear_extrude(7) hull() for(x=[-40,21.75],y=[-17.25,17.25])
            translate([x,y]) circle(d=6);
        for(x=[-14,14],y=[-17.25,17.25]) hull()
            for(dy=[-1,1]) translate([x,y+dy,-1]) cylinder(d=3.5,h=9);
        translate([-10.35,0,-1]) cylinder(d=22,h=9);
        // Clear passive-support ribs that extend below its z=-3 base face.
        // In this print frame the support mating face is z=7.
        minkowski() {
            intersection() {
                translate([0,0,10]) rotate([180,0,0]) joint_support();
                translate([-100,-100,-1]) cube([200,200,7.999]);
            }
            cube([0.4,0.4,0.4],center=true);
        }
        for(y=[-12,12]) {
            translate([-35,y,-1]) cylinder(d=4.5,h=9);
            translate([-35,y,2.5]) cylinder(d=7.5,h=5);
        }
    }
}
bench_base();
