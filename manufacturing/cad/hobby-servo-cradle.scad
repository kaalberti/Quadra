// MEC-122: printable, adjustable split cradle. Units mm.
// Body envelope from TowerPro MG996R; mounting ears/horn are deliberately
// above the cradle. Verify lower-case shape and cable exit with the coupon.
part = "left"; // left, right, coupon, assembly
$fn = 48;
body_length = 40.7;
body_width = 19.7;
body_height = 42.9;
clearance = 0.8; // total pocket allowance, not per side
split_gap = 1.0; // allows closing the halves to grip the actual case
floor_t = 3;
wall_t = 4;
grip_height = 18;
bolt_d = 3.5;
L = body_length + clearance;
W = body_width + clearance;
outer_L = L + 2*wall_t;
outer_W = W + 2*wall_t;
lug_x = outer_L/2 + 4;
assert(grip_height < body_height);
assert(clearance < split_gap);

module yhole(x,z,d=bolt_d) {
    translate([x,0,z]) rotate([90,0,0])
        cylinder(d=d,h=outer_W+4,center=true);
}
module raw_cradle(height=grip_height) {
    difference() {
        union() {
            translate([-outer_L/2,-outer_W/2,0])
                cube([outer_L,outer_W,floor_t+height]);
            // Two accessible bolt lugs beyond the servo's short ends.
            for (s=[-1,1]) translate([s*lug_x,0,9])
                cube([10,outer_W,12],center=true);
            // Base flange for mounting to the eventual leg/frame.
            translate([-outer_L/2,-(outer_W+12)/2,0])
                cube([outer_L,outer_W+12,floor_t]);
        }
        translate([-L/2,-W/2,floor_t]) cube([L,W,height+1]);
        // Cable relief at one short end; no exact exit position assumed.
        translate([-outer_L/2-1,-6,floor_t]) cube([wall_t+2,12,7]);
        for (s=[-1,1]) yhole(s*lug_x,9);
        for (x=[-14,14],y=[-(outer_W/2+3),outer_W/2+3])
            hull() for (dy=[-1,1])
                translate([x,y+dy,-1]) cylinder(d=bolt_d,h=floor_t+2);
    }
}
module half(side=1,height=grip_height) {
    intersection() {
        raw_cradle(height);
        translate([-60,side>0 ? split_gap/2 : -60,-1])
            cube([120,60-split_gap/2,height+floor_t+2]);
    }
}
if (part=="left") half(-1);
else if (part=="right") half(1);
else if (part=="coupon") {
    // Short body-section check uses the same pocket and split geometry.
    half(-1,6);
    translate([0,outer_W+18,0]) half(1,6);
}
else if (part=="assembly") {
    color("orange") half(-1);
    color("gold") half(1);
    color([0.2,0.2,0.2,0.35])
        translate([-body_length/2,-body_width/2,floor_t])
            cube([body_length,body_width,body_height]);
}
else assert(false,"Unknown part selector");
