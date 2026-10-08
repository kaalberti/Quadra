// MEC-155: placement study only. No released chassis or mirrored print parts.
include <hobby-joint-common.scad>
include <prototype-j1-layout.scad>
use <hobby-joint-assembly.scad>
use <prototype-three-dof-leg.scad>
use <prototype-j1-carrier.scad>
use <prototype-pitch-leg.scad>
use <prototype-upper-leg.scad>
q1=0; q2=44.0486; q3=78.9786;
root_length=150; root_width=110; root_height=120;
deck_height=155; // Raised placeholder, attachment brackets not yet designed.
mode="assembly"; // assembly, cases, case-deck-collision, case-pair-collision, leg-deck-collision
$fn=24;
function placement(f,s)=[[f,0,0,f*root_length/2],[0,s,0,s*root_width/2],[0,0,1,root_height],[0,0,0,1]];
module local_leg() {
    multmatrix(j1_point_to_world()) {
        color("orange") fixed_prints();
        color("dimgray") servo_reservation();
        color("silver") {fixed_hardware();bearing_envelope();}
    }
    rotate([q1,0,0]) {
        color("mediumpurple") j1_fork();
        color("gold") carrier_world();
        multmatrix(pitch_point_to_world()) pitch_leg(q2,q3,false);
    }
}
module local_cases() {
    multmatrix(j1_point_to_world()) servo_reservation();
    rotate([q1,0,0]) multmatrix(pitch_point_to_world()) {
        servo_reservation();
        rotate([0,0,q2]) translate([upper_leg_knee_x(),0,0]) knee_case_reservation();
    }
}
module deck() {translate([-90,-55,deck_height]) cube([180,110,4]);}
if(mode=="assembly") {
    for(f=[-1,1],s=[-1,1]) multmatrix(placement(f,s)) local_leg();
    color([0.5,0.5,0.5,0.45]) deck();
    // Unmeasured conservative space claims, not mounting-hole patterns.
    color("teal") translate([-70,-20,deck_height+4]) cube([70,35,20]);
    color("darkgreen") translate([5,-15,deck_height+4]) cube([65,30,15]);
}
else if(mode=="cases") for(f=[-1,1],s=[-1,1]) multmatrix(placement(f,s)) local_cases();
else if(mode=="case-deck-collision") intersection() {
    deck();
    union() {for(f=[-1,1],s=[-1,1]) multmatrix(placement(f,s)) local_cases();}
}
else if(mode=="case-pair-collision") {
    roots=[[-1,-1],[-1,1],[1,-1],[1,1]];
    for(i=[0:2],j=[i+1:3]) intersection() {
        multmatrix(placement(roots[i][0],roots[i][1])) local_cases();
        multmatrix(placement(roots[j][0],roots[j][1])) local_cases();
    }
}
else if(mode=="leg-deck-collision") intersection() {
    deck();
    union() {for(f=[-1,1],s=[-1,1]) multmatrix(placement(f,s)) local_leg();}
}
else assert(false,"Unknown four-leg study mode");
