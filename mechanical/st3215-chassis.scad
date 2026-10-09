// MEC-172 working body. mm. Real boards, servo ports and loaded motion unverified.
leg_library=true;
include <st3215-leg.scad>
chassis_part="assembly";
test_abduction=0;
$fn=32;
body_length=175; body_width=160;
hip_x=115; hip_y=50;
floor_bottom=-48; floor_top=-43;
wall_inner=82.5; wall_outer=87.5; wall_top=-6;
deck_z=8; deck_thickness=4;
riser_height=deck_z-floor_top;
module x_bore(y,z){translate([75,y,z]) rotate([0,90,0]) cylinder(d=3.5,h=25);}
module front_wall(){
 difference(){
  translate([wall_inner,-body_width/2,floor_top-.5]) cube([5,body_width,wall_top-floor_top+.5]);
  for(side=[-1,1],dy=[-26,26],z=[-16,-38]) x_bore(side*hip_y+dy,z);
  // Clears the rotating J1 fork behind its existing notched mounting plate.
  for(side=[-1,1])translate([75,side*hip_y,0])rotate([0,90,0])cylinder(d=34,h=25);
 }
 for(y=[-hip_y,hip_y])translate([wall_inner,y,floor_top]) rotate([90,0,0])
  linear_extrude(4,center=true) polygon([[0,0],[-15,0],[0,25]]);
}
module body_world(){
 difference(){
  union(){
   translate([-body_length/2,-body_width/2,floor_bottom]) cube([body_length,body_width,5]);
   front_wall();rotate([0,0,180])front_wall();
  }
  // Peripheral floor windows leave central battery floor and mounting rails.
  for(y=[-55,55])translate([-45,y-10,floor_bottom-1]) cube([90,20,7]);
  for(x=[-55,55],y=[-29,29])translate([x,y,floor_bottom-1])cylinder(d=3.5,h=7);
  for(x=[-55,55],y=[-60,60])translate([x,y,floor_bottom-1])cylinder(d=3.5,h=7);
 }
}
module body_print(){translate([0,0,-floor_bottom])body_world();}
module deck_print(){
 difference(){
  translate([-70,-70,0])cube([140,140,deck_thickness]);
  for(x=[-55,55],y=[-60,60])translate([x,y,-1])cylinder(d=3.5,h=deck_thickness+2);
  // Generic paired tie slots; actual board hole patterns intentionally unset.
  for(x=[-45,0,45],y=[-45,0,45])translate([x-6,y-1.75,-1])cube([12,3.5,deck_thickness+2]);
  for(y=[-25,25])translate([-10,y-6,-1])cube([20,12,deck_thickness+2]);
 }
}
module riser_print(){difference(){cylinder(d=10,h=riser_height);translate([0,0,-1])cylinder(d=3.5,h=riser_height+2);}}
module risers_world(){for(x=[-55,55],y=[-60,60])translate([x,y,floor_top])riser_print();}
module battery_world(){
 translate([0,0,floor_top])color("orange")import("st3215-battery-tray.stl");
 color([.28,.28,.32,.8])translate([-60,-25,floor_top+4])cube([120,50,20]);
 for(x=[-35,35])color("black")translate([x-7.5,-25,floor_top+24])cube([15,50,1]);
}
module leg_at(rear=false,side=1){translate([rear?-hip_x:hip_x,side*hip_y,0])rotate([0,0,rear?180:0])children();}
module all_legs(){for(rear=[false,true],side=[-1,1])leg_at(rear,side)assembly();}
module electronics_reservations(){
 // Reserved space only: not dimensional models or selected modules.
 color([.2,.65,.4,.75])translate([-60,-50,deck_z+deck_thickness])cube([65,35,20]);
 color([.2,.4,.8,.75])translate([10,-50,deck_z+deck_thickness])cube([50,35,20]);
 color([.8,.4,.2,.75])translate([-60,0,deck_z+deck_thickness])cube([120,45,25]);
}
module chassis_assembly(){
 color("lightgray")body_world();
 battery_world();color("gray")risers_world();
 color([.65,.65,.7,.8])translate([0,0,deck_z])deck_print();
 electronics_reservations();all_legs();
}
module hip_body_collision(){
 intersection(){body_world();union(){
  for(rear=[false,true],side=[-1,1])leg_at(rear,side)
   rotate([side*(rear?-1:1)*test_abduction,0,0])rotate([-90,0,0])
    translate([0,0,-27.5])import("st3215-hip.stl");
 }}
}
if(chassis_part=="assembly")chassis_assembly();
else if(chassis_part=="body")body_print();
else if(chassis_part=="deck")deck_print();
else if(chassis_part=="riser")riser_print();
else if(chassis_part=="body-assembly"){body_world();battery_world();risers_world();translate([0,0,deck_z])deck_print();}
else if(chassis_part=="hip-collision")hip_body_collision();
else assert(false,"Unknown chassis part");
