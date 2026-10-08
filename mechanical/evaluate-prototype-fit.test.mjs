import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {evaluate} from './evaluate-prototype-fit.mjs';
const template=JSON.parse(fs.readFileSync(new URL('./prototype-fit-record.json',import.meta.url),'utf8'));
function measured() {
  const r=structuredClone(template);
  Object.assign(r,{measured_by:'TEST FIXTURE',measured_on:'2026-10-08',servo_model:'synthetic',bearing_model:'synthetic',print_material:'PETG'});
  Object.assign(r.measurements,{case_length:40.7,case_width:19.7,mounted_shaft_x:-10.35,mounted_horn_face_z:50,selected_bearing_coupon_seat:13.2,assembled_leg_mass_g:400});
  for(const key of Object.keys(r.checks)) r.checks[key]=true;
  return r;
}
test('untouched real record remains unmeasured',()=>assert.equal(evaluate(template).status,'NOT_MEASURED'));
test('complete synthetic fit evidence never approves powered operation',()=>{
  const result=evaluate(measured());assert.equal(result.status,'READY_FOR_UNPOWERED_ASSEMBLY');assert.equal(result.powered_operation_approved,false);
});
test('binding fails even when the rest is complete',()=>{
  const r=measured();r.checks.all_joints_move_gently_without_binding=false;assert.equal(evaluate(r).status,'FIT_FAILED');
});
test('different coupon seat requires a CAD revision',()=>{
  const r=measured();r.measurements.selected_bearing_coupon_seat=13.4;assert.equal(evaluate(r).status,'CAD_REVIEW_REQUIRED');
});
test('oversized case fails instead of relying on optimistic observation',()=>{
  const r=measured();r.measurements.case_width=22;assert.equal(evaluate(r).status,'FIT_FAILED');
});
test('string booleans, missing observations and invalid dates cannot pass',()=>{
  const r=measured();r.checks.lead_exit_clear='true';assert.equal(evaluate(r).status,'INVALID_RECORD');
  r.checks.lead_exit_clear=null;assert.equal(evaluate(r).status,'NOT_MEASURED');
  r.measured_on='2026-02-30';assert.equal(evaluate(r).status,'INVALID_RECORD');
});
