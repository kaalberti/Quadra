// MEC-156. Local bench-leg frame, mm. Working prototype, fit untested.
include <hobby-joint-common.scad>
include <prototype-j1-layout.scad>
use <hobby-joint-assembly.scad>
$fn=32;
part="left"; // left, right (print coordinates)
module chassis_mount_world() {
    difference() {
        union() {
            // Seven-mm vertical plate mates with J1 support at x=-3.
            translate([-10,-10,-24]) cube([7,41,59]);
            // Six-mm deck flange reaches inboard, away from the case/horn.
            translate([-36,-35,29]) cube([33,66,6]);
        }
        // Same four slotted cradle/support fixing centres, with shaft access.
        for(y=[-14-shaft_x,14-shaft_x],z=[-17.25,17.25]) hull()
            for(dz=[-1,1]) translate([-11,y,z+dz]) rotate([0,90,0]) cylinder(d=3.5,h=9);
        translate([-11,0,0]) rotate([0,90,0]) cylinder(d=22,h=9);
        // Passive-support ribs project behind its mounting face. Pocket only
        // that projection, leaving the broad intended x=-3 mating face.
        minkowski() {
            intersection() {
                multmatrix(j1_point_to_world()) fixed_prints();
                translate([-20,-60,-60]) cube([16.999,120,120]);
            }
            cube([0.4,0.4,0.4],center=true);
        }
        for(x=[-28,-16],y=[-25,-10]) translate([x,y,28]) cylinder(d=3.5,h=8);
    }
}
module chassis_mount_print(hand=1) {
    // Mount plate flat on the bed; deck flange becomes a vertical wall.
    // The right hand reflects world y; two of each serve the four corners.
    // For the original hand this is a proper rotation (determinant +1).
    multmatrix([[0,hand,0,0],[0,0,-1,0],[-1,0,0,-3],[0,0,0,1]]) chassis_mount_world();
}
if(part=="left") chassis_mount_print(1);
else if(part=="right") chassis_mount_print(-1);
else assert(false,"Unknown chassis mount hand");
