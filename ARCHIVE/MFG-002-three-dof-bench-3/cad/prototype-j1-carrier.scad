include <hobby-joint-common.scad>
include <prototype-j1-layout.scad>
use <hobby-joint-support.scad>
// Export flat face down. Local x = world x, local y = world z;
// local z = world y - carrier_back_y. Two end tabs bolt to the fork.
module carrier_beam(a,b,d=10,h=j1_carrier_t) {
    linear_extrude(h) hull() {translate(a) circle(d=d);translate(b) circle(d=d);}
}
module j1_carrier() {
    difference() {
        union() {
            // J2 support contact face, with full floor behind its base flange.
            translate([j1_pitch_forward,-shaft_x,0]) linear_extrude(j1_carrier_t)
                hull() for(x=[-22,22],y=[-24,24]) translate([x,y]) circle(d=6);
            carrier_beam([j1_rear_inner_x+3,j1_tab_z],[j1_pitch_forward-17.25,-shaft_x-14],12);
            carrier_beam([j1_front_inner_x-3,j1_tab_z],[j1_pitch_forward+17.25,-shaft_x-14],12);
            carrier_beam([j1_rear_inner_x+3,j1_tab_z],[j1_front_inner_x-3,j1_tab_z],12);
            for(x=[j1_rear_inner_x,j1_front_inner_x-6])
                translate([x,j1_tab_z-6,0]) cube([6,12,41]);
        }
        // J2 cradle + passive support: original slotted mounting coordinates.
        for(x=[-17.25,17.25],y=[-14,14]) hull()
            for(dx=[-1,1]) translate([j1_pitch_forward+x+dx,-shaft_x+y,-1]) cylinder(d=3.5,h=j1_carrier_t+2);
        translate([j1_pitch_forward,j1_pitch_vertical,-1]) cylinder(d=22,h=j1_carrier_t+2);
        // Relief the real support ribs below its base, with 0.2mm clearance.
        // Exclude the intended mating base face from the pocket operation.
        minkowski() {
            intersection() {
                multmatrix([[0,-1,0,j1_pitch_forward],[1,0,0,0],[0,0,1,10],[0,0,0,1]])
                    translate([-shaft_x,0,0]) rotate([180,0,0]) joint_support();
                translate([-100,-100,-1]) cube([400,300,7.999]);
            }
            cube([0.4,0.4,0.4],center=true);
        }
        for(x=[j1_rear_inner_x,j1_front_inner_x-6],y=j1_tab_hole_y)
            translate([x-1,j1_tab_z,y-j1_carrier_back_y]) rotate([0,90,0]) cylinder(d=3.5,h=8);
    }
}
module carrier_world() {
    multmatrix([[1,0,0,0],[0,0,1,j1_carrier_back_y],[0,1,0,0],[0,0,0,1]]) j1_carrier();
}
j1_carrier();
