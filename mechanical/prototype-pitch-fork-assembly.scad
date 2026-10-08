// Local pitch-frame experiment. Physical STL placement uses only rotations.
use <hobby-joint-assembly.scad>
use <prototype-pitch-leg.scad>
use <prototype-upper-leg.scad>
use <prototype-foot.scad>
use <hobby-joint-bearing-parts.scad>
q2=44.0486; q3=78.9786;
module placed_fork(kind) {
    // Inverse of print=Tz(16)*Rx(90), determinant+1.
    translate([0,-16,0]) rotate([-90,0,0])
        import(str("prototype-pitch-fork-",kind,".stl"));
}
color("orange") fixed_prints();
color([.25,.25,.25,.6]) servo_reservation();
rotate([0,0,q2]) {
    color("royalblue") placed_fork("upper");
    color("orange") translate([0,0,28]) knee_ear_saddle();
    color("silver") translate([0,0,-23.2]) rotate([180,0,0]) bearing_retainer();
    translate([-70,0,0]) {
        color("orange") knee_fixed_prints();
        color([.25,.25,.25,.6]) knee_case_reservation();
        rotate([0,0,-q3]) {
            color("seagreen") placed_fork("lower");
            color("orange") translate([-76,0,47]) foot_carrier();
            color("silver") translate([0,0,-23.2]) rotate([180,0,0]) bearing_retainer();
        }
    }
}
