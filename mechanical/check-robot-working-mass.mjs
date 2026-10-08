import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import assert from 'node:assert/strict';
const here=path.dirname(fileURLToPath(import.meta.url));
const inputPath=path.join(here,'robot-mass-inputs.json');
const input=JSON.parse(fs.readFileSync(inputPath,'utf8'));
const plan=JSON.parse(fs.readFileSync(path.join(here,'four-leg-working-print-manifest.json'),'utf8'));
const hardware=JSON.parse(fs.readFileSync(path.join(here,'three-dof-hardware.json'),'utf8').replace(/^\uFEFF/,''));
const optional=x=>{assert.ok(x===null || (Number.isFinite(x)&&x>0),'invalid measured/slicer input');return x;};
const positive=x=>{assert.ok(Number.isFinite(x)&&x>0);return x;};
for(const [key,value]of Object.entries(input))if(key.startsWith('measured_'))optional(value);
const fraction=positive(input.assumed_printed_material_fraction);assert.ok(fraction<=1);
const parameters=fs.readFileSync(path.join(here,'../DESIGN_PARAMETERS.md'),'utf8');
const approvedLimit=Number(parameters.match(/MAX_OPERATING_MASS\s*=\s*([0-9.]+)\s*kg/)[1])*1000;
assert.equal(input.maximum_complete_mass_g,approvedLimit,'mass input differs from approved limit');
const knownNames=new Set(plan.parts.map(p=>path.basename(p.file)));
for(const name of Object.keys(input.print_unit_inputs))assert.ok(knownNames.has(name),'unknown/stale print record');
const prints=[];
for(const p of plan.parts) {
 const name=path.basename(p.file),bytes=fs.readFileSync(path.join(here,name));
 assert.equal(createHash('sha256').update(bytes).digest('hex').toUpperCase(),p.sha256,'stale working STL');
 assert.ok(Number.isInteger(p.quantity)&&p.quantity>0);
 const v=[...bytes.toString().matchAll(/vertex\s+([-+\d.eE]+)\s+([-+\d.eE]+)\s+([-+\d.eE]+)/g)].map(m=>m.slice(1).map(Number));
 assert.ok(v.length&&v.length%3===0&&v.flat().every(Number.isFinite));
 let volume=0;for(let i=0;i<v.length;i+=3){const [a,b,c]=v.slice(i,i+3);volume+=(a[0]*(b[1]*c[2]-b[2]*c[1])+a[1]*(b[2]*c[0]-b[0]*c[2])+a[2]*(b[0]*c[1]-b[1]*c[0]))/6;}
 const solid=Math.abs(volume)/1000*positive(input.PETG_density_g_per_cm3_assumed);
 input.print_unit_inputs[name]??={slicer_unit_g:null,measured_unit_g:null};
 const record=input.print_unit_inputs[name],measured=optional(record.measured_unit_g),sliced=optional(record.slicer_unit_g);
 prints.push({file:name,quantity:p.quantity,solid_unit_g:solid,assumed_unit_g:solid*fraction,chosen_unit_g:measured??sliced??solid*fraction,chosen_basis:measured!==null?'measured':sliced!==null?'slicer':'assumed material fraction',sha256:p.sha256});
}
assert.equal(prints.reduce((s,p)=>s+p.quantity,0),117);
const rho=positive(input.steel_density_g_per_cm3_assumed)/1000;
const thread=positive(input.threaded_shank_volume_fraction_assumed);assert.ok(thread<=1);
const cylinder=(d,h)=>Math.PI*d*d*h/4;
const hex=(af,h)=>Math.sqrt(3)*af*af*h/2;
const bolt=(d,length,headD,headH,socketAF,socketH)=>(cylinder(d,length)*thread+cylinder(headD,headH)-hex(socketAF,socketH))*rho;
const nut=(d,af,h)=>(hex(af,h)-cylinder(d,h))*rho;
const washer=(bore,od,h)=>(cylinder(od,h)-cylinder(bore,h))*rho;
const byLength=new Map();for(const role of hardware.M3_fastener_roles)byLength.set(role.length_mm,(byLength.get(role.length_mm)||0)+role.quantity*4);
byLength.set(16,byLength.get(16)+16); // Deck fixings, once.
assert.equal([...byLength.values()].reduce((a,b)=>a+b,0),156);
const fasteners=[];
for(const [length,quantity]of byLength)fasteners.push({item:`M3x${length}`,quantity,unit_g_estimated:bolt(3,length,5.5,3,2.5,1.3)});
for(const [item,quantity,unit]of [
 ['M3 nuts',hardware.M3_nuts*4+16,nut(3,5.5,2.4)],
 ['M3 ordinary washers',hardware.M3_normal_washers*4+32,washer(3.2,7,0.5)],
 ['M3 backing washers',4,washer(3.2,12,1)],
 ['M4x35 pivots',12,bolt(4,35,7,4,3,2)],
 ['M4 locknuts',12,nut(4,7,5)],
 ['M4 washers',12,washer(4.3,9,0.8)],
 ['M2x10 horn bolts (maximum)',48,bolt(2,10,3.8,2,1.5,1)],
 ['M2 horn nuts (maximum)',48,nut(2,4,1.6)],
 ['M2 horn washers (maximum)',96,washer(2.2,5,0.3)]])fasteners.push({item,quantity,unit_g_estimated:unit});
