use <fork-leg-parts.scad>
use <prototype-pitch-fork.scad>
include <prototype-j1-layout.scad>
kind="upper"; mode="source";
if(mode=="placed") {
    if(kind=="upper") placed_upper(); else placed_lower();
} else multmatrix(pitch_point_to_world()) rotate([0,0,44.0486]) {
    if(kind=="upper") pitch_fork("upper");
    else translate([-70,0,0]) rotate([0,0,-78.9786]) pitch_fork("lower");
}
