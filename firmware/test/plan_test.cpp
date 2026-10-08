#include <assert.h>
#include <stdio.h>
#include <limits>
#include "leg_plan.h"
using namespace bench;
LegCalibration synthetic(){ // TEST ONLY; actual JSON profiles remain unset
  return {{{true,-25,30,1475,1530,-25,30,1450,1550},
           {true,20,55,1476,1546,20,55,1450,1550},
           {true,60,90,1530,1470,60,90,1450,1550}}};
}
LegPlan sentinel(){return {{7,8,9},{1,2,3},3,true};}
void unchanged(const LegPlan& p){
  assert(p.angles.q1==7 && p.angles.q2==8 && p.angles.q3==9);
  assert(p.pulses[0]==1 && p.pulses[1]==2 && p.pulses[2]==3 && p.branch==3 && p.singular);
}
int main(){
  LegGeometry g;LegPose nominal;forwardKinematics(g,0,44.0486,78.9786,nominal);
  LegPlan plan=sentinel();LegCalibration unset;
  auto result=prepareLegPlan(g,nominal.footReference,unset,plan);
  assert(result.status==PlanStatus::CalibrationRequired);unchanged(plan);
  auto c=synthetic();result=prepareLegPlan(g,nominal.footReference,c,plan);
  assert(result.status==PlanStatus::Ok && result.branchCount==1 && !plan.singular);
  assert(plan.pulses[0]==1500 && plan.pulses[1]==1524 && plan.pulses[2]==1492);
  plan=sentinel();c.joints[2].measured=false;
  result=prepareLegPlan(g,nominal.footReference,c,plan);
  assert(result.status==PlanStatus::CalibrationRequired && result.failedJoint==2);unchanged(plan);
  c=synthetic();c.joints[2].angleB=c.joints[2].angleA;
  assert(prepareLegPlan(g,nominal.footReference,c,plan).status==PlanStatus::CalibrationInvalid);unchanged(plan);
  c=synthetic();c.joints[2].minimumAngle=80;
  result=prepareLegPlan(g,nominal.footReference,c,plan);
  assert(result.status==PlanStatus::AngleOutsideCalibration && result.failedJoint==2);unchanged(plan);
  c=synthetic();c.joints[2].pulseA=1800;c.joints[2].pulseB=1700;c.joints[2].maximumPulse=1900;
  result=prepareLegPlan(g,nominal.footReference,c,plan);
  assert(result.status==PlanStatus::PulseOutsideBench && result.failedJoint==2);unchanged(plan);
  c=synthetic();assert(prepareLegPlan(g,{85,0,0},c,plan).status==PlanStatus::Unreachable);unchanged(plan);
  auto invalid=nominal.footReference;invalid.z=std::numeric_limits<double>::infinity();
  assert(prepareLegPlan(g,invalid,c,plan).status==PlanStatus::InvalidRequest);unchanged(plan);
  assert(prepareLegPlan(g,nominal.footReference,c,plan,{},2).status==PlanStatus::InvalidBranch);unchanged(plan);
  LegPose outside;forwardKinematics(g,31,44,79,outside);
  assert(prepareLegPlan(g,outside.footReference,c,plan).status==PlanStatus::OutsideBounds);unchanged(plan);
  JointBounds wide{{-180,-180,-180},{180,180,180}};
  for(auto& joint:c.joints)joint={true,-180,180,1470,1530,-180,180,1450,1550};
  result=prepareLegPlan(g,nominal.footReference,c,plan,wide);
  assert(result.status==PlanStatus::BranchChoiceRequired && result.branchCount==4);unchanged(plan);
  result=prepareLegPlan(g,nominal.footReference,c,plan,wide,2);
  assert(result.status==PlanStatus::Ok && plan.branch==2);
  plan=sentinel();forwardKinematics(g,0,0,0,outside);
  assert(prepareLegPlan(g,outside.footReference,c,plan,wide).status==PlanStatus::BranchChoiceRequired);unchanged(plan);
  result=prepareLegPlan(g,outside.footReference,c,plan,wide,0);
  assert(result.status==PlanStatus::Ok && plan.singular);
  plan=sentinel();g.pitchFloorYmm=-50;
  assert(prepareLegPlan(g,{240,0,0},c,plan,wide,0).status==PlanStatus::BranchChoiceRequired);unchanged(plan);
  puts("PASS: complete/partial calibration, atomic failure, pulse ceiling, target errors and explicit branch/singular policy");
}
