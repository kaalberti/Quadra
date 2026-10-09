import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import {closedMesh,rayCrosses} from './mesh-check.mjs';
import {verifyArtifacts} from './verify-st3215-artifacts.mjs';
console.log(verifyArtifacts());
const source='mechanical/st3215-chassis.scad';
const hash=file=>createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const dependencies=[source,'mechanical/st3215-leg.scad','mechanical/st3215-battery-tray.stl','mechanical/st3215-hip.stl','mechanical/st3215-mount.stl','mechanical/st3215-leg-check.json','mechanical/check-st3215-chassis.mjs'];
const initial=Object.fromEntries(dependencies.map(file=>[file,hash(file)]));
const text=fs.readFileSync(source,'utf8');
const number=name=>{const m=text.match(new RegExp('\\b'+name+'=([-+\\d.]+)\\s*;'));assert(m,`Missing ${name}`);return Number(m[1]);};
const hx=number('hip_x'),hy=number('hip_y'),floor=number('floor_bottom'),floorTop=number('floor_top'),deckZ=number('deck_z');
const compiler=path.resolve('mechanical/tools/openscad-2021.01/openscad.com');
const rows=[];
for(const [part,quantity] of [['body',1],['deck',1],['riser',4]]){
 const file=`mechanical/st3215-chassis-${part}.stl`;
 const r=spawnSync(compiler,['-o',file,'-D',`chassis_part="${part}"`,source],{encoding:'utf8',timeout:120000});
 assert.equal(r.status,0,r.stderr);assert(!/ERROR|WARNING/.test(r.stderr+r.stdout));
 const mesh=closedMesh(file);assert(Math.abs(mesh.bounds[2][0])<.001);assert(mesh.size.every(v=>v<=300));
 rows.push({part,file,quantity,sha256:mesh.sha256,size_mm:mesh.size,solid_volume_mm3:mesh.volume});
 console.log(`Printable ${part}: ${mesh.size.join(' x ')} mm`);
}
const body=closedMesh(rows[0].file),deck=closedMesh(rows[1].file),riser=closedMesh(rows[2].file);
assert.deepEqual(body.size,[175,160,42]);assert.deepEqual(deck.size,[140,140,4]);assert.deepEqual(riser.size,[10,10,51]);
// Derive fixture positions independently from the existing leg mounting-plate axes.
const fixture=[];
const legMount=closedMesh('mechanical/st3215-mount.stl');
for(const u of [16,38])for(const v of [-26,26]){
 assert(!rayCrosses(legMount.v,[u,v,-1],[0,0,1],7),'actual leg fixture bore blocked');
 assert(rayCrosses(legMount.v,[u+3,v,-1],[0,0,1],7),'no leg material around fixture bore');
}
for(const rear of [false,true])for(const side of [-1,1])for(const u of [16,38])for(const v of [-26,26]){
 const direction=rear?-1:1;
 const p=[direction*(hx-27.5-10),side*hy+direction*v,-u-floor];
 assert(!rayCrosses(body.v,p,[direction,0,0],20),'hip fixture bore blocked');
 fixture.push([direction*(hx-27.5),side*hy+direction*v,-u]);
}
for(const x of [-55,55])for(const y of [-29,29,-60,60])assert(!rayCrosses(body.v,[x,y,-1],[0,0,1],7),'floor mounting bore blocked');
for(const x of [-55,55])for(const y of [-60,60])assert(!rayCrosses(deck.v,[x,y,-1],[0,0,1],6),'deck bore blocked');
assert(!rayCrosses(riser.v,[0,0,-1],[0,0,1],53),'riser bore blocked');
const deg=n=>n*Math.PI/180;
const rx=(v,a)=>[v[0],v[1]*Math.cos(deg(a))-v[2]*Math.sin(deg(a)),v[1]*Math.sin(deg(a))+v[2]*Math.cos(deg(a))];
const rz=(v,a)=>[v[0]*Math.cos(deg(a))-v[1]*Math.sin(deg(a)),v[0]*Math.sin(deg(a))+v[1]*Math.cos(deg(a)),v[2]];
const t=(v,d)=>v.map((n,i)=>n+d[i]);
const A=v=>[v[2],v[1],-v[0]];
const P=v=>[85+v[1],v[2],v[0]];
const bounds=v=>[0,1,2].map(i=>[Math.min(...v.map(p=>p[i])),Math.max(...v.map(p=>p[i]))]);
const intersects=(a,b)=>a.every(([lo,hi],i)=>Math.min(hi,b[i][1])-Math.max(lo,b[i][0])>.0001);
const box=(lo,hi)=>[0,1].flatMap(x=>[0,1].flatMap(y=>[0,1].map(z=>[x?hi[0]:lo[0],y?hi[1]:lo[1],z?hi[2]:lo[2]])));
const meshes=Object.fromEntries(['clamp-bottom','clamp-top','upper','lower','hip','mount','shims','shim-rear'].map(p=>[p,closedMesh(`mechanical/st3215-${p}.stl`).v]));
const caseV=box([-10.11,-12.36,-17.5],[35.11,12.36,17.5]);
const report=JSON.parse(fs.readFileSync('mechanical/st3215-leg-check.json','utf8'));
assert.deepEqual(report.axis_lengths_mm,[70,85]);
const bodyBounds=[[ -87.5,87.5],[-80,80],[-48,-6]];
const poses=[];
for(const abduction of [0,5]){
 const legBounds=[];const feet=[];
 for(const rear of [false,true])for(const side of [-1,1]){
  const q=side*(rear?-1:1)*abduction;
  const place=v=>t(rz(v,rear?180:0),[rear?-hx:hx,side*hy,0]);
  // Rotations are proper: Rz determinant +1; no reflected handed printed parts.
  const pitch=v=>rx(P(v),q);
  const upper=v=>pitch(rz(v,-44.0486));
  const knee=v=>upper(t(v,[-70,0,0]));
  const lower=v=>knee(rz(v,78.9786));
  const items=[];
  const add=(name,vertices,transform)=>items.push({name,vertices:vertices.map(v=>place(transform(v)))});
  const cb=v=>t(v,[0,0,-22.5]),ct=v=>rx(t(v,[0,0,-22.5]),180);
  for(const [name,raw] of [['clamp-bottom',cb],['clamp-top',ct]]){
   add(`J1 ${name}`,meshes[name],v=>A(raw(v)));add(`J2 ${name}`,meshes[name],v=>pitch(raw(v)));add(`J3 ${name}`,meshes[name],v=>knee(raw(v)));
  }
  add('mount',meshes.mount,v=>A(t(v,[0,0,-27.5])));
  add('hip',meshes.hip,v=>rx(rx(t(v,[0,0,-27.5]),-90),q));
  add('upper',meshes.upper,v=>upper(rx(t(v,[0,0,-24]),-90)));
  add('lower',meshes.lower,v=>lower(rx(t(v,[0,0,-14]),-90)));
  add('J1 case',caseV,A);add('J2 case',caseV,pitch);add('J3 case',caseV,knee);
  for(const [name,z] of [['shims',18.625],['shim-rear',-23]]){
   add(`J1 ${name}`,meshes[name],v=>rx(A(t(v,[0,0,z])),q));
   add(`J2 ${name}`,meshes[name],v=>upper(t(v,[0,0,z])));
   add(`J3 ${name}`,meshes[name],v=>lower(t(v,[0,0,z])));
  }
  const candidates=items.filter(i=>intersects(bounds(i.vertices),bodyBounds));
  assert(candidates.every(i=>i.name==='hip'),'Unexpected body collision candidate: '+candidates.map(i=>i.name));
  legBounds.push(bounds(items.flatMap(i=>i.vertices)));feet.push(place(rx(report.foot_mm,q)));
 }
 for(let i=0;i<4;i++)for(let j=i+1;j<4;j++)assert(!intersects(legBounds[i],legBounds[j]),'Conservative leg boxes overlap');
 const file=`mechanical/st3215-chassis-hip-clearance-${abduction}.stl`;
 const r=spawnSync(compiler,['-o',file,'-D','chassis_part="hip-collision"','-D',`test_abduction=${abduction}`,source],{encoding:'utf8',timeout:120000});
 const log=r.stdout+r.stderr;fs.writeFileSync(file.replace('.stl','.log'),log);
 assert.equal(r.status,1,log);assert(/Current top level object is empty/.test(log));assert(!/ERROR|WARNING/.test(log));assert(!fs.existsSync(file),'hip intersection mesh exists');
 poses.push({outward_abduction_deg:abduction,leg_aabbs_disjoint:true,hip_body_intersection_empty:true,foot_reference_mm:feet});
 console.log(`Four-leg clearance passed at outward abduction ${abduction} deg`);
}
// Central tray fits between walls; padded battery and straps leave deck access.
assert(67<82.5 && 33<60-5);assert(floorTop+25<deckZ);
assert(70<82.5 && 70<80);
const reservations=[...text.matchAll(/translate\(\[([-+\d]+),([-+\d]+),deck_z\+deck_thickness\]\)cube\(\[([\d,]+)\]\)/g)].map(m=>({origin:[Number(m[1]),Number(m[2]),deckZ+4],size:m[3].split(',').map(Number)}));
assert.equal(reservations.length,3,'Missing provisional electronics reservations');
for(const r of reservations){
 assert(r.origin[0]>=-70 && r.origin[0]+r.size[0]<=70 && r.origin[1]>=-70 && r.origin[1]+r.size[1]<=70);
 for(const x of [-55,55])for(const y of [-60,60])assert(!(r.origin[0]<x+4 && r.origin[0]+r.size[0]>x-4 && r.origin[1]<y+4 && r.origin[1]+r.size[1]>y-4),'Reservation blocks deck nut/tool space');
}
for(const [file,before] of Object.entries(initial))assert.equal(hash(file),before,`Input changed: ${file}`);
const result={task:'MEC-172',inputs_sha256:initial,parts:rows,fixture_holes_world_mm:fixture,poses,
 electronics_reserved_spaces:reservations,battery_envelope_mm:[120,50,20],battery_to_deck_gap_mm:deckZ-(floorTop+24),nominal_floor_ground_clearance_mm:120+floor,
 geometric_center_support_margin_mm:hy,actual_center_of_mass_known:false,
 body_solid_petg_g:rows.reduce((s,r)=>s+r.quantity*r.solid_volume_mm3*1.24/1000,0),
 complete_robot_mass_g:null,physical_fit_verified:false,loaded_range_released:false,
 limitations:'Two clearance poses only. Hub relief checked by actual mesh intersection; other body/leg and inter-leg separations use conservative AABBs. Hardware protrusions, cable bends and actual boards omitted. COM/loaded strength and gait remain unqualified.'};
fs.writeFileSync('mechanical/st3215-chassis-check.json',JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({body_solid_petg_g:result.body_solid_petg_g,nominal_floor_ground_clearance_mm:result.nominal_floor_ground_clearance_mm,physical_fit_verified:false}));
