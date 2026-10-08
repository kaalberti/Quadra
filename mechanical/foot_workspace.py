"""KIN-005 ideal workspace analysis; --write regenerates JSON and SVG artifacts."""

import argparse
import hashlib
import itertools
import json
import math
from pathlib import Path


DIRECTORY = Path(__file__).resolve().parent
SOURCE_NAMES = ('leg-skeleton.json', 'joint-ranges.json', 'standing-pose.json')
BASE, RANGES, POSE = [json.loads((DIRECTORY / name).read_text(encoding='utf-8'))
                      for name in SOURCE_NAMES]
PARAMETERS = BASE['parameters']
BOUNDS = tuple((joint['lower'], joint['upper']) for joint in RANGES['joints'])
AXES = ('x', 'y', 'z')
BIN_MM = 2
PLOT_SCALE = 1.2
PLOT_RANGES = {'x': (-150, 160), 'y': (-60, 120), 'z': (-170, 60)}
PANELS = (('xz', 60), ('yz', 525), ('xy', 960))


def validate_model():
    if any(PARAMETERS[name] != 0 for name in ('forward', 'vertical', 'height')):
        raise ValueError('This analysis assumes KIN-002 u = w = h = 0.')
    if not (-90 < BOUNDS[0][0] < BOUNDS[0][1] < 90):
        raise ValueError('Abduction range must have positive cosine throughout.')


def foot_local(angles):
    abduction, hip, knee = map(math.radians, angles)
    forward = PARAMETERS['upper'] * math.sin(hip) + PARAMETERS['lower'] * math.sin(hip - knee)
    vertical = -PARAMETERS['upper'] * math.cos(hip) - PARAMETERS['lower'] * math.cos(hip - knee)
    offset = PARAMETERS['outward']
    return (forward, offset * math.cos(abduction) - vertical * math.sin(abduction),
            offset * math.sin(abduction) + vertical * math.cos(abduction))


def stationary_angles(sine_coefficient, cosine_coefficient, lower, upper):
    if sine_coefficient == cosine_coefficient == 0:
        return []
    phase = math.degrees(math.atan2(sine_coefficient, cosine_coefficient))
    first = math.ceil((lower - phase) / 180 - 1e-12)
    last = math.floor((upper - phase) / 180 + 1e-12)
    return [max(lower, min(upper, phase + 180 * index)) for index in range(first, last + 1)]


def planar_extrema(axis):
    upper, lower = PARAMETERS['upper'], PARAMETERS['lower']
    first_sine, first_cosine, second_sine, second_cosine = (
        (upper, 0, lower, 0) if axis == 'x' else (0, -upper, 0, -lower))
    hip_bounds, knee_bounds = BOUNDS[1], BOUNDS[2]
    candidates = set(itertools.product(hip_bounds, knee_bounds))
    for knee in knee_bounds:
        knee_rad = math.radians(knee)
        sine = first_sine + second_sine * math.cos(knee_rad) + second_cosine * math.sin(knee_rad)
        cosine = first_cosine - second_sine * math.sin(knee_rad) + second_cosine * math.cos(knee_rad)
        candidates.update((hip, knee) for hip in stationary_angles(sine, cosine, *hip_bounds))
    for hip in hip_bounds:
        candidates.update((hip, hip - relative) for relative in stationary_angles(
            second_sine, second_cosine, hip - knee_bounds[1], hip - knee_bounds[0]))
    for hip in stationary_angles(first_sine, first_cosine, *hip_bounds):
        candidates.update((hip, hip - relative) for relative in stationary_angles(
            second_sine, second_cosine, hip - knee_bounds[1], hip - knee_bounds[0]))
    records = []
    for hip, knee in sorted(candidates):
        hip_rad, relative = math.radians(hip), math.radians(hip - knee)
        value = (first_sine * math.sin(hip_rad) + first_cosine * math.cos(hip_rad)
                 + second_sine * math.sin(relative) + second_cosine * math.cos(relative))
        records.append({'value_mm': value, 'angles_degrees': [0, hip, knee]})
    return {'min': min(records, key=lambda record: record['value_mm']),
            'max': max(records, key=lambda record: record['value_mm'])}