const hardwareEstimate=fasteners.reduce((s,p)=>s+p.quantity*p.unit_g_estimated,0);
const m3x40=fasteners.find(p=>p.item==='M3x40').unit_g_estimated;
assert.ok(Math.abs(m3x40-2.36)<0.05,'M3 reference sanity check');
const hardwareChosen=input.measured_complete_fasteners_g??hardwareEstimate;
const servos=12*(input.measured_servo_unit_g??positive(input.MG996R_unit_g_published));
const bearings=12*(input.measured_bearing_unit_g??positive(input['624_unit_g_reference']));
const extras=[['battery','battery'],['electronics_and_power','electronics_and_power'],['distribution_wiring','distribution_wiring'],['horns_feet_ties','horns_feet_ties']].map(([name,key])=>({item:name,g:input['measured_'+key+'_g']??positive(input[key+'_allowance_g']),basis:input['measured_'+key+'_g']!==null?'measured':'provisional allowance'}));
const extraTotal=extras.reduce((s,p)=>s+p.g,0),fixed=hardwareChosen+servos+bearings+extraTotal;
const solidTotal=prints.reduce((s,p)=>s+p.quantity*p.solid_unit_g,0),chosenPrints=prints.reduce((s,p)=>s+p.quantity*p.chosen_unit_g,0);
const allMeasured=prints.every(p=>p.chosen_basis==='measured')&&['measured_servo_unit_g','measured_bearing_unit_g','measured_complete_fasteners_g','measured_battery_g','measured_electronics_and_power_g','measured_distribution_wiring_g','measured_horns_feet_ties_g'].every(k=>input[k]!==null);
const report={revision:'working-robot-mass-1',complete_limit_g:input.maximum_complete_mass_g,printed_pieces:117,prints,fasteners,fastener_estimate_g:hardwareEstimate,servos_g:servos,bearings_g:bearings,extras,solid_CAD_prints_g:solidTotal,chosen_prints_g:chosenPrints,estimated_complete_g:fixed+chosenPrints,estimated_margin_g:input.maximum_complete_mass_g-fixed-chosenPrints,available_print_mass_g:input.maximum_complete_mass_g-fixed,required_max_material_fraction:(input.maximum_complete_mass_g-fixed)/solidTotal,all_component_masses_measured:allMeasured,measured_complete_robot_g:input.measured_complete_robot_g,status:input.measured_complete_robot_g!==null?(input.measured_complete_robot_g<=input.maximum_complete_mass_g?'MEASURED_WITHIN_LIMIT':'MEASURED_OVER_LIMIT'):'NOT_MEASURED',sources:input.sources,limits:'Solid CAD mass is not printed mass; 65% material fraction is an example, not an infill setting. Fastener dimensions/thread factor are rough reference-based estimates, not product weights. Unselected power/battery hardware and actual materials can change this screen.'};
report.fastener_geometry_assumptions={M3_cap_mm:{diameter:5.5,height:3,socket_AF:2.5,socket_depth:1.3},M3_nut_mm:{AF:5.5,height:2.4,bore:3},M3_washer_mm:{bore:3.2,OD:7,thickness:0.5},M3_backing_washer_mm:{bore:3.2,OD:12,thickness:1},M4_cap_mm:{diameter:7,height:4,socket_AF:3,socket_depth:2},M4_locknut_mm:{AF:7,height:5,bore:4},M4_washer_mm:{bore:4.3,OD:9,thickness:0.8},M2_cap_mm:{diameter:3.8,height:2,socket_AF:1.5,socket_depth:1},M2_nut_mm:{AF:4,height:1.6,bore:2},M2_washer_mm:{bore:2.2,OD:5,thickness:0.3},note:'Rough reference envelopes; mixed/partial threads, locking inserts and actual washer sizes need weighing. Some close positions require6mm OD washers;7mm here conservatively screens mass.'};
report.M3x40_reference_check={estimated_unit_g:m3x40,published_unit_g:2.36};
report.independent_volume_spot_checks=[];
for(const [file,validation,part]of [
 ['prototype-j1-carrier.stl','prototype-three-dof-check.json','j1-carrier'],
 ['prototype-lower-leg.stl','prototype-pitch-leg-check.json','lower-leg'],
 ['prototype-chassis-deck.stl','prototype-chassis-check.json','deck']]) {
 const reference=JSON.parse(fs.readFileSync(path.join(here,validation),'utf8').replace(/^\uFEFF/,''));
 const expected=reference.meshes.find(p=>p.part===part).volume_mm3;
 const actual=prints.find(p=>p.file===file).solid_unit_g*1000/input.PETG_density_g_per_cm3_assumed;
 assert.ok(Math.abs(actual-expected)<0.01,'independent CAD-volume report differs');
 report.independent_volume_spot_checks.push({file,reference:validation,volume_difference_mm3:Math.abs(actual-expected)});
}
fs.writeFileSync(inputPath,JSON.stringify(input,null,2)+'\n');
fs.writeFileSync(path.join(here,'robot-working-mass-check.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({solid_prints_g:solidTotal,assumed_prints_g:chosenPrints,fasteners_g:hardwareEstimate,servos_g:servos,bearings_g:bearings,other_allowances_g:extraTotal,estimated_complete_g:report.estimated_complete_g,margin_g:report.estimated_margin_g,available_prints_g:report.available_print_mass_g,max_solid_material_fraction:report.required_max_material_fraction,status:report.status},null,2));
