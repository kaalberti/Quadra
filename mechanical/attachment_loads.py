"""Bounded analytical attachment scenario; never an actual inventory."""
import itertools
import json
from pathlib import Path
from mass_accounting import BASE, ANGLES, correction, position, G
from check_leg_frames import skeleton, cross, dot, subtract

HERE = Path(__file__).resolve().parent
MASSES = {'HS-5085MG': .0219, 'XL330-M288-T': .018, 'XC330-M288-T': .023}
# Generous assumed axis-relative COM boxes, mm; not inferred shaft drawings.
HALF = (34., 26., 34.)

def rows(model, offsets=(0., 0., 0.)):
    result = []
    for name, leg in BASE['legs'].items():
        points, _, _ = skeleton(leg['front'], leg['side'], ANGLES, BASE['parameters'])
        for joint, attachment, centre in ((1, 'body', points[0]),
                (2, 'hip_carrier', (0, leg['side']*25, 0)),
                (3, 'upper', (0, 0, -70))):
            result.append(dict(id=f'{name}-q{joint}', leg=name, attachment=attachment,
                mass_kg=MASSES[model], com_local_mm=[a+b for a,b in zip(centre, offsets)]))
    return result

def gravity_bounds(model, angles=ANGLES):
    corners = list(itertools.product(*[(-h, h) for h in HALF]))
    bounds = {}
    for name in BASE['legs']:
        limits = [[0., 0.] for _ in range(3)]
        for row in rows(model):
            if row['leg'] != name: continue
            vals = []
            for offset in corners:
                variant = dict(row, com_local_mm=[a+b for a,b in zip(row['com_local_mm'], offset)])
                vals.append(correction(variant, name, angles))
            for j in range(3):
                limits[j][0] += min(v[j] for v in vals)
                limits[j][1] += max(v[j] for v in vals)
        bounds[name] = limits
    return bounds

def report():
    return {'task':'TOR-010', 'assumed_COM_half_box_mm':HALF,
        'warning':'Axis-relative COM bounds are engineering assumptions, not product mounting data.',
        'candidates':{m:{'twelve_actuator_mass_kg':12*mass,
          'FL_nominal_gravity_Nm':[sum(correction(r,'FL')[j] for r in rows(m)) for j in range(3)],
          'gravity_bounds_Nm':gravity_bounds(m)} for m,mass in MASSES.items()}}

if __name__ == '__main__':
    (HERE/'attachment-loads.json').write_text(json.dumps(report(), indent=2)+'\n')
