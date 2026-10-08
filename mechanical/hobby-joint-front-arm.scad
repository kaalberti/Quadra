include <hobby-joint-common.scad>
module front_arm() {
    difference() {
        arm_blank(front_t);
        arm_window(front_t);
        translate([0,0,-1]) cylinder(d=10,h=front_t+2);
        for(a=[0,90,180,270]) rotate([0,0,a]) hull()
            for(r=[7,11]) translate([r,0,-1]) cylinder(d=2.5,h=front_t+2);
        bridge_holes(front_t);
    }
}
front_arm();
