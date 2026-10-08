#include <stdio.h>
#include <stdlib.h>
#include <initializer_list>
#include "leg_geometry.h"
int main(int argc,char** argv){
  if(argc!=4)return 1;
  bench::LegPose p;
  if(!bench::forwardKinematics({},atof(argv[1]),atof(argv[2]),atof(argv[3]),p))return 2;
  printf("{\"knee\":[%.9f,%.9f,%.9f],\"foot\":[%.9f,%.9f,%.9f],\"pad_center\":[%.9f,%.9f,%.9f]}\n",
    p.knee.x,p.knee.y,p.knee.z,p.footReference.x,p.footReference.y,p.footReference.z,
    p.padCenter.x,p.padCenter.y,p.padCenter.z);
}
