// MEC-166 working attachment option; original deck and MFG-003 stay unchanged.
use <prototype-chassis-assembly.scad>
view="print"; // print, layout
$fn=32;
module electronics_deck() {
    difference() {
        translate([0,0,-155]) chassis_deck();
        // Four strap lanes, two through-slots each. Actual PCB mounts are TBD.
        for(x=[-60,-15,15,60],y=[-20,20]) hull()
            for(dx=[-2.5,2.5]) translate([x+dx,y,-1]) cylinder(d=3,h=6);
    }
}
if(view=="print") electronics_deck();
else if(view=="layout") {
    color("silver") electronics_deck();
    // Unmeasured space claims only, floating to indicate an insulating mount.
    color([0,.6,.6,.5]) translate([-70,-20,7]) cube([70,35,20]);
    color([0,.5,0,.5]) translate([5,-15,7]) cube([65,30,15]);
}
else assert(false,"Unknown electronics deck view");