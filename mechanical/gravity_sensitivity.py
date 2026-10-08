"""TOR-008 nominal gravity coefficients; reference COMs are not placements."""
import json
import argparse
from mass_accounting import BASE, DIRECTORY, correction


def coefficient(attachment, com, leg='FL'):
    return correction({'attachment': attachment, 'com_local_mm': list(com),
                       'mass_kg': 1.0, 'leg': leg}, leg)


def build_report():
    p = BASE['parameters']
    references = [
        ('carrier_at_H', 'hip_carrier', [p['forward'], p['outward'], p['vertical']]),
        ('upper_at_H', 'upper', [0, 0, 0]),
        ('upper_midpoint', 'upper', [0, 0, -p['upper']/2]),
        ('upper_at_K', 'upper', [0, 0, -p['upper']]),
        ('lower_at_K', 'lower', [0, 0, 0]),
        ('lower_midpoint', 'lower', [0, 0, -p['lower']/2]),
        ('lower_at_P', 'lower', [0, 0, -p['lower']])]
    rows = []
    for name, attachment, com in references:
        base = coefficient(attachment, com)
        gradients = []
        for axis in range(3):
            shifted = list(com)
            shifted[axis] += 1
            gradients.append([v-b for v, b in zip(coefficient(attachment, shifted), base)])
        rows.append({'id': name, 'attachment': attachment, 'com_local_mm_FL': com,
                     'gravity_hold_nm_per_kg': base,
                     'gradient_nm_per_kg_mm_columns_xyz': gradients})
    return {'decision': 'TOR-008', 'scope': 'nominal gravity only; fixed contact reactions',
            'joint_order': ['q1', 'q2', 'q3'],
            'reference_leg': 'FL', 'references': rows}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    output = json.dumps(build_report(), indent=2)+'\n'
    if args.write:
        (DIRECTORY/'gravity-sensitivity.json').write_text(output)
    print(output)
