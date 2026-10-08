include <hobby-joint-common.scad>
module rear_arm() {
    difference() {
        arm_blank(rear_t);
        arm_window(rear_t);
        translate([0,0,-1]) cylinder(d=8,h=rear_t+2);
        translate([0,0,rear_t-seat_depth]) cylinder(d=seat_d,h=seat_depth+1);
        for(y=[-11,11]) translate([0,y,-1]) cylinder(d=3.5,h=rear_t+2);
        bridge_holes(rear_t);
    }
}
rear_arm();
