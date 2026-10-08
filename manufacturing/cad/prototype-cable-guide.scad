$fn=40;
module cable_guide() {
    difference() {
        union() {
            translate([-9,-7,0]) cube([18,14,3]);
            for(y=[-7,4]) translate([0,y,3]) cube([9,3,7]);
        }
        translate([-6,0,-1]) cylinder(d=3.5,h=5);
        translate([4.5,0,7]) rotate([90,0,0]) cylinder(d=2.5,h=18,center=true);
    }
}
cable_guide();
