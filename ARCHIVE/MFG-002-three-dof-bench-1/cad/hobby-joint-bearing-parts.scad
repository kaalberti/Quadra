include <hobby-joint-common.scad>
part="retainer"; // retainer, front-spacer, rear-spacer
module bearing_spacer(h) {
    difference() {
        cylinder(d=5.8,h=h);
        translate([0,0,-1]) cylinder(d=4.3,h=h+2);
    }
}
module bearing_retainer() {
    difference() {
        linear_extrude(3) hull() {
            circle(d=18);
            for(y=[-11,11]) translate([0,y]) circle(d=9);
        }
        translate([0,0,-1]) cylinder(d=10,h=5);
        for(y=[-11,11]) translate([0,y,-1]) cylinder(d=3.5,h=5);
    }
}
if(part=="retainer") bearing_retainer();
else if(part=="front-spacer") bearing_spacer(8);
else if(part=="rear-spacer") bearing_spacer(3);
else assert(false,"Unknown bearing-part selector");
