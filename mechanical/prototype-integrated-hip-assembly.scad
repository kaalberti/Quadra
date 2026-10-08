use <fork-leg-parts.scad>
q1=0;q2=44.0486;q3=78.9786;
module placed_integrated_hip() {
    translate([0,-28,0]) rotate([-90,0,0]) import("prototype-integrated-hip.stl");
}
module integrated_hip_leg(a=q1,b=q2,c=q3) {
    fork_leg_fixed();
    rotate([a,0,0]) {
        color("mediumorchid") placed_integrated_hip();
        // Existing J1 retainer remains separate and accessible.
        multmatrix([[0,0,-1,-23.2],[0,1,0,0],[1,0,0,0],[0,0,0,1]])
            color("gold") import("hobby-joint-retainer.stl");
        fork_leg_j2();
        upper_delta(b) {fork_leg_upper(); lower_delta(c) fork_leg_lower();}
    }
}
integrated_hip_leg();
