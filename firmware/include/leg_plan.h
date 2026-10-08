#pragma once
#include "bench_config.h"
#include "joint_calibration.h"
#include "leg_inverse.h"
namespace bench {
struct LegCalibration { JointCalibration joints[3]{}; };
struct LegPlan { JointAngles angles; uint16_t pulses[3]{}; uint8_t branch=0; bool singular=false; };
enum class PlanStatus { Ok, CalibrationRequired, CalibrationInvalid, InvalidRequest,
  Unreachable, OutsideBounds, BranchChoiceRequired, InvalidBranch,
  AngleOutsideCalibration, PulseOutsideBench };
struct PlanResult {
  PlanStatus status=PlanStatus::InvalidRequest;
  InverseStatus inverse=InverseStatus::InvalidTarget;
  MappingResult mapping=MappingResult::Unmeasured;
  int failedJoint=-1;
  uint8_t branchCount=0;
};
inline PlanResult prepareLegPlan(const LegGeometry& geometry,const Point3& target,
  const LegCalibration& calibration,LegPlan& output,const JointBounds& bounds={},int branch=-1) {
  PlanResult result;
  for(unsigned i=0;i<3;++i) {
    uint16_t ignored=0;
    const auto& c=calibration.joints[i];
    result.mapping=angleToPulse(c,c.minimumAngle,ignored);
    if(result.mapping!=MappingResult::Ok) {
      result.failedJoint=int(i);
      result.status=result.mapping==MappingResult::Unmeasured?PlanStatus::CalibrationRequired:PlanStatus::CalibrationInvalid;
      return result;
    }
  }
  const auto solved=inverseKinematics(geometry,target,bounds);
  result.inverse=solved.status;result.branchCount=solved.count;
  if(solved.count==0) {
    result.status=solved.status==InverseStatus::Unreachable?PlanStatus::Unreachable:
      solved.status==InverseStatus::OutsideBounds?PlanStatus::OutsideBounds:
      solved.status==InverseStatus::Singular?PlanStatus::BranchChoiceRequired:PlanStatus::InvalidRequest;
    return result;
  }
  if(branch<-1 || branch>=solved.count) { result.status=PlanStatus::InvalidBranch;return result; }
  if(branch==-1 && (solved.count>1 || solved.singular)) {
    result.status=PlanStatus::BranchChoiceRequired;return result;
  }
  const unsigned selected=branch==-1?0:unsigned(branch);
  LegPlan pending;pending.angles=solved.solutions[selected];pending.branch=uint8_t(selected);
  pending.singular=solved.singular;
  const double angles[]={pending.angles.q1,pending.angles.q2,pending.angles.q3};
  for(unsigned i=0;i<3;++i) {
    result.mapping=angleToPulse(calibration.joints[i],float(angles[i]),pending.pulses[i]);
    if(result.mapping!=MappingResult::Ok) {
      result.failedJoint=int(i);
      result.status=result.mapping==MappingResult::OutsideLimits?PlanStatus::AngleOutsideCalibration:PlanStatus::CalibrationInvalid;
      return result;
    }
    if(pending.pulses[i]<MinPulseUs || pending.pulses[i]>MaxPulseUs) {
      result.failedJoint=int(i);result.status=PlanStatus::PulseOutsideBench;return result;
    }
  }
  output=pending;result.status=PlanStatus::Ok;return result;
}
}
