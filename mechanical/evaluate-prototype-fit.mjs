import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';

const requiredChecks = [
  'cradle_clamps_without_case_damage', 'lead_exit_clear',
  'supplied_horn_and_original_centre_screw_used', 'horn_through_bolts_and_tips_clear',
  'bearing_retained_without_force_or_play', 'spacers_touch_inner_ring_only',
  'both_fork_arms_align_without_force', 'carrier_relief_and_mounts_fit',
  'bench_fixture_rigid_and_clear', 'all_joints_move_gently_without_binding',
  'cable_loop_clear_through_trial_motion',
];
const requiredNumbers = ['case_length','case_width','mounted_shaft_x',
  'mounted_horn_face_z','selected_bearing_coupon_seat','assembled_leg_mass_g'];

export function evaluate(record) {
  const missing = [], failures = [], revisions = [], invalid = [];
  if(record.revision !== 'three-dof-bench-1' || record.units !== 'mm') invalid.push('Wrong revision or units');
  for(const key of ['measured_by','measured_on','servo_model','bearing_model','print_material']) {
    if(record[key] == null || record[key] === '') missing.push(key);
    else if(typeof record[key] !== 'string') invalid.push(key);
  }
  if(record.measured_on && (!/^\d{4}-\d{2}-\d{2}$/.test(record.measured_on) ||
    !Number.isFinite(Date.parse(record.measured_on+'T00:00:00Z')) ||
    new Date(record.measured_on+'T00:00:00Z').toISOString().slice(0,10) !== record.measured_on)) invalid.push('measured_on');
  const m = record.measurements ?? {};
  for(const key of requiredNumbers) {
    if(m[key] == null) missing.push(key);
    else if(typeof m[key] !== 'number' || !Number.isFinite(m[key]) || (key !== 'mounted_shaft_x' && m[key] <= 0)) invalid.push(key);
  }
  for(const key of requiredChecks) {
    const value = record.checks?.[key];
    if(value == null) missing.push(key);
    else if(typeof value !== 'boolean') invalid.push(key);
    else if(!value) failures.push(key);
  }
  if(!invalid.length) {
    if(m.case_length > 41.5 || m.case_width > 20.5) failures.push('Case exceeds the nominal cradle pocket');
    if(m.mounted_shaft_x != null && Math.abs(m.mounted_shaft_x + 10.35) > 0.4) revisions.push('Mounted shaft x differs from CAD by more than0.4mm');
    if(m.mounted_horn_face_z != null && Math.abs(m.mounted_horn_face_z - 50) > 0.4) revisions.push('Horn-face height differs from CAD by more than0.4mm');
    if(m.selected_bearing_coupon_seat != null && m.selected_bearing_coupon_seat !== 13.2) revisions.push('Rear-arm seat is13.2mm; regenerate CAD/STL for the selected coupon fit');
  }
  const status = invalid.length ? 'INVALID_RECORD' : failures.length ? 'FIT_FAILED' :
    missing.length ? 'NOT_MEASURED' : revisions.length ? 'CAD_REVIEW_REQUIRED' : 'READY_FOR_UNPOWERED_ASSEMBLY';
  return {status, missing, failures, revisions, invalid,
    evidence: 'User-recorded measurements and observations; no automated physical inspection',
    powered_operation_approved: false};
}

if(process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const recordPath = process.argv[2] ?? path.join(path.dirname(fileURLToPath(import.meta.url)), 'prototype-fit-record.json');
  const result = evaluate(JSON.parse(fs.readFileSync(recordPath,'utf8').replace(/^\uFEFF/,'')));
  console.log(JSON.stringify(result,null,2));
  if(result.status === 'INVALID_RECORD' || result.status === 'FIT_FAILED') process.exitCode = 1;
}
