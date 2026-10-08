#include <assert.h>
#include <stdio.h>
#include <limits>
#include "leg_inverse.h"
using namespace bench;
bool near(double a,double b){return fabs(a-b)<1e-7;}
void residual(const LegGeometry& g,const Point3& target,const InverseResult& solved){
  for(unsigned i=0;i<solved.count;++i){
    LegPose p;const auto& a=solved.solutions[i];
    assert(forwardKinematics(g,a.q1,a.q2,a.q3,p));
    assert(near(p.footReference.x,target.x)&&near(p.footReference.y,target.y)&&near(p.footReference.z,target.z));
  }
}
int main(){
  LegGeometry g;unsigned tested=0;
  for(double q1:{-25.0,0.0,15.0,30.0})
   for(double q2:{20.0,44.0486,55.0})
    for(double q3:{60.0,78.9786,90.0}){
      LegPose p;assert(forwardKinematics(g,q1,q2,q3,p));
      auto solved=inverseKinematics(g,p.footReference);
      assert(solved.status==InverseStatus::Unique && solved.count==1);
      assert(near(solved.solutions[0].q1,q1)&&near(solved.solutions[0].q2,q2)&&near(solved.solutions[0].q3,q3));
      residual(g,p.footReference,solved);++tested;
    }
  LegPose nominal;forwardKinematics(g,0,44.0486,78.9786,nominal);
  JointBounds wide{{-180,-180,-180},{180,180,180}};
  auto branches=inverseKinematics(g,nominal.footReference,wide);
  assert(branches.status==InverseStatus::Ambiguous && branches.count==4);
  residual(g,nominal.footReference,branches);
  assert(inverseKinematics(g,{85,0,0}).status==InverseStatus::Unreachable);
  assert(inverseKinematics(g,{85,32,-155.000001},wide).status==InverseStatus::Unreachable);
  assert(inverseKinematics(g,{85,32,-10},wide).status==InverseStatus::Unreachable);
  LegPose outside;forwardKinematics(g,31,44,79,outside);
  assert(inverseKinematics(g,outside.footReference).status==InverseStatus::OutsideBounds);
  auto bad=nominal.footReference;bad.x=std::numeric_limits<double>::quiet_NaN();
  assert(inverseKinematics(g,bad).status==InverseStatus::InvalidTarget);
  JointBounds reversed;reversed.minimum.q1=40;
  assert(inverseKinematics(g,nominal.footReference,reversed).status==InverseStatus::InvalidBounds);
  auto broken=g;broken.lowerMm=0;
  assert(inverseKinematics(broken,nominal.footReference).status==InverseStatus::InvalidGeometry);
  broken=g;broken.pitchFloorYmm=-50;
  assert(inverseKinematics(broken,{240,0,0},wide).status==InverseStatus::Singular);
  forwardKinematics(g,0,0,0,outside);
  auto straight=inverseKinematics(g,outside.footReference,wide);
  assert(straight.count==2 && straight.singular);residual(g,outside.footReference,straight);
  auto folded=inverseKinematics(g,{100,32,0},wide);
  assert(folded.status==InverseStatus::Unique && folded.count==1 && folded.singular);
  residual(g,{100,32,0},folded);
  // A target 1um outside the abduction cylinder is rejected, never projected.
  assert(inverseKinematics(g,{100,31.999999,0},wide).status==InverseStatus::Unreachable);
  // Non-default offsets and link lengths exercise the generic solver contract.
  g={65,80,90,-12,4,49,50};forwardKinematics(g,12,40,75,outside);
  auto changed=inverseKinematics(g,outside.footReference);assert(changed.status==InverseStatus::Unique);
  residual(g,outside.footReference,changed);
  printf("PASS: %u bounded FK/IK round trips, four branches, reach boundaries and singular/invalid cases\n",tested);
}
