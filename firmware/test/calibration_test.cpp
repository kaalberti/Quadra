#include <assert.h>
#include <stdio.h>
#include <limits>
#include "joint_calibration.h"
using namespace bench;
int main() {
  uint16_t output=42;JointCalibration c;
  assert(angleToPulse(c,0,output)==MappingResult::Unmeasured && output==42);
  c={true,-30,60,1000,1900,-20,50,900,2000}; // SYNTHETIC, not a physical profile
  assert(angleToPulse(c,0,output)==MappingResult::Ok && output==1300);
  assert(angleToPulse(c,-20,output)==MappingResult::Ok && output==1100);
  assert(angleToPulse(c,50,output)==MappingResult::Ok && output==1800);
  assert(angleToPulse(c,51,output)==MappingResult::OutsideLimits && output==1800);
  assert(angleToPulse(c,-30,output)==MappingResult::OutsideLimits);
  c.pulseA=1900;c.pulseB=1000;
  assert(angleToPulse(c,0,output)==MappingResult::Ok && output==1600);
  assert(angleToPulse(c,0.04f,output)==MappingResult::Ok && output==1600);
  assert(angleToPulse(c,0.06f,output)==MappingResult::Ok && output==1599);
  assert(angleToPulse(c,std::numeric_limits<float>::quiet_NaN(),output)==MappingResult::InvalidAngle);
  assert(angleToPulse(c,std::numeric_limits<float>::infinity(),output)==MappingResult::InvalidAngle);
  c.angleB=c.angleA;assert(angleToPulse(c,0,output)==MappingResult::InvalidProfile);
  c.angleB=60;c.maximumAngle=70;assert(angleToPulse(c,0,output)==MappingResult::InvalidProfile);
  c.maximumAngle=50;c.minimumPulse=1950;assert(angleToPulse(c,0,output)==MappingResult::InvalidProfile);
  c.minimumPulse=900;c.pulseA=c.pulseB;assert(angleToPulse(c,0,output)==MappingResult::InvalidProfile);
  c.pulseA=1900;c.maximumPulse=2600;assert(angleToPulse(c,0,output)==MappingResult::InvalidProfile);
  puts("PASS: calibration direction, interpolation, limits, missing/invalid profiles and nonfinite inputs");
}
