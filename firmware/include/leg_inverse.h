#pragma once
#include <float.h>
#include <stdint.h>
#include "leg_geometry.h"
namespace bench {
struct JointAngles { double q1=0,q2=0,q3=0; };
struct JointBounds {
  JointAngles minimum{-25,20,60},maximum{30,55,90}; // unpowered geometric envelope only
};
enum class InverseStatus { Unique, Ambiguous, Unreachable, OutsideBounds,
  Singular, InvalidGeometry, InvalidTarget, InvalidBounds };
struct InverseResult {
  InverseStatus status=InverseStatus::Unreachable;
  uint8_t count=0;
  bool singular=false;
  JointAngles solutions[4]{};
};
inline double normalizedAngle(double angle) {
  double r=fmod(angle+180,360);if(r<0)r+=360;return r-180;
}
inline bool fitAngle(double angle,double minimum,double maximum,double& output) {
  for(double value:{angle-360,angle,angle+360}) {
    if(value>=minimum-1e-8 && value<=maximum+1e-8) {
      output=value<minimum?minimum:value>maximum?maximum:value;return true;
    }
  }
  return false;
}
inline InverseResult inverseKinematics(const LegGeometry& g,const Point3& target,
                                      const JointBounds& bounds={}) {
  InverseResult result;
  LegPose check;
  if(!forwardKinematics(g,0,0,0,check)) {result.status=InverseStatus::InvalidGeometry;return result;}
  for(double value:{target.x,target.y,target.z})if(!isfinite(value)) {
    result.status=InverseStatus::InvalidTarget;return result;
  }
  const double lo[]={bounds.minimum.q1,bounds.minimum.q2,bounds.minimum.q3};
  const double hi[]={bounds.maximum.q1,bounds.maximum.q2,bounds.maximum.q3};
  for(unsigned i=0;i<3;++i)if(!isfinite(lo[i])||!isfinite(hi[i])||lo[i]>hi[i]||lo[i]<-180||hi[i]>180) {
    result.status=InverseStatus::InvalidBounds;return result;
  }
  const double d=g.pitchFloorYmm+g.referenceAxialMm;
  const double radius=hypot(target.y,target.z),delta=radius*radius-d*d;
  if(!isfinite(delta))return result;
  const double tolerance=32*DBL_EPSILON*fmax(1,fmax(radius*radius,d*d));
  if(delta < -tolerance)return result;
  if(radius==0 && d==0){result.status=InverseStatus::Singular;result.singular=true;return result;}
  const double height=sqrt(fmax(0,delta));
  constexpr double deg=180/3.14159265358979323846;
  bool geometricallyReachable=false;
  for(double vertical:{-height,height}) {
    const double q1=normalizedAngle((atan2(target.z,target.y)-atan2(vertical,d))*deg);
    const double p=g.pitchVerticalMm-vertical,w=target.x-g.pitchForwardMm;
    double cosine=(p*p+w*w-g.upperMm*g.upperMm-g.lowerMm*g.lowerMm)/(2*g.upperMm*g.lowerMm);
    if(!isfinite(cosine)||cosine<-1-64*DBL_EPSILON||cosine>1+64*DBL_EPSILON)continue;
    geometricallyReachable=true;
    cosine=fmax(-1,fmin(1,cosine)); // machine-roundoff guard, not target projection
    for(double knee:{acos(cosine),-acos(cosine)}) {
      const double q2=normalizedAngle((atan2(w,p)+atan2(g.lowerMm*sin(knee),g.upperMm+g.lowerMm*cos(knee)))*deg);
      const double q3=normalizedAngle(knee*deg);
      JointAngles candidate;
      if(!fitAngle(q1,lo[0],hi[0],candidate.q1)||!fitAngle(q2,lo[1],hi[1],candidate.q2)||
         !fitAngle(q3,lo[2],hi[2],candidate.q3))continue;
      if(!forwardKinematics(g,candidate.q1,candidate.q2,candidate.q3,check))continue;
      if(hypot(hypot(check.footReference.x-target.x,check.footReference.y-target.y),
               check.footReference.z-target.z)>1e-7)continue;
      bool duplicate=false;
      for(unsigned i=0;i<result.count;++i) {
        const auto& old=result.solutions[i];
        if(fabs(normalizedAngle(old.q1-candidate.q1))<1e-7 &&
           fabs(normalizedAngle(old.q2-candidate.q2))<1e-7 &&
           fabs(normalizedAngle(old.q3-candidate.q3))<1e-7)duplicate=true;
      }
      if(!duplicate && result.count<4) {
        result.solutions[result.count++]=candidate;
        if(height<1e-9 || fabs(sin(knee))<1e-8)result.singular=true;
      }
    }
  }
  result.status=result.count==1?InverseStatus::Unique:result.count>1?InverseStatus::Ambiguous:
    geometricallyReachable?InverseStatus::OutsideBounds:InverseStatus::Unreachable;
  return result;
}
}
