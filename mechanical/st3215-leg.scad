// MEC-170 ST3215 12V working leg. mm. Physical dimensions remain to be checked.
// Shaft-axis datum at origin, axis +Z. Supplied wheel OD19.2, four holes PCD14.
$fn=48;
part="assembly";
q1=0; q2=44.0486; q3=78.9786;
L1=70; L2=85; pitch_forward=85;
case_grip_height=35; // Adjust to actual band; drawing main shell is29mm.
// Conservative envelope: drawing45.22 x24.72 x35; wheel overall37.25.
module servo_case(){
 color([.22,.22,.24]) translate([-10.11,-12.36,-17.5]) cube([45.22,24.72,35]);
 for(s=[-1,1]) color("silver") translate([0,0,s*18.125]) cylinder(d=19.2,h=1,center=true);
}
module axial_hole(x,y,d=3.5){translate([x,y,-40]) cylinder(d=d,h=80);}
module clamp_raw(top=false){
 difference(){
  translate([18,-22,top?.5:-22.5]) cube([11,44,22]);
  translate([17,-12.76,-(case_grip_height+.8)/2]) cube([13,25.52,case_grip_height+.8]);
  for(y=[-18,18]) axial_hole(23.5,y);
 }
}
module clamp_print(top=false){
 if(top) translate([0,0,22.5]) rotate([180,0,0]) clamp_raw(true);
 else translate([0,0,22.5]) clamp_raw(false);
}
module horn_holes(){
 axial_hole(0,0,8);
 // Slots tolerate supplied M2/M3 hardware; dimensions/thread engagement unverified.
 for(a=[0,90,180,270]) rotate([0,0,a]) hull()
  for(r=[6.5,7.5]) axial_hole(r,0,3.2);
}
foot_pitch=78.9786-44.0486;
function fnorm()=[cos(foot_pitch),-sin(foot_pitch)];
function ftan()=[sin(foot_pitch),cos(foot_pitch)];
function footpoint(n,t)=[-85+fnorm()[0]*n+ftan()[0]*t,fnorm()[1]*n+ftan()[1]*t];
module foot_profile(){polygon([footpoint(0,-10),footpoint(0,10),footpoint(8,10),footpoint(8,-10)]);}
module plate(kind="lower"){
 difference(){
  linear_extrude(5) union(){
   circle(d=28);
   if(kind=="upper") hull(){circle(d=28);translate([-46.5,0]) square([16,48],center=true);}
   else if(kind=="lower") hull(){circle(d=28);foot_profile();}
   else hull(){circle(d=28);translate([-20,0]) square([12,28],center=true);}
  }
  horn_holes();
  if(kind=="upper"){
   translate([-70,0,-1]) cylinder(d=36,h=7);
   for(y=[-18,18]) axial_hole(-46.5,y);
  }
  if(kind=="lower") axial_hole(footpoint(4,0)[0],footpoint(4,0)[1],3.5);
 }
}
module yoke(kind="lower"){
 union(){
  translate([0,0,23]) plate(kind);
  translate([0,0,-28]) plate(kind);
  // Web behind shaft clears case's -10.11mm end by5.89mm.
  translate([-22,kind=="lower"?-12:-14,-28]) cube([6,kind=="lower"?24:28,56]);
  if(kind=="lower") difference(){translate([0,0,-28]) linear_extrude(56) foot_profile();axial_hole(footpoint(4,0)[0],footpoint(4,0)[1],3.5);}
 }
}
module fork_print(kind="lower") {translate([0,0,kind=="upper"?24:14]) rotate([90,0,0]) yoke(kind);}
module shims(){
 // Nominal wheel-to-fork gap4.375mm. Actual asymmetric wheel faces must be measured.
 difference(){cylinder(d=19.2,h=4.375);horn_holes();}
}
module hip_world(){
 union(){
  multmatrix([[0,0,1,0],[0,1,0,0],[-1,0,0,0],[0,0,0,1]]) yoke("hip");
  // Shaft web is above datum after mapping; bridge below servo case instead.
  translate([-28,-27.5,16]) cube([137,5,6]);
  translate([-28,-27.5,16]) cube([12,41.5,6]);
  // J2 rear mounting plate, outside its35mm axial case envelope.
  difference(){
   translate([61,-27.5,16]) cube([48,5,19]);
   for(x=[67,103]) translate([x,-30,23.5]) rotate([-90,0,0]) cylinder(d=3.5,h=12);
  }
 }
}
module hip_print(){translate([0,0,27.5]) rotate([90,0,0]) hip_world();}
module mount_print(){
 difference(){
  union(){translate([12,-30,0]) cube([30,60,5]);translate([18,-22,0]) cube([11,44,5]);}
  translate([0,0,-1]) cylinder(d=32,h=7); // Clears rotating J1 wheel/fork hub.
  for(y=[-18,18]) translate([23.5,y,-1]) cylinder(d=3.5,h=7);
  for(x=[16,38],y=[-26,26]) translate([x,y,-1]) cylinder(d=3.5,h=7);
 }
}
module clamp_pair(){color("gold") {clamp_raw();clamp_raw(true);}}
module pitch_frame(){multmatrix([[0,1,0,85],[0,0,1,0],[1,0,0,0],[0,0,0,1]]) children();}
module wheel_spacers(){color("silver") {translate([0,0,18.625]) shims();translate([0,0,-23]) shims();}}
module assembly(){
 multmatrix([[0,0,1,0],[0,1,0,0],[-1,0,0,0],[0,0,0,1]]) {servo_case();clamp_pair();translate([0,0,-27.5]) color("orange") mount_print();}
 rotate([q1,0,0]) {
  color("orchid") hip_world();
  multmatrix([[0,0,1,0],[0,1,0,0],[-1,0,0,0],[0,0,0,1]]) wheel_spacers();
  pitch_frame(){
   servo_case();clamp_pair();
   rotate([0,0,-q2]){
    wheel_spacers();color("royalblue") yoke("upper");
    translate([-70,0,0]) {servo_case();clamp_pair();rotate([0,0,q3]){wheel_spacers();color("seagreen") yoke("lower");}}
   }
  }
 }
}
if(part=="assembly") assembly();
else if(part=="clamp-bottom") clamp_print();
else if(part=="clamp-top") clamp_print(true);
else if(part=="upper") fork_print("upper");
else if(part=="lower") fork_print("lower");
else if(part=="hip") hip_print();
else if(part=="mount") mount_print();
else if(part=="shims") shims();
else if(part=="collision") intersection(){printed_world();cases_world();}
else if(part=="pair-collision") pair_collision();
else assert(false,"Unknown part");


