import fs from 'node:fs';import assert from 'node:assert/strict';
const read=n=>JSON.parse(fs.readFileSync(new URL(n,import.meta.url),'utf8').replace(/^\uFEFF/,''));
const p=read('buffer-perfboard-layout.json'),v=read('voltage-perfboard-addon.json');
const occupied=new Set();
for(const c of [...p.components,...p.headers])for(const t of c.pins)occupied.add(`${t.column},${t.row}`);
for(const c of [...v.components,...v.headers])for(const t of c.pins){
  assert(t.column>=0 && t.column<p.grid.columns && t.row>=0 && t.row<p.grid.rows);
  const key=`${t.column},${t.row}`;assert(!occupied.has(key),'shared pad '+key);occupied.add(key);
}
assert.equal(occupied.size,172);assert.equal(v.physical_tested,false);assert.equal(v.gpio,8);
const pins=id=>[...v.components,...v.headers].find(c=>c.id===id).pins;
assert.deepEqual(pins('RV_TOP').map(t=>t.net),['SENSE_POS','ADC8']);
assert.deepEqual(pins('RV_BOTTOM').map(t=>t.net),['ADC8','GND']);
assert.deepEqual(pins('CV').map(t=>t.net),['ADC8','GND']);
assert.deepEqual(pins('VS_IN').map(t=>t.net),['SENSE_POS','GND']);
assert.deepEqual(pins('VS_ADC').map(t=>t.net),['ADC8','GND']);
const tol=v.resistor_tolerance_fraction,highBottom=v.bottom_ohms*(1+tol),lowTop=v.top_ohms*(1-tol);
const maximumAdc=v.input_max_v*highBottom/(lowTop+highBottom);
assert(maximumAdc<2.0);assert.equal(1+v.top_ohms/v.bottom_ohms,16);
const worstTotal=(v.top_ohms+v.bottom_ohms)*(1-tol);
const worstCurrent=v.input_max_v/worstTotal;
const topPower=worstCurrent**2*v.top_ohms*(1+tol),bottomPower=worstCurrent**2*highBottom;
assert(topPower<v.resistor_power_w/10 && bottomPower<v.resistor_power_w/10);
const tau=(v.top_ohms*v.bottom_ohms/(v.top_ohms+v.bottom_ohms))*v.filter_f;
console.log(`PASS:172 unique pads including optional monitor; divider scale16; worst ADC=${maximumAdc.toFixed(4)}V; conservative resistor powers=${(topPower*1000).toFixed(2)}/${(bottomPower*1000).toFixed(2)}mW; RC=${(tau*1000).toFixed(3)}ms. Physical fit/accuracy remains untested.`);
