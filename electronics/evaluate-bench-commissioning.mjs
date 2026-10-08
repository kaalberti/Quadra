import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';

export function evaluate(r) {
  const missing=[], invalid=[], failures=[], notes=[];
  if(!r || typeof r!=='object' || Array.isArray(r))
    return {status:'INVALID_RECORD',invalid:['Expected an object'],assembled_leg_approved:false};
  if(r.revision!=='bench-power-1') invalid.push('Wrong revision');
  for(const key of ['measured_by','measured_on','servo_model','servo_voltage_source','controller_board','psu_model']) {
    if(r[key]==null || r[key]==='') missing.push(key);
    else if(typeof r[key]!=='string') invalid.push(key);
  }
  if(typeof r.measured_on==='string' && r.measured_on) {
    const d=new Date(r.measured_on+'T00:00:00Z');
    if(!/^\d{4}-\d{2}-\d{2}$/.test(r.measured_on) || !Number.isFinite(+d) ||
      d.toISOString().slice(0,10)!==r.measured_on) invalid.push('measured_on');
  }
  const m=r.measurements??{};
  const number=(key,minimum,maximum,optional=false)=>{
    const v=m[key];
    if(v==null){if(!optional)missing.push(key);return;}
    if(typeof v!=='number' || !Number.isFinite(v)){invalid.push(key);return;}
    if(v<minimum || v>maximum)failures.push(key);
  };
  number('servo_allowed_min_V',0.1,5.3);
  number('servo_allowed_max_V',4.8,20);
  number('psu_rated_current_A',0.1,100);
  number('initial_current_limit_A',0.1,0.5); // modest initial horn-off trial, not final duty limit
  number('servo_rail_unloaded_V',4.8,5.3);
  number('logic_V',3.0,3.4);
  number('OE_disabled_V',2,3.4);
  number('OE_enabled_V',0,0.8);
  number('cutoff_servo_rail_V',0,0.2);
  number('PWM_period_us_optional',19000,21000,true);
  number('PWM_centre_us_optional',1400,1600,true);
  if(Number.isFinite(m.OE_disabled_V) && Number.isFinite(m.logic_V) &&
      m.OE_disabled_V<0.7*m.logic_V) failures.push('OE disabled below PCA VIH');
  if(Number.isFinite(m.initial_current_limit_A) && Number.isFinite(m.psu_rated_current_A) &&
      m.initial_current_limit_A>m.psu_rated_current_A) failures.push('Limit exceeds PSU rating');
  if(Number.isFinite(m.servo_allowed_min_V) && Number.isFinite(m.servo_allowed_max_V)) {
    if(m.servo_allowed_min_V>m.servo_allowed_max_V) invalid.push('Servo voltage range reversed');
    if(Number.isFinite(m.servo_rail_unloaded_V) &&
        (m.servo_rail_unloaded_V<m.servo_allowed_min_V || m.servo_rail_unloaded_V>m.servo_allowed_max_V))
      failures.push('Rail outside actual servo voltage range');
  }
  const boolean=(object,key,missingList=missing)=>{
    const v=object?.[key];
    if(v==null)missingList.push(key);
    else if(typeof v!=='boolean')invalid.push(key);
    else if(!v)failures.push(key);
  };
  for(const key of ['polarity_and_common_ground_verified','actual_board_pins_and_pullups_verified',
    'external_power_distribution_and_fuse_verified','OE_high_at_startup_and_MCU_reset',
    'disabled_signals_low','only_one_secured_servo_horn_removed','physical_cutoff_removes_servo_and_buffer_power'])
    boolean(r.checks,key);
  if(m.PWM_period_us_optional==null || m.PWM_centre_us_optional==null)
    notes.push('PWM timing unmeasured; optional for initial horn-off trial, measure before wider/mounted motion');
  const trialMissing=[];
  const trial=r.trial??{};
  if(trial.performed!=null && typeof trial.performed!=='boolean')invalid.push('trial.performed');
  if(trial.performed===true) {
    for(const key of ['observed_min_servo_rail_V','observed_current_A']) {
      if(trial[key]==null)trialMissing.push(key);
      else if(typeof trial[key]!=='number' || !Number.isFinite(trial[key]))invalid.push(key);
    }
    if(Number.isFinite(trial.observed_min_servo_rail_V) &&
       (trial.observed_min_servo_rail_V<Math.max(4.8,m.servo_allowed_min_V??4.8) ||
        trial.observed_min_servo_rail_V>Math.min(5.3,m.servo_allowed_max_V??5.3))) failures.push('Trial rail voltage');
    if(Number.isFinite(trial.observed_current_A) &&
       (trial.observed_current_A<0 || trial.observed_current_A>m.initial_current_limit_A)) failures.push('Trial current');
    for(const key of ['PSU_did_not_limit_or_reset','small_pulse_commands_responded','no_continuous_buzz_or_rapid_heating'])
      boolean(trial,key,trialMissing);
  }
  const status=invalid.length?'INVALID_RECORD':failures.length?'SETUP_OR_TRIAL_FAILED':
    missing.length?'NOT_MEASURED':trial.performed===true?
      (trialMissing.length?'TRIAL_RECORD_INCOMPLETE':'UNMOUNTED_TRIAL_RECORDED'):'READY_FOR_ONE_UNMOUNTED_SERVO_TRIAL';
  return {status,missing,trial_missing:trialMissing,invalid,failures,notes,
    evidence:'Operator-recorded observations; no automatic hardware qualification',
    assembled_leg_approved:false,three_servo_supply_approved:false};
}

if(process.argv[1] && path.resolve(process.argv[1])===fileURLToPath(import.meta.url)) {
  const source=process.argv[2]??new URL('./bench-commissioning.json',import.meta.url);
  const result=evaluate(JSON.parse(fs.readFileSync(source,'utf8').replace(/^\uFEFF/,'')));
  console.log(JSON.stringify(result,null,2));
  if(['INVALID_RECORD','SETUP_OR_TRIAL_FAILED'].includes(result.status))process.exitCode=1;
}
