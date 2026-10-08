import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {evaluate} from './evaluate-bench-commissioning.mjs';
const blank=()=>JSON.parse(fs.readFileSync(new URL('./bench-commissioning.json',import.meta.url)));
function synthetic() {
  const r=blank();
  Object.assign(r,{measured_by:'TEST ONLY',measured_on:'2026-10-08',servo_model:'synthetic',
    servo_voltage_source:'synthetic public data',controller_board:'synthetic',psu_model:'synthetic'});
  Object.assign(r.measurements,{servo_allowed_min_V:4.8,servo_allowed_max_V:6.6,psu_rated_current_A:3,
    initial_current_limit_A:0.5,servo_rail_unloaded_V:5.2,logic_V:3.3,OE_disabled_V:3,
    OE_enabled_V:0.6,cutoff_servo_rail_V:0});
  for(const key of Object.keys(r.checks))r.checks[key]=true;
  r.trial.performed=false;
  return r;
}
test('real blank record stays unmeasured',()=>{
  const result=evaluate(blank());assert.equal(result.status,'NOT_MEASURED');
  assert.equal(result.assembled_leg_approved,false);
});
test('synthetic setup permits only horn-off single trial',()=>{
  const result=evaluate(synthetic());assert.equal(result.status,'READY_FOR_ONE_UNMOUNTED_SERVO_TRIAL');
  assert.equal(result.three_servo_supply_approved,false);assert(result.notes.length);
});
test('synthetic completed trial remains no assembled-leg approval',()=>{
  const r=synthetic();Object.assign(r.trial,{performed:true,observed_min_servo_rail_V:5.1,
    observed_current_A:0.2,PSU_did_not_limit_or_reset:true,small_pulse_commands_responded:true,
    no_continuous_buzz_or_rapid_heating:true});
  const result=evaluate(r);assert.equal(result.status,'UNMOUNTED_TRIAL_RECORDED');
  assert.equal(result.assembled_leg_approved,false);
});
test('bad rail, OE and cutoff observations fail',()=>{
  for(const [key,value] of [['servo_rail_unloaded_V',6],['OE_disabled_V',2.2],['OE_enabled_V',1],['cutoff_servo_rail_V',5.2]]) {
    const r=synthetic();r.measurements[key]=value;assert.equal(evaluate(r).status,'SETUP_OR_TRIAL_FAILED',key);
  }
});
test('wrong types, false checks and invalid dates are rejected',()=>{
  let r=synthetic();r.checks.disabled_signals_low='true';assert.equal(evaluate(r).status,'INVALID_RECORD');
  r=synthetic();r.checks.disabled_signals_low=false;assert.equal(evaluate(r).status,'SETUP_OR_TRIAL_FAILED');
  r=synthetic();r.measured_on='2026-02-30';assert.equal(evaluate(r).status,'INVALID_RECORD');
  assert.equal(evaluate(null).status,'INVALID_RECORD');
});
test('missing trial evidence cannot claim completed trial',()=>{
  const r=synthetic();r.trial.performed=true;assert.equal(evaluate(r).status,'TRIAL_RECORD_INCOMPLETE');
});
test('actual servo limits, source rating and optional timing are enforced',()=>{
  for(const edit of [r=>r.measurements.servo_allowed_max_V=5,
    r=>r.measurements.psu_rated_current_A=0.3,r=>r.measurements.PWM_period_us_optional=10000]) {
    const r=synthetic();edit(r);assert.equal(evaluate(r).status,'SETUP_OR_TRIAL_FAILED');
  }
});
