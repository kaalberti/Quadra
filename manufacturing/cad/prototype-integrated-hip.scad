// MEC-164 experimental integrated moving hip. No supported-kit replacement.
include <prototype-j1-layout.scad>
include <hobby-joint-common.scad>
use <prototype-j1-carrier.scad>
use <hobby-joint-front-arm.scad>
use <hobby-joint-rear-arm.scad>
view="print";
hand=1;
module integrated_hip_world() {
    union() {
        // Shorter integral tabs reach worldy=0, giving13mm arm contact width.
        multmatrix([[1,0,0,0],[0,0,1,-28],[0,1,0,0],[0,0,0,1]]) intersection() {
            j1_carrier();
            translate([-100,-100,-1]) cube([400,300,29]);
        }
        multmatrix(j1_point_to_world()) rotate([0,0,90]) {
            translate([0,0,50]) front_arm();
            translate([0,0,-16.2]) rotate([180,0,0]) rear_arm();
        }
        // Positive overlap at the former mating planes; avoid a face-only union.
        // Also closes unused fixing-hole portions within these integral joints.
        for(x=[-18.2,48]) translate([x,-13,-64]) cube([4,13,12]);
    }
}
// Proper world->print rotation. Carrier's broad floor is on the bed.
module handed_hip() {
    if(hand==1) integrated_hip_world(); else mirror([0,1,0]) integrated_hip_world();
}
assert(hand==1 || hand==-1);
if(view=="print") translate([0,0,28]) rotate([hand*90,0,0]) handed_hip();
else if(view=="world") integrated_hip_world();
else assert(false,"Unknown view");
