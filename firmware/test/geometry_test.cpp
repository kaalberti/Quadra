#include <assert.h>
#include <stdio.h>
#include <limits>
#include <initializer_list>
#include "leg_geometry.h"
using namespace bench;
bool near(double a,double b){return fabs(a-b)<1e-8;}
int main(){
  LegGeometry g;LegPose p;
  assert(forwardKinematics(g,0,0,0,p));
  assert(near(p.footReference.x,85)&&near(p.footReference.y,32)&&near(p.footReference.z,-155));
  assert(near(p.padCenter.y,33)&&near(p.knee.z,-70));
  assert(forwardKinematics(g,0,90,0,p));
  assert(near(p.footReference.x,240)&&near(p.footReference.z,0));
  assert(forwardKinematics(g,0,0,90,p));
  assert(near(p.footReference.x,0)&&near(p.footReference.z,-70));
  assert(forwardKinematics(g,90,0,0,p));
  assert(near(p.footReference.y,155)&&near(p.footReference.z,32));
  LegPose baseline;assert(forwardKinematics(g,0,44,79,baseline));
  for(double a:{-25.0,15.0,30.0}){
    assert(forwardKinematics(g,a,44,79,p));assert(near(p.footReference.x,baseline.footReference.x));
    assert(near(hypot(p.footReference.y,p.footReference.z),hypot(baseline.footReference.y,baseline.footReference.z)));
    assert(near(hypot(p.padCenter.y-p.footReference.y,p.padCenter.z-p.footReference.z),1));
  }
  auto previous=p;g.upperMm=0;assert(!forwardKinematics(g,0,0,0,p));
  assert(near(previous.footReference.x,p.footReference.x));g.upperMm=70;
  assert(!forwardKinematics(g,std::numeric_limits<double>::quiet_NaN(),0,0,p));
  g.pitchFloorYmm=std::numeric_limits<double>::infinity();assert(!forwardKinematics(g,0,0,0,p));
  puts("PASS: special poses, abduction invariants, pad-centre offset and invalid geometry");
}
