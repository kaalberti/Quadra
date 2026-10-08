#pragma once
#include <math.h>
#include <stdint.h>
namespace bench {
struct JointCalibration {
  bool measured=false;
  float angleA=0,angleB=0;
  uint16_t pulseA=0,pulseB=0;
  float minimumAngle=0,maximumAngle=0;
  uint16_t minimumPulse=0,maximumPulse=0;
};
enum class MappingResult { Ok, Unmeasured, InvalidProfile, OutsideLimits, InvalidAngle };
inline MappingResult angleToPulse(const JointCalibration& c,float angle,uint16_t& output) {
  if(!c.measured)return MappingResult::Unmeasured;
  if(!isfinite(c.angleA)||!isfinite(c.angleB)||!isfinite(c.minimumAngle)||!isfinite(c.maximumAngle)||
     c.angleA>=c.angleB || c.minimumAngle>c.maximumAngle ||
     c.minimumAngle<c.angleA || c.maximumAngle>c.angleB ||
     c.minimumPulse<500 || c.maximumPulse>2500 || c.minimumPulse>=c.maximumPulse ||
     c.pulseA==c.pulseB || c.pulseA<c.minimumPulse || c.pulseA>c.maximumPulse ||
     c.pulseB<c.minimumPulse || c.pulseB>c.maximumPulse)return MappingResult::InvalidProfile;
  if(!isfinite(angle))return MappingResult::InvalidAngle;
  if(angle<c.minimumAngle || angle>c.maximumAngle)return MappingResult::OutsideLimits;
  const double pulse=c.pulseA+(double(angle)-c.angleA)*(int(c.pulseB)-int(c.pulseA))/(double(c.angleB)-c.angleA);
  if(!isfinite(pulse)||pulse<c.minimumPulse||pulse>c.maximumPulse)return MappingResult::InvalidProfile;
  output=uint16_t(lround(pulse));
  return MappingResult::Ok;
}
}
