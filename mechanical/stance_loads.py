"""Conservative vertical static screening; explicit synthetic mass scenario."""
import itertools
import json
import math
from pathlib import Path
from attachment_loads import MASSES, rows, HALF
from mass_accounting import BASE, ANGLES, correction, G, DEPTH
from check_leg_frames import skeleton, apply, add, subtract, cross, dot

HERE = Path(__file__).resolve().parent

def components(model):
    result = [(r, HALF) for r in rows(model)]
    for name in BASE['legs']:
        # 40 g printed leg target; all per-actuator accessory allowance placed
        # distally on upper for screening. Not a physical bill of materials.
        for attach, mass, centre, half in (
            ('upper', .020 + 3*(.030-MASSES[model]), (0,0,-35), (10,10,35)),
            ('lower', .020, (0,0,-42.5), (10,10,42.5))):
            result.append((dict(leg=name, attachment=attach, mass_kg=mass,
                com_local_mm=centre), half))
    assigned = sum(r['mass_kg'] for r,h in result)
    # All remaining categories + reserve/ceiling gap are body-fixed. Deliberately
    # use 1.2 kg limit, not a claim actual operating mass meets strict inequality.
    result.append((dict(leg=None, attachment='body', mass_kg=1.2-assigned,
        com_local_mm=(0,0,0)), (20,20,20)))
    return result

def com_position(row, angles):
    if row['attachment']=='body': return row['com_local_mm']
    leg=BASE['legs'][row['leg']]
    points,frames,_=skeleton(leg['front'],leg['side'],angles,BASE['parameters'])
    index=DEPTH[row['attachment']]-1
    return add(points[index],apply(frames[index],row['com_local_mm']))

def vertices(row, half):
    for off in itertools.product(*[(-h,h) for h in half]):
        yield dict(row,com_local_mm=[a+b for a,b in zip(row['com_local_mm'],off)])

def screen(model, angles=ANGLES):
    cs=components(model)
    mass=sum(r['mass_kg'] for r,h in cs)
    com=[[0.,0.] for _ in range(3)]
    gravity={n:[[0.,0.] for _ in range(3)] for n in BASE['legs']}
    for r,h in cs:
        vs=list(vertices(r,h))
        ps=[com_position(v,angles) for v in vs]
        for k in range(3):
            com[k][0]+=r['mass_kg']*min(p[k] for p in ps)/mass
            com[k][1]+=r['mass_kg']*max(p[k] for p in ps)/mass
        for name in BASE['legs']:
            ts=[correction(v,name,angles) for v in vs]
            for j in range(3):
                gravity[name][j][0]+=min(t[j] for t in ts)
                gravity[name][j][1]+=max(t[j] for t in ts)
    feet={n:skeleton(l['front'],l['side'],angles,BASE['parameters'])[0][3]
          for n,l in BASE['legs'].items()}
    xs=[p[0] for p in feet.values()]; ys=[p[1] for p in feet.values()]
    xmin,xmax=min(xs),max(xs); ymin,ymax=min(ys),max(ys)
    if not (xmin<=com[0][0]<=com[0][1]<=xmax and ymin<=com[1][0]<=com[1][1]<=ymax):
        raise ValueError('COM box exceeds support rectangle')
    answer={}
    for name,l in BASE['legs'].items():
        ax=[(x-xmin)/(xmax-xmin) for x in com[0]]
        ay=[(y-ymin)/(ymax-ymin) for y in com[1]]
        if l['front']<0: ax=[1-ax[1],1-ax[0]]
        if l['side']<0: ay=[1-ay[1],1-ay[0]]
        shares=[max(0.,ax[0]+ay[0]-1),min(ax[1],ay[1])]
        points,_,axes=skeleton(l['front'],l['side'],angles,BASE['parameters'])
        torques=[]
        for j in range(3):
            coefficient=-dot(axes[j],cross(subtract(points[3],points[j]),(0,0,mass*G)))/1000
            vals=[coefficient*s for s in shares]
            torques.append([min(vals)+gravity[name][j][0],max(vals)+gravity[name][j][1]])
        answer[name]={'contact_share':shares,'signed_torque_Nm':torques,
            'absolute_upper_Nm':[max(abs(t) for t in interval) for interval in torques]}
    return {'mass_ceiling_kg':mass,'COM_bounds_mm':com,'legs':answer}

if __name__=='__main__':
    (HERE/'nominal-loads.json').write_text(json.dumps({m:screen(m) for m in MASSES},indent=2)+'\n')
