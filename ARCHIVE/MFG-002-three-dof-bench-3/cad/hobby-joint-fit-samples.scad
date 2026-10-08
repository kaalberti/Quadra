include <hobby-joint-common.scad>
use <hobby-joint-front-arm.scad>
part="bearing"; // bearing, horn
module bearing_coupon() {
    difference() {
        translate([-36,-12,0]) cube([72,24,7]);
        for(i=[0:2]) {
            translate([(i-1)*24,0,-1]) cylinder(d=8,h=9);
            translate([(i-1)*24,0,1.8]) cylinder(d=13+0.2*i,h=6);
        }
        // One, two, three shallow dots identify the seats without text fonts.
        for(i=[0:2],mark=[0:i])
            translate([(i-1)*24+(mark-i/2)*3,9,6]) cylinder(d=1.5,h=2);
    }
}
module horn_coupon() {
    intersection() { front_arm(); cylinder(d=32,h=front_t); }
}
if(part=="bearing") bearing_coupon();
else if(part=="horn") horn_coupon();
else assert(false,"Unknown fit sample");
