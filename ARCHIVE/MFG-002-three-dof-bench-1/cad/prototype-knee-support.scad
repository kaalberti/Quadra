// Print base down; assembly translates z=-8 relative to knee axis.
$fn=48;
module knee_support() {
    difference() {
        union() {
            linear_extrude(3) hull() {
                circle(d=18);
                translate([22.5,0]) square([7,16],center=true);
            }
            cylinder(d=18,h=8);
            translate([19,-8,0]) cube([7,16,36]);
            for(y=[-6,6]) hull() {
                translate([0,y,0]) cylinder(d=3,h=7);
                translate([20,y,0]) cylinder(d=3,h=12);
            }
        }
        translate([0,0,-1]) cylinder(d=4.5,h=10);
        translate([0,0,3.5]) cylinder(d=7.5,h=5);
        for(y=[-4,4]) translate([22,y,-1]) cylinder(d=3.5,h=38);
    }
}
knee_support();
