// MEC-168 working alternative: three small frames, no extra M3 mount hardware.
use <prototype-electronics-deck.scad>
view="assembly"; // perfboard, esp32, pca9685, assembly, board-collision
$fn=32;
module tie_slot(x,y,h=10) {
    hull() for(dx=[-2.5,2.5]) translate([x+dx,y,-1]) cylinder(d=3,h=h);
}
module perfboard_sled() {
    difference() {
        union() {
            for(y=[-38,38]) translate([-51,y-3,0]) cube([102,6,3]);
            for(x=[-15,15]) translate([x-7,-41,0]) cube([14,82,3]);
            for(x=[-40,40],y=[-37.5,37.5]) translate([x-3,y-2.5,2]) cube([6,5,6]);
        }
        for(x=[-15,15],y=[-20,20]) tie_slot(x,y,5);
        for(x=[-46,46]) translate([x-1.5,-42,-.1]) cube([3,84,1.5]);
    }
}
module controller_sled(width=36,tie_x=10) {
    difference() {
        union() {
            for(y=[-22,22]) translate([-width/2,y-3,0]) cube([width,6,3]);
            for(x=[0,-tie_x]) translate([x-3,-25,0]) cube([6,50,3]);
            translate([tie_x-7,-25,0]) cube([14,50,3]);
            for(x=[-12,12],y=[-22,22]) translate([x-3,y-3,2]) cube([6,6,6]);
        }
        for(y=[-20,20]) tie_slot(tie_x,y,5);
    }
}
module single_level_prints() {
    perfboard_sled();
    translate([-70,0,0]) controller_sled(36,10);
    translate([70,0,0]) controller_sled(32,-10);
}
module single_level_boards(contact_relief=0) {
    color([.8,.4,0,.65]) translate([-50,-40,8+contact_relief]) cube([100,80,21.6-contact_relief]);
    // Controllers rotated90deg in plan; exact connector orientation is unmeasured.
    color([0,.6,.6,.65]) translate([-87.5,-35,8+contact_relief]) cube([35,70,20-contact_relief]);
    color([0,.5,0,.65]) translate([55,-32.5,8+contact_relief]) cube([30,65,15-contact_relief]);
}
if(view=="perfboard") perfboard_sled();
else if(view=="esp32") controller_sled(36,10);
else if(view=="pca9685") controller_sled(32,-10);
else if(view=="assembly") {
    color("silver") electronics_deck();
    translate([0,0,4]) {color("gold") single_level_prints();single_level_boards();}
}
else if(view=="board-collision") intersection() {single_level_prints();single_level_boards(.001);}
else assert(false,"Unknown sled view");
