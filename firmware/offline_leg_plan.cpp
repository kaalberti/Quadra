#include <cstdio>
#include <cstdlib>
#include <cerrno>
#include "leg_plan.h"
#include "offline-profile.h"
const char* statusName(bench::PlanStatus s) {
  switch(s) {
    case bench::PlanStatus::Ok:return "Ok";
    case bench::PlanStatus::CalibrationRequired:return "CalibrationRequired";
    case bench::PlanStatus::CalibrationInvalid:return "CalibrationInvalid";
    case bench::PlanStatus::InvalidRequest:return "InvalidRequest";
    case bench::PlanStatus::Unreachable:return "Unreachable";
    case bench::PlanStatus::OutsideBounds:return "OutsideBounds";
    case bench::PlanStatus::BranchChoiceRequired:return "BranchChoiceRequired";
    case bench::PlanStatus::InvalidBranch:return "InvalidBranch";
    case bench::PlanStatus::AngleOutsideCalibration:return "AngleOutsideCalibration";
    case bench::PlanStatus::PulseOutsideBench:return "PulseOutsideBench";
  }
  return "InvalidRequest";
}
int main(int argc,char** argv) {
  if(argc!=5){std::puts("{\"ok\":false,\"status\":\"InvalidRequest\"}");return 2;}
  double target[3];
  for(int i=0;i<3;i++) {char* end=nullptr;errno=0;target[i]=std::strtod(argv[i+1],&end);
    if(errno || end==argv[i+1] || *end || !isfinite(target[i])){std::puts("{\"ok\":false,\"status\":\"InvalidRequest\"}");return 2;}}
  char* end=nullptr;errno=0;const long branch=std::strtol(argv[4],&end,10);
  if(errno || end==argv[4] || *end || branch < -1 || branch > 3){std::puts("{\"ok\":false,\"status\":\"InvalidBranch\"}");return 2;}
  bench::LegCalibration calibration;
  for(unsigned i=0;i<3;i++)calibration.joints[i]=offline_calibration::joints[i];
  bench::LegPlan plan;
  const auto result=bench::prepareLegPlan({}, {target[0],target[1],target[2]},calibration,plan,{},int(branch));
  if(result.status!=bench::PlanStatus::Ok){std::printf("{\"ok\":false,\"status\":\"%s\",\"failed_joint\":%d,\"branch_count\":%u}\n",statusName(result.status),result.failedJoint,unsigned(result.branchCount));return 2;}
  std::printf("{\"ok\":true,\"offline_only\":true,\"angles_deg\":[%.12g,%.12g,%.12g],\"pulses_us\":[%u,%u,%u],\"branch\":%u,\"singular\":%s}\n",plan.angles.q1,plan.angles.q2,plan.angles.q3,unsigned(plan.pulses[0]),unsigned(plan.pulses[1]),unsigned(plan.pulses[2]),unsigned(plan.branch),plan.singular?"true":"false");
  return 0;
}
