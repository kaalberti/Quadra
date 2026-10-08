include <hobby-joint-common.scad>
// Print base down; assembly flips this below the existing cradle floor.
module joint_support() {
    difference() {
        union() {
            translate([-24.75,-20.25,0]) cube([49.5,40.5,3]);
            translate([shaft_x,0,0]) cylinder(d=18,h=10);
            for(y=[-1,1]) hull() {
                translate([shaft_x,y*6,0]) cylinder(d=4,h=9);
                translate([shaft_x,y*17,0]) cylinder(d=4,h=3);
            }
        }
        translate([shaft_x,0,-1]) cylinder(d=4.5,h=12);
        // Head captured between support and cradle floor after assembly.
        translate([shaft_x,0,-0.1]) cylinder(d=7.5,h=4.6);
        for(x=[-14,14],y=[-17.25,17.25]) hull()
            for(dy=[-1,1]) translate([x,y+dy,-1]) cylinder(d=3.5,h=12);
    }
}
joint_support();
