// Provisional120 x50 x20mm conventional3S pack. Not a battery enclosure.
$fn=32;
view="print";
module tray(){
 difference(){
  translate([-67,-33,0]) cube([134,66,11]);
  translate([-61,-26,3]) cube([122,52,12]);
  for(x=[-35,35],y=[-29,29]) translate([x-8,y-1.75,-1]) cube([16,3.5,14]);
  for(x=[-55,55],y=[-29,29]) translate([x,y,-1]) cylinder(d=3.5,h=14);
 }
}
if(view=="print")tray();
else{
 color("orange")tray();
 color([.25,.25,.3,.6])translate([-60,-25,4])cube([120,50,20]);
 for(x=[-35,35])color("black")translate([x-7.5,-25,24])cube([15,50,1]);
}
