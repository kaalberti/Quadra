import fs from 'node:fs';
import assert from 'node:assert/strict';
const p=JSON.parse(fs.readFileSync(new URL('./bench-power.json',import.meta.url),'utf8'));
const areaMm2=awg=>Math.PI*(0.127*Math.pow(92,(36-awg)/39))**2/4;
const resistance=awg=>0.01724/areaMm2(awg); // copper ohm·mm²/m at20C
const current=p.servo_count*p.design_allowance_per_servo_A;
const mainR=2*p.main_one_way_length_m*resistance(p.main_wire_AWG);
const branchR=2*p.branch_one_way_length_m*resistance(p.branch_wire_AWG);
const drop=current*mainR+p.design_allowance_per_servo_A*branchR;
assert(p.servo_supply_max_V<=5.5,'AHCT supply ceiling');
assert(p.servo_supply_V-drop>=4.8,'Candidate voltage floor before connector losses');
assert(p.distribution_min_rating_A>=current*(1+p.supply_margin_fraction),'Distribution rating');
assert(p.main_fuse_A<=p.distribution_min_rating_A,'Fuse exceeds distribution rating');
assert.notEqual(p.SDA_GPIO,p.SCL_GPIO);
assert.notEqual(p.OE_GPIO,p.SDA_GPIO);
assert.notEqual(p.OE_GPIO,p.SCL_GPIO);
const result={planning_peak_A:current,supply_capacity_target_A:current*(1+p.supply_margin_fraction),
  wire_only_drop_V:drop,wire_only_min_servo_V:p.servo_supply_V-drop,
  main_wire_dissipation_W:current*current*mainR,
  per_branch_wire_dissipation_W:p.design_allowance_per_servo_A**2*branchR,
  excludes:'Existing servo leads, plugs, contact resistance, temperature rise, PSU transient response and exact servo variation',
  actual_power_test_performed:false};
console.log(JSON.stringify(result,null,2));
