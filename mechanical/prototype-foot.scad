$fn=48;
module foot_carrier() {
    difference() {
        union() {
            translate([-8,-9,0]) cube([16,18,3]);
            translate([-8,-9,0]) cube([3,18,8]);
        }
        for(y=[-4,4]) translate([0,y,-1]) cylinder(d=3.5,h=5);
    }
}
foot_carrier();
