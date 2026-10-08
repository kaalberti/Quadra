// MEC-162 experimental leg; original supported manufacturing kit unchanged.
module fork_leg_fixed(){
multmatrix([[0,0,1,0],[1,0,0,10.349999999999994],[0,1,0,0],[0,0,0,1]]) color("gold") import("hobby-servo-cradle-left.stl"); // J1 cradle left
multmatrix([[0,0,1,0],[1,0,0,10.349999999999994],[0,1,0,0],[0,0,0,1]]) color("gold") import("hobby-servo-cradle-right.stl"); // J1 cradle right
multmatrix([[0,1.2246467991473532e-16,-1,0],[1,0,0,10.349999999999994],[0,-1,-1.2246467991473532e-16,0],[0,0,0,1]]) color("gold") import("hobby-joint-support.stl"); // J1 support
multmatrix([[0,0,1,-18],[1,0,0,0],[0,1,0,0],[0,0,0,1]]) color("gold") import("hobby-joint-front-spacer.stl"); // J1 8mm spacer
multmatrix([[0,0,1,-26],[1,0,0,0],[0,1,0,0],[0,0,0,1]]) color("gold") import("hobby-joint-rear-spacer.stl"); // J1 3mm spacer
multmatrix([[0,0,1,-10],[1,0,0,10.35],[0,1,0,0],[0,0,0,1]]) color("gold") import("prototype-bench-base.stl"); // Bench adapter
multmatrix([[0,0,1,0],[1,0,0,0],[0,1,0,0],[0,0,0,1]]) color([.25,.25,.25,.6]) translate([-10,-9.85,3]) cube([40.7,19.7,42.9]);
}
module fork_leg_j1(){
multmatrix([[0,0,1,50],[6.123233995736766e-17,-1,0,0],[1,6.123233995736766e-17,0,0],[0,0,0,1]]) color("gold") import("hobby-joint-front-arm.stl"); // J1 front arm
multmatrix([[0,1.2246467991473532e-16,-1,-16.200000000000003],[6.123233995736766e-17,1,1.2246467991473532e-16,0],[1,-6.123233995736766e-17,-7.498798913309288e-33,0],[0,0,0,1]]) color("gold") import("hobby-joint-rear-arm.stl"); // J1 rear arm
multmatrix([[0,1.2246467991473532e-16,-1,-23.200000000000003],[6.123233995736766e-17,1,1.2246467991473532e-16,0],[1,-6.123233995736766e-17,-7.498798913309288e-33,0],[0,0,0,1]]) color("gold") import("hobby-joint-retainer.stl"); // J1 retainer
multmatrix([[1,0,0,0],[0,0,1,-28],[0,-1,0,0],[0,0,0,1]]) color("gold") import("prototype-j1-carrier-mirrored.stl"); // J1 carrier
}
module fork_leg_j2(){
multmatrix([[0,1,0,85],[0,0,1,-18],[1,0,0,10.349999999999994],[0,0,0,1]]) color("gold") import("hobby-servo-cradle-right.stl"); // J2 cradle left
multmatrix([[0,1,0,85],[0,0,1,-18],[1,0,0,10.349999999999994],[0,0,0,1]]) color("gold") import("hobby-servo-cradle-left.stl"); // J2 cradle right
multmatrix([[0,-1,1.2246467991473532e-16,85],[0,-1.2246467991473532e-16,-1,-18],[1,0,0,10.349999999999994],[0,0,0,1]]) color("gold") import("hobby-joint-support.stl"); // J2 support
multmatrix([[0,-1,0,85],[0,0,1,-36],[-1,0,0,0],[0,0,0,1]]) color("gold") import("hobby-joint-front-spacer.stl"); // J2 8mm spacer
multmatrix([[0,-1,0,85],[0,0,1,-44],[-1,0,0,0],[0,0,0,1]]) color("gold") import("hobby-joint-rear-spacer.stl"); // J2 3mm spacer
multmatrix([[0,1,0,85],[0,0,1,-18],[1,0,0,0],[0,0,0,1]]) color([.25,.25,.25,.6]) translate([-10,-9.85,3]) cube([40.7,19.7,42.9]);
}
module fork_leg_upper(){
multmatrix([[0.6952682860952114,0.7187503115479167,8.802152684233191e-17,85],[0,1.2246467991473532e-16,-1,-41.2],[-0.7187503115479167,0.6952682860952114,8.514580811151668e-17,0],[0,0,0,1]]) color("gold") import("hobby-joint-retainer.stl"); // J2 retainer
multmatrix([[-0.6952682860952114,0.7187503115479167,0,85],[0,0,1,10],[0.7187503115479167,0.6952682860952114,0,0],[0,0,0,1]]) color("gold") import("prototype-upper-leg-saddle-mirrored.stl"); // Knee saddle
multmatrix([[-0.6952682860952114,0.7187503115479167,0,102.03407300933267],[0,0,1,37],[0.7187503115479167,0.6952682860952114,0,-17.609382632923968],[0,0,0,1]]) color("gold") import("prototype-cable-guide.stl"); // Cable guide
multmatrix([[-0.6952682860952114,0.7187503115479167,0,133.6687800266648],[0,0,1,-26],[0.7187503115479167,0.6952682860952114,0,-50.31252180835418],[0,0,0,1]]) color("gold") import("prototype-knee-support.stl"); // Knee support
multmatrix([[0.6952682860952114,-0.7187503115479167,0,133.6687800266648],[0,0,1,-36],[-0.7187503115479167,-0.6952682860952114,0,-50.31252180835418],[0,0,0,1]]) color("gold") import("prototype-knee-spacer.stl"); // Knee 10mm spacer
multmatrix([[0.6952682860952114,-0.7187503115479167,0,133.6687800266648],[0,0,1,-44],[-0.7187503115479167,-0.6952682860952114,0,-50.31252180835418],[0,0,0,1]]) color("gold") import("hobby-joint-rear-spacer.stl"); // Knee 3mm spacer
multmatrix([[-0.6952682860952114,4.4010763421165954e-17,-0.7187503115479167,96.50000498476666],[0,1,6.123233995736766e-17,-18],[0.7187503115479167,4.257290405575834e-17,-0.6952682860952114,11.124292577523383],[0,0,0,1]]) color("royalblue") import("prototype-pitch-fork-upper-mirrored.stl"); // Upper fork
multmatrix([[-0.7187503115479167,-0.6952682860952114,0,133.6687800266648],[0,0,1,-18],[-0.6952682860952114,0.7187503115479167,0,-50.31252180835418],[0,0,0,1]]) color([.25,.25,.25,.6]) translate([-10,-9.85,3]) cube([40.7,19.7,42.9]);
}
module fork_leg_lower(){
multmatrix([[-0.5725752255153884,0.8198521885840168,1.0040293585233684e-16,133.6687800266648],[0,1.2246467991473532e-16,-1,-41.2],[-0.8198521885840168,-0.5725752255153884,-7.012024171984944e-17,-50.31252180835418],[0,0,0,1]]) color("gold") import("hobby-joint-retainer.stl"); // Knee retainer
multmatrix([[0.5725752255153884,0.8198521885840168,0,90.15306288749528],[0,0,1,29],[0.8198521885840168,-0.5725752255153884,0,-112.62128814073944],[0,0,0,1]]) color("gold") import("prototype-foot.stl"); // Foot carrier
multmatrix([[0.5725752255153884,5.020146792616842e-17,-0.8198521885840168,146.78641504400906],[0,1,6.123233995736766e-17,-18],[0.8198521885840168,-3.506012085992472e-17,0.5725752255153884,-59.47372541660039],[0,0,0,1]]) color("royalblue") import("prototype-pitch-fork-lower-mirrored.stl"); // Lower fork
}
module upper_delta(q2){translate([85,-18,0]) rotate([0,-(q2-44.0486),0]) translate([-85,18,0]) children();}
module lower_delta(q3){translate([133.6687800266648,-18,-50.31252180835418]) rotate([0,q3-78.9786,0]) translate([-133.6687800266648,18,50.31252180835418]) children();}
module fork_leg(q1=0,q2=44.0486,q3=78.9786){fork_leg_fixed();rotate([q1,0,0]){fork_leg_j1();fork_leg_j2();upper_delta(q2){fork_leg_upper();lower_delta(q3) fork_leg_lower();}}}
module placed_upper(){multmatrix([[-0.6952682860952114,4.4010763421165954e-17,-0.7187503115479167,96.50000498476666],[0,1,6.123233995736766e-17,-18],[0.7187503115479167,4.257290405575834e-17,-0.6952682860952114,11.124292577523383],[0,0,0,1]]) import("prototype-pitch-fork-upper-mirrored.stl");}
module placed_lower(){multmatrix([[0.5725752255153884,5.020146792616842e-17,-0.8198521885840168,146.78641504400906],[0,1,6.123233995736766e-17,-18],[0.8198521885840168,-3.506012085992472e-17,0.5725752255153884,-59.47372541660039],[0,0,0,1]]) import("prototype-pitch-fork-lower-mirrored.stl");}
module only_forks(q1=0,q2=44.0486,q3=78.9786){rotate([q1,0,0]) upper_delta(q2){placed_upper();lower_delta(q3) placed_lower();}}
