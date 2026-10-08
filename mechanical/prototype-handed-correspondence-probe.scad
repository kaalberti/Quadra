include <prototype-j1-layout.scad>
include <working-handed-probe-data.scad>
use <prototype-j1-carrier.scad>
use <prototype-upper-leg.scad>
part="carrier";
mode="source"; // source, placed: compare fresh exports without coplanar booleans.
module source_shape() {
    if(part=="carrier") carrier_world();
    else multmatrix(pitch_point_to_world()) rotate([0,0,44.0486])
        translate([0,0,upper_leg_saddle_z()]) knee_ear_saddle();
}
module placed_shape() {
    translate([-75,-55,-120]) {
        if(part=="carrier") multmatrix(carrier_pose) import("prototype-j1-carrier-mirrored.stl");
        else multmatrix(saddle_pose) import("prototype-upper-leg-saddle-mirrored.stl");
    }
}
if(mode=="source") source_shape();
else if(mode=="placed") placed_shape();
else assert(false,"Unknown correspondence probe mode");
