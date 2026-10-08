// Rev A local joint datum: rotation axis at x=y=0, axial direction +z.
$fn=48;
shaft_x=-10.35;
horn_z=50;
front_t=5;
rear_top=-16.2;
rear_t=7;
bridge_r=58;
bridge_length=horn_z-rear_top;
bridge_pitch=14;
seat_d=13.2;
seat_depth=5.2;
module bridge_holes(h) {
    for(y=[-bridge_pitch/2,bridge_pitch/2])
        translate([-bridge_r,y,-1]) cylinder(d=3.5,h=h+2);
}
module arm_blank(t) {
    linear_extrude(t) hull() {
        circle(d=32);
        translate([-bridge_r,0]) square([12,26],center=true);
    }
}
module arm_window(t) {
    translate([0,0,-1]) linear_extrude(t+2) hull()
        for(x=[-40,-25]) translate([x,0]) circle(d=10);
}
