#pragma once
#include <math.h>
#include <initializer_list>
namespace bench {
struct Point3 { double x=0,y=0,z=0; };
struct LegGeometry {
  double upperMm=70,lowerMm=85,pitchForwardMm=85,pitchFloorYmm=-18;
  double pitchVerticalMm=0,referenceAxialMm=50,padCenterAxialMm=51;
};
struct LegPose { Point3 knee,footReference,padCenter; };
inline bool forwardKinematics(const LegGeometry& g,double q1Deg,double q2Deg,double q3Deg,LegPose& output) {
  const double values[]={g.upperMm,g.lowerMm,g.pitchForwardMm,g.pitchFloorYmm,
    g.pitchVerticalMm,g.referenceAxialMm,g.padCenterAxialMm,q1Deg,q2Deg,q3Deg};
  for(double value:values)if(!isfinite(value))return false;
  if(g.upperMm<=0 || g.lowerMm<=0)return false;
  constexpr double rad=3.14159265358979323846/180;
  const double a=q1Deg*rad,b=q2Deg*rad,c=(q2Deg-q3Deg)*rad;
  const double s=sin(a),co=cos(a);
  auto world=[&](double localX,double localY,double axial){
    const double y=g.pitchFloorYmm+axial,z=g.pitchVerticalMm+localX;
    return Point3{g.pitchForwardMm-localY,y*co-z*s,y*s+z*co};
  };
  const double ux=-g.upperMm*cos(b),uy=-g.upperMm*sin(b);
  const double fx=ux-g.lowerMm*cos(c),fy=uy-g.lowerMm*sin(c);
  LegPose result{world(ux,uy,g.referenceAxialMm),world(fx,fy,g.referenceAxialMm),
    world(fx,fy,g.padCenterAxialMm)};
  for(const auto& point:{result.knee,result.footReference,result.padCenter})
    if(!isfinite(point.x)||!isfinite(point.y)||!isfinite(point.z))return false;
  output=result;return true;
}
}
