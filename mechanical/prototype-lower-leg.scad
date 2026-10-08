include <hobby-joint-common.scad>
// Contact reference is85mm with the matching carrier and1mm rubber pad.
module lower_front_link() {
    difference() {
        linear_extrude(5) hull() {
            circle(d=32);
            translate([-76,0]) square([8,18],center=true);
        }
        translate([0,0,-1]) cylinder(d=10,h=7);
        for(a=[0,90,180,270]) rotate([0,0,a]) hull()
            for(r=[7,11]) translate([r,0,-1]) cylinder(d=2.5,h=7);
        arm_window(5);
        bridge_holes(5);
        for(y=[-4,4]) translate([-76,y,-1]) cylinder(d=3.5,h=7);
    }
}
lower_front_link();
