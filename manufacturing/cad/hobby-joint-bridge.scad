include <hobby-joint-common.scad>
module joint_bridge() {
    difference() {
        union() {
            for(y=[-bridge_pitch/2,bridge_pitch/2])
                translate([0,y,0]) cylinder(d=12,h=bridge_length);
            translate([-1.5,-bridge_pitch/2,0]) cube([3,bridge_pitch,bridge_length]);
        }
        for(y=[-bridge_pitch/2,bridge_pitch/2])
            translate([0,y,-1]) cylinder(d=3.5,h=bridge_length+2);
    }
}
joint_bridge();
