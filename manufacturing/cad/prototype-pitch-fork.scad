// MEC-161 experimental one-piece pitch outputs. Existing interfaces retained.
use <prototype-upper-leg.scad>
use <prototype-lower-leg.scad>
use <hobby-joint-rear-arm.scad>
include <hobby-joint-common.scad>
part="upper"; // upper, lower
view="print"; // print, joint
hand=1; // -1 creates the opposite physical print; never a placement transform.
module pitch_fork(kind="upper") {
    side=kind=="upper"?1:-1;
    union() {
        translate([0,0,horn_z])
            if(kind=="upper") upper_plate(); else lower_front_link();
        translate([0,0,rear_top]) rotate([180,0,kind=="upper"?180:0]) rear_arm();
        // Six millimetre side web; overlaps both plates by3mm in y.
        translate([side*bridge_r-6,-16,rear_top-rear_t])
            cube([12,6,horn_z+front_t-rear_top+rear_t]);
        // Flat bed lands under the tips; avoid a long unsupported web.
        for(z=[rear_top-rear_t,horn_z])
            translate([side*bridge_r-6,-16,z]) cube([12,3,z==horn_z?front_t:rear_t]);
    }
}
assert(part=="upper" || part=="lower");
assert(hand==1 || hand==-1);
module handed_fork() {
    if(hand==1) pitch_fork(part); else mirror([0,1,0]) pitch_fork(part);
}
if(view=="joint") handed_fork();
else if(view=="print") translate([0,0,16]) rotate([hand*90,0,0]) handed_fork();
else assert(false,"Unknown view");