def continuous_extrema():
    validate_model()
    result = {'x': planar_extrema('x')}
    vertical = planar_extrema('z')
    offset = PARAMETERS['outward']
    for axis in ('y', 'z'):
        records = []
        for endpoint in vertical.values():
            height = endpoint['value_mm']
            sine, cosine = (-height, offset) if axis == 'y' else (offset, height)
            candidates = list(BOUNDS[0]) + stationary_angles(sine, cosine, *BOUNDS[0])
            for abduction in candidates:
                radians = math.radians(abduction)
                records.append({'value_mm': sine * math.sin(radians) + cosine * math.cos(radians),
                                'angles_degrees': [abduction, *endpoint['angles_degrees'][1:]]})
        result[axis] = {'min': min(records, key=lambda record: record['value_mm']),
                        'max': max(records, key=lambda record: record['value_mm'])}
    return result


def angle_grid(lower, upper, step):
    count = int(math.floor((upper - lower) / step))
    values = [lower + index * step for index in range(count + 1)]
    if values[-1] < upper:
        values.append(upper)
    return values


def sample_workspace(step):
    bins = {plane: set() for plane, _ in PANELS}
    minimum, maximum = [math.inf] * 3, [-math.inf] * 3
    count = 0
    for angles in itertools.product(*(angle_grid(*bounds, step) for bounds in BOUNDS)):
        point = foot_local(angles)
        count += 1
        for index, value in enumerate(point):
            minimum[index] = min(minimum[index], value)
            maximum[index] = max(maximum[index], value)
        for plane in bins:
            bins[plane].add(tuple(math.floor(point[AXES.index(axis)] / BIN_MM) for axis in plane))
    return {'step_degrees': step, 'point_count': count,
            'bounds_mm': dict(zip(AXES, zip(minimum, maximum))),
            'projection_bin_mm': BIN_MM,
            'occupied_projection_cells': {plane: len(cells) for plane, cells in bins.items()}}, bins


def build_report():
    extremes = continuous_extrema()
    sampling, bins = sample_workspace(2)
    local = {axis: [extremes[axis][boundary]['value_mm'] for boundary in ('min', 'max')]
             for axis in AXES}
    body = {}
    for name, leg in BASE['legs'].items():
        body[name] = {
            'x': [leg['front'] * PARAMETERS['half_length'] + value for value in local['x']],
            'y': sorted(leg['side'] * (PARAMETERS['half_width'] + value) for value in local['y']),
            'z': local['z']}
    return {'decision': 'KIN-005', 'units': 'mm',
            'scope': 'unfiltered ideal geometric reach; no physical feasibility approval',
            'source_sha256': {name: hashlib.sha256((DIRECTORY / name).read_bytes()).hexdigest()
                              for name in SOURCE_NAMES},
            'reference_frame': 'FL root O; axes parallel to body; x forward, y left, z up',
            'continuous_extrema': extremes, 'local_enclosing_box_mm': local,
            'body_enclosing_boxes_mm': body,
            'nominal_local_mm': list(foot_local(POSE['joint_angles_degrees_all_legs'])),
            'nominal_ground_z_local_mm': POSE['ground_z_body'],
            'sampling': sampling}, bins


def projection(plane, left, values):
    return (left + (values[0] - PLOT_RANGES[plane[0]][0]) * PLOT_SCALE,
            140 + (PLOT_RANGES[plane[1]][1] - values[1]) * PLOT_SCALE)


