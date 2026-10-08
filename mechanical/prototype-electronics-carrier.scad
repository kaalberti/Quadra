// MEC-167 optional working carrier. No PCB mounting-hole pattern is assumed.
use <prototype-electronics-deck.scad>
view="assembly"; // base, shelf, assembly, board-collision
$fn=32;
module strap_slot(x,y,h=8) {
    hull() for(dx=[-2.5,2.5]) translate([x+dx,y,-1]) cylinder(d=3,h=h);
}
module electronics_carrier_base() {
    difference() {
        union() {
            for(y=[-38,38]) translate([-81,y-3,0]) cube([162,6,4]);
            for(x=[-75,75]) translate([x-6,-44,0]) cube([12,88,4]);
            // Strap beams clear the sixteen chassis fixing positions.
            for(s=[-1,1]) {
                translate([s*60-7,-25,0]) cube([14,50,4]);
                translate([s>0?60:-75,-3,0]) cube([15,6,4]);
            }
            for(x=[-75,75],y=[-38,38]) translate([x-6,y-6,0]) cube([12,12,40]);
            // Insulating lower-board pads; underside jumpers get6mm clearance.
            for(x=[-40,40],y=[-37.5,37.5]) translate([x-4,y-2.5,3]) cube([8,5,7]);
        }
        for(x=[-60,60],y=[-20,20]) strap_slot(x,y,6);
        // Lower board ties pass underneath without being pinched by the deck.
        for(x=[-46,46]) translate([x-1.5,-45,-.1]) cube([3,90,1.9]);
        for(x=[-75,75],s=[-1,1]) {
            y=s*38;
            translate([x,y,31.5]) cylinder(d=3.5,h=10);
            // Side-load M3 nut, flats aligned with the5.9mm channel.
            translate([x-2.95,s>0?y-3.3:y-8.7,33]) cube([5.9,12,2.9]);
        }
    }
}
module electronics_carrier_shelf() {
    difference() {
        union() {
            for(y=[-10,10]) translate([-81,y-6,0]) cube([162,12,4]);
            for(x=[-75,75]) translate([x-6,-44,0]) cube([12,88,4]);
            for(x=[-65,-15,15,65],y=[-10,10]) translate([x-3,y-3,3]) cube([6,6,4]);
        }
        for(x=[-75,75],y=[-38,38]) translate([x,y,-1]) cylinder(d=3.5,h=10);
        for(x=[-55,-25,25,55],y=[-10,10]) strap_slot(x,y,10);
    }
}
module electronics_carrier_structure() {
    electronics_carrier_base();translate([0,0,40]) electronics_carrier_shelf();
}
module electronics_carrier_boards(contact_relief=0) {
    // Entire populated envelopes are UNMEASURED reservations.
    color([.8,.4,0,.65]) translate([-50,-40,10+contact_relief]) cube([100,80,21.6-contact_relief]);
    color([0,.6,.6,.65]) translate([-75,-17.5,47+contact_relief]) cube([70,35,20-contact_relief]);
    color([0,.5,0,.65]) translate([7.5,-15,47+contact_relief]) cube([65,30,15-contact_relief]);
}
if(view=="base") electronics_carrier_base();
else if(view=="shelf") electronics_carrier_shelf();
else if(view=="assembly") {
    color("silver") electronics_deck();
    translate([0,0,4]) {
        color("gold") electronics_carrier_base();
        color("lightblue") translate([0,0,40]) electronics_carrier_shelf();
        electronics_carrier_boards();
    }
}
else if(view=="board-collision") intersection() {
    electronics_carrier_structure();electronics_carrier_boards(.001);
}
else assert(false,"Unknown carrier view");
