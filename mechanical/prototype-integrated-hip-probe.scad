use <prototype-integrated-hip-assembly.scad>
use <fork-leg-parts.scad>
q1=0;q2=44.0486;q3=78.9786;
intersection() {
    rotate([q1,0,0]) placed_integrated_hip();
    union() {
        fork_leg_fixed();
        rotate([q1,0,0]) {
            multmatrix([[0,1,0,85],[0,0,1,-18],[1,0,0,0],[0,0,0,1]])
                translate([-10,-9.85,3]) cube([40.7,19.7,42.9]);
            upper_delta(q2) {fork_leg_upper(); lower_delta(q3) fork_leg_lower();}
        }
    }
}