module cases_world(){
 multmatrix([[0,0,1,0],[0,1,0,0],[-1,0,0,0],[0,0,0,1]]) servo_case();
 rotate([q1,0,0]) pitch_frame(){servo_case();rotate([0,0,-q2]) translate([-70,0,0]) servo_case();}
}
module printed_world(){
 multmatrix([[0,0,1,0],[0,1,0,0],[-1,0,0,0],[0,0,0,1]]) {clamp_pair();translate([0,0,-27.5])mount_print();}
 rotate([q1,0,0]){hip_world();pitch_frame(){clamp_pair();rotate([0,0,-q2]){yoke("upper");translate([-70,0,0]){clamp_pair();rotate([0,0,q3])yoke("lower");}}}}
}


module group(i){
 if(i==0) multmatrix([[0,0,1,0],[0,1,0,0],[-1,0,0,0],[0,0,0,1]]) {clamp_pair();translate([0,0,-27.5])mount_print();}
 if(i==1) rotate([q1,0,0]){hip_world();pitch_frame()clamp_pair();}
 if(i==2) rotate([q1,0,0])pitch_frame()rotate([0,0,-q2]){yoke("upper");translate([-70,0,0])clamp_pair();}
 if(i==3) rotate([q1,0,0])pitch_frame()rotate([0,0,-q2])translate([-70,0,0])rotate([0,0,q3])yoke("lower");
}
module pair_collision(){union(){for(i=[0:2],j=[i+1:3])intersection(){group(i);group(j);}}}
