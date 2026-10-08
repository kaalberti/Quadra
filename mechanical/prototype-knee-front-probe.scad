use <prototype-lower-leg.scad>
use <prototype-upper-leg.scad>
q3=79;
intersection() {
    rotate([0,0,-q3]) lower_front_link();
    translate([70,0,0]) upper_plate();
}
