// MEC-133. Print-flat upper plate and support-free knee-ear saddle. mm.
include <hobby-joint-common.scad>
part="plate"; // plate, saddle, ear-coupon
upper_length=70;
ear_face_z=31; // Assumed underside of actual mounting ears; verify coupon.
ear_plate_t=3;
saddle_base_z=ear_face_z-ear_plate_t;
post_height=horn_z-saddle_base_z;
knee_x=-upper_length;
ear_y=[-14.4,35.1]; // Assumed49.5mm pitch, body centre+10.35mm.
function upper_leg_saddle_z()=saddle_base_z;
function upper_leg_knee_x()=knee_x;
module ear_slots(h) {
    for(x=[knee_x-5,knee_x+5],y=ear_y) hull()
        for(dy=[-1,1]) translate([x,y+dy,-1]) cylinder(d=3.5,h=h+2);
}
module saddle_mount_holes(h) {
    for(y=[-4,4]) translate([knee_x+22,y,-1]) cylinder(d=3.5,h=h+2);
}
module upper_plate() {
    difference() {
        linear_extrude(front_t) union() {
            hull() { circle(d=32); translate([bridge_r,0]) square([12,26],center=true); }
            hull() { circle(d=32); translate([knee_x+22,0]) square([14,22],center=true); }
        }
        translate([0,0,-1]) cylinder(d=10,h=front_t+2);
        for(a=[0,90,180,270]) rotate([0,0,a]) hull()
            for(r=[7,11]) translate([r,0,-1]) cylinder(d=2.5,h=front_t+2);
        for(y=[-bridge_pitch/2,bridge_pitch/2])
            translate([bridge_r,y,-1]) cylinder(d=3.5,h=front_t+2);
        for(s=[-1,1]) translate([0,0,-1]) linear_extrude(front_t+2) hull()
            for(r=[25,36]) translate([s*r,0]) circle(d=9);
        // Clearance around the knee output centre; knee fork follows later.
        translate([knee_x,0,-1]) cylinder(d=38,h=front_t+2);
        saddle_mount_holes(front_t);
    }
}
module knee_ear_saddle(coupon=false) {
    difference() {
        union() {
            translate([knee_x-14,-20,0]) cube([40,60.7,ear_plate_t]);
            if(!coupon) translate([knee_x+19,-8,0]) cube([7,16,post_height]);
        }
        // Knee case is clocked90deg to the link to keep70mm spacing.
        translate([knee_x-10.55,-10.7,-1]) cube([21.1,42.1,post_height+2]);
        ear_slots(post_height);
        saddle_mount_holes(post_height);
    }
}
assert(post_height>ear_plate_t);
if(part=="plate") upper_plate();
else if(part=="saddle") knee_ear_saddle();
else if(part=="ear-coupon") knee_ear_saddle(true);
else assert(false,"Unknown upper-leg part");
