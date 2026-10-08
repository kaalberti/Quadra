// Working reflected variants. Keep the original flat bed plane z=0.
use <prototype-j1-carrier.scad>
use <prototype-upper-leg.scad>
part="carrier";
mirror([0,1,0]) {
    if(part=="carrier") j1_carrier();
    else if(part=="saddle") knee_ear_saddle();
    else assert(false,"Unknown handed part");
}
