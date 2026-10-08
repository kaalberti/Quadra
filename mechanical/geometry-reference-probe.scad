// Independent transform-chain probe; current CAD is not modified.
include <prototype-j1-layout.scad>
include <hobby-joint-common.scad>
use <prototype-upper-leg.scad>
q1=0;q2=44.0486;q3=78.9786;
pad_point=[-85,0,51]; // test runner extracts actual patch centre from pitch CAD
function rx(a)=[[1,0,0,0],[0,cos(a),-sin(a),0],[0,sin(a),cos(a),0],[0,0,0,1]];
function rz(a)=[[cos(a),-sin(a),0,0],[sin(a),cos(a),0,0],[0,0,1,0],[0,0,0,1]];
function tr(x,y,z)=[[1,0,0,x],[0,1,0,y],[0,0,1,z],[0,0,0,1]];
base=rx(q1)*pitch_point_to_world()*rz(q2);
knee=base*[upper_leg_knee_x(),0,horn_z,1];
foot=base*tr(upper_leg_knee_x(),0,0)*rz(-q3)*[pad_point[0],0,horn_z,1];
pad=base*tr(upper_leg_knee_x(),0,0)*rz(-q3)*concat(pad_point,[1]);
echo("FK_KNEE",knee);
echo("FK_FOOT",foot);
echo("FK_PAD",pad);
cube(0.1); // cheap CSG output; no assembly/CGAL export needed
