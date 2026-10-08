"""1 mm sampled common-foot-offset stance domain; no gait or dynamic claim."""
import json
import math
from attachment_loads import MASSES
from stance_loads import screen, HERE
from mass_accounting import BASE
from check_leg_frames import skeleton

def pose(x, height):
    upper,lower=70.,85.
    knee=math.acos((x*x+height*height-upper*upper-lower*lower)/(2*upper*lower))
    hip=math.atan2(x,height)+math.atan2(lower*math.sin(knee),upper+lower*math.cos(knee))
    return (0.,hip,knee)

def report():
    result={m:{'max_absolute_upper_Nm':[0.,0.,0.],'max_locations':[None]*3} for m in MASSES}
    angle_bounds=[[float('inf'),-float('inf')] for _ in range(3)]
    count=0
    for x in range(-10,11):
        for h in range(110,131):
            angles=pose(x,h)
            for j,a in enumerate(angles):
                angle_bounds[j][0]=min(angle_bounds[j][0],math.degrees(a))
                angle_bounds[j][1]=max(angle_bounds[j][1],math.degrees(a))
            for name,leg in BASE['legs'].items():
                foot=skeleton(leg['front'],leg['side'],angles,BASE['parameters'])[0][3]
                assert abs(foot[0]-(leg['front']*75+x))<1e-9
                assert abs(foot[1]-leg['side']*80)<1e-9
                assert abs(foot[2]+h)<1e-9
            for m in MASSES:
                r=screen(m,angles)
                for name,leg in r['legs'].items():
                    for j,v in enumerate(leg['absolute_upper_Nm']):
                        if v>result[m]['max_absolute_upper_Nm'][j]:
                            result[m]['max_absolute_upper_Nm'][j]=v
                            result[m]['max_locations'][j]={'foot_offset_mm':x,'height_mm':h,'leg':name}
            count+=1
    return {'task':'TOR-012','grid_points':count,'grid_spacing_mm':1,
        'warning':'Sampled maxima only. No continuous-domain bound, gait, friction or dynamic margin.',
        'angle_bounds_degrees':angle_bounds,'candidates':result}

if __name__=='__main__':
    (HERE/'stance-envelope.json').write_text(json.dumps(report(),indent=2)+'\n')