def render_svg(report, bins):
    parts = ['<svg xmlns="http://www.w3.org/2000/svg" width="1420" height="650" viewBox="0 0 1420 650">',
             '<title>KIN-005 unfiltered foot workspace projections</title>',
             '<rect width="1420" height="650" fill="white"/>',
             '<style>text{font:15px Arial,sans-serif;fill:#172033}.title{font-size:24px;font-weight:bold}'
             '.grid{stroke:#e2e8f0;stroke-width:1}.box{fill:none;stroke:#be123c;stroke-dasharray:5 4}'
             '.ground{stroke:#475569;stroke-dasharray:8 4}.nominal{fill:#f59e0b;stroke:#172033;stroke-width:2}</style>',
             '<text x="35" y="38" class="title">KIN-005 | Unfiltered ideal foot workspace</text>',
             '<text x="35" y="67">FL root coordinates, mm. Projections of the whole set, NOT slices or approved operating regions.</text>',
             '<text x="35" y="94">Blue: occupied 2 mm cells from a 2 deg grid. Red: continuous enclosing box. Gold: nominal foot.</text>']
    for plane, left in PANELS:
        horizontal, vertical = plane
        parts.append(f'<g id="projection-{plane}"><text x="{left}" y="125">{plane.upper()} projection</text>')
        width = (PLOT_RANGES[horizontal][1] - PLOT_RANGES[horizontal][0]) * PLOT_SCALE
        height = (PLOT_RANGES[vertical][1] - PLOT_RANGES[vertical][0]) * PLOT_SCALE
        parts.append(f'<rect x="{left}" y="140" width="{width}" height="{height}" fill="#f8fafc"/>')
        for value in range(math.ceil(PLOT_RANGES[horizontal][0] / 50) * 50, PLOT_RANGES[horizontal][1] + 1, 50):
            screen = projection(plane, left, (value, 0))[0]
            parts.append(f'<line class="grid" x1="{screen}" y1="140" x2="{screen}" y2="{140 + height}"/>'
                         f'<text x="{screen - 12}" y="{162 + height}">{value}</text>')
        for value in range(math.ceil(PLOT_RANGES[vertical][0] / 50) * 50, PLOT_RANGES[vertical][1] + 1, 50):
            screen = projection(plane, left, (0, value))[1]
            parts.append(f'<line class="grid" x1="{left}" y1="{screen}" x2="{left + width}" y2="{screen}"/>'
                         f'<text x="{left - 43}" y="{screen + 5}">{value}</text>')
        path = []
        for column, row in sorted(bins[plane]):
            screen_x, screen_y = projection(plane, left, (column * BIN_MM, (row + 1) * BIN_MM))
            size = BIN_MM * PLOT_SCALE
            path.append(f'M{screen_x:.3f},{screen_y:.3f}h{size}v{size}h-{size}z')
        parts.append(f'<path id="cells-{plane}" d="{" ".join(path)}" fill="#38bdf8" fill-opacity="0.65"/>')
        box = report['local_enclosing_box_mm']
        screen_x, screen_y = projection(plane, left, (box[horizontal][0], box[vertical][1]))
        parts.append(f'<rect id="bounds-{plane}" class="box" x="{screen_x:.6f}" y="{screen_y:.6f}" '
                     f'width="{(box[horizontal][1] - box[horizontal][0]) * PLOT_SCALE:.6f}" '
                     f'height="{(box[vertical][1] - box[vertical][0]) * PLOT_SCALE:.6f}"/>')
        if vertical == 'z':
            ground = projection(plane, left, (0, report['nominal_ground_z_local_mm']))[1]
            parts.append(f'<line id="ground-{plane}" class="ground" x1="{left}" y1="{ground}" '
                         f'x2="{left + width}" y2="{ground}"/>')
        nominal = report['nominal_local_mm']
        screen_x, screen_y = projection(plane, left, tuple(nominal[AXES.index(axis)] for axis in plane))
        parts.append(f'<circle id="nominal-{plane}" class="nominal" cx="{screen_x:.6f}" cy="{screen_y:.6f}" r="5"/>'
                     f'<text x="{left + width / 2 - 15}" y="{190 + height}">+{horizontal} (mm)</text>'
                     f'<text x="{left - 35}" y="133">+{vertical}</text></g>')
    parts.extend(['<text x="35" y="510">Nominal FL foot relative to O: (0, 25, -120) mm. Dashed grey: nominal ground z = -120 mm.</text>',
                  '<text x="35" y="539">Grid cells indicate sample occupancy only; filled cells and projected overlaps are not reachability proofs.</text>',
                  '<text x="35" y="568">Includes below-ground and above-hip points. No body/leg collision, joint-load, or actuator-travel filtering.</text>',
                  '<text x="35" y="597">Regenerate from mechanical/foot_workspace.py --write. Continuous extrema are recorded with witness angles in JSON.</text>',
                  '</svg>'])
    return '\n'.join(parts) + '\n'


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true', help='Regenerate workspace JSON and SVG')
    options = parser.parse_args()
    report, cells = build_report()
    if options.write:
        (DIRECTORY / 'foot-workspace.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
        (DIRECTORY / 'foot-workspace.svg').write_text(render_svg(report, cells), encoding='utf-8')
    print(json.dumps(report, indent=2))
