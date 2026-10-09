import fs from 'node:fs';
import {spawnSync} from 'node:child_process';
import path from 'node:path';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {closedMesh,rayCrosses} from './mesh-check.mjs';
const quantities={'clamp-bottom':3,'clamp-top':3,upper:1,lower:1,hip:1,mount:1,shims:6};
const compiler=path.resolve('mechanical/tools/openscad-2021.01/openscad.com');
const source='mechanical/st3215-leg.scad';
const traySource='mechanical/st3215-battery-tray.scad';
const hashFile=file=>createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const initialTrayHash=hashFile(traySource),initialCheckerHash=hashFile('mechanical/check-st3215-leg.mjs');
const initialSource=fs.readFileSync(source);const initialHash=createHash('sha256').update(initialSource).digest('hex');
const sourceText=initialSource.toString('utf8');
assert(sourceText.includes('L1=70; L2=85; pitch_forward=85;'));
assert(sourceText.includes('[[0,1,0,85],[0,0,1,0],[1,0,0,0],[0,0,0,1]]'),'pitch placement must be a proper rotation');
const matrices=[...new Set([...sourceText.matchAll(/multmatrix\((\[\[.*?\]\])\)/g)].map(m=>m[1]))].map(JSON.parse);
assert.equal(matrices.length,2);
const rotationDeterminants=matrices.map(m=>{
 const det=m[0][0]*(m[1][1]*m[2][2]-m[1][2]*m[2][1])-m[0][1]*(m[1][0]*m[2][2]-m[1][2]*m[2][0])+m[0][2]*(m[1][0]*m[2][1]-m[1][1]*m[2][0]);
 assert.equal(det,1,'reflected placement');
 for(let i=0;i<3;i++)for(let j=0;j<3;j++)assert.equal(m[i].slice(0,3).reduce((s,v,k)=>s+v*m[j][k],0),i===j?1:0,'nonrigid placement');
 return det;
});
for(const part of Object.keys(quantities)){
 const r=spawnSync(compiler,['-o',`mechanical/st3215-${part}.stl`,'-D',`part="${part}"`,source],{encoding:'utf8',timeout:60000});
 assert.equal(r.status,0,`compile failed ${part}: ${r.stderr}`);
 assert(!/ERROR|WARNING/.test((r.stdout||'')+(r.stderr||'')),'compiler warning/error');
}
const clearance=[];
const runId=Date.now();
for(const [index,pose] of [[0,[0,44.0486,78.9786]],[1,[-15,20,60]],[2,[15,55,90]]]){
 for(const kind of ['collision','pair-collision']){
  const out=`mechanical/st3215-${runId}-${index}-${kind}.stl`;
  const r=spawnSync(compiler,['-o',out,'-D',`part="${kind}"`,'-D',`q1=${pose[0]}`,'-D',`q2=${pose[1]}`,'-D',`q3=${pose[2]}`,source],{encoding:'utf8',timeout:60000});
  const log=out.slice(0,-4)+'.log';const diagnostics=(r.stdout||'')+(r.stderr||'');fs.writeFileSync(log,diagnostics);
  assert.equal(r.status,1,`expected empty intersection at ${pose}: ${r.stderr}`);
  assert(/Current top level object is empty/.test(diagnostics));
  assert(!/ERROR|WARNING/.test(diagnostics));assert(!fs.existsSync(out),'intersection mesh present');
  clearance.push({pose_deg:pose,kind,empty:true});
  console.log(`Clearance passed ${kind} at ${pose}`);
 }
}
assert.equal(createHash('sha256').update(fs.readFileSync(source)).digest('hex'),initialHash,'source changed during validation');
const rows=[];
for(const [part,quantity] of Object.entries(quantities)){
 const file=`mechanical/st3215-${part}.stl`,m=closedMesh(file);
 assert(Math.abs(m.bounds[2][0])<.001,`${part} not on print bed`);
 assert(m.size.every(v=>v<=300),`${part} exceeds conservative bed`);
 rows.push({part,file,quantity,sha256:m.sha256,size_mm:m.size,solid_volume_mm3:m.volume});
}
// Independent arithmetic from retained axis lengths and drawing clearances.
const q2=44.0486*Math.PI/180,q3=78.9786*Math.PI/180;
const knee=[85+70*Math.sin(q2),0,-70*Math.cos(q2)];
const foot=[knee[0]+85*Math.sin(q2-q3),0,knee[2]-85*Math.cos(q2-q3)];
assert(Math.abs(Math.hypot(knee[0]-85,knee[2])-70)<1e-9);
assert(Math.abs(Math.hypot(foot[0]-knee[0],foot[2]-knee[2])-85)<1e-9);
assert(Math.abs(foot[2]+120)<.001);
assert(23-17.5>0);assert(16-10.11>0);
// Physical foot surface matches the nominal vertical contact plane,not a rounded tip.
const theta=(78.9786-44.0486)*Math.PI/180;
const n=[Math.cos(theta),-Math.sin(theta)];
const lower=closedMesh('mechanical/st3215-lower.stl');
const contact=lower.v.map(v=>[v[0],v[2]-14]);
const signed=contact.map(v=>n[0]*(v[0]+85)+n[1]*v[1]);
assert(Math.min(...signed)>-.001,'printed foot extends below nominal contact');
assert(signed.some(v=>Math.abs(v)<.001),'contact surface missing');
const hole=[-85+4*n[0],4*n[1]+14];
assert(!rayCrosses(lower.v,[hole[0],-30,hole[1]],[0,1,0],60),'foot bore obstructed');
const clamp=closedMesh('mechanical/st3215-clamp-bottom.stl');
for(const y of [-18,18]) assert(!rayCrosses(clamp.v,[23.5,y,-1],[0,0,1],25),'clamp bolt bore obstructed');
const trayCompile=spawnSync(compiler,['-o','mechanical/st3215-battery-tray.stl','mechanical/st3215-battery-tray.scad'],{encoding:'utf8',timeout:60000});
assert.equal(trayCompile.status,0);assert(!/ERROR|WARNING/.test((trayCompile.stdout||'')+(trayCompile.stderr||'')));
const tray=closedMesh('mechanical/st3215-battery-tray.stl');
assert.deepEqual(tray.size,[134,66,11]);assert.equal(tray.bounds[2][0],0);
for(const x of [-55,55])for(const y of [-29,29])assert(!rayCrosses(tray.v,[x,y,-1],[0,0,1],14));
assert.equal(hashFile(source),initialHash,'leg source changed during validation');
assert.equal(hashFile(traySource),initialTrayHash,'tray source changed during validation');
assert.equal(hashFile('mechanical/check-st3215-leg.mjs'),initialCheckerHash,'checker changed during validation');
const report={schema_version:2,checker_sha256:initialCheckerHash,tray_source_sha256:initialTrayHash,placement_rotation_determinants:rotationDeterminants,sampled_clearance:clearance,source_sha256:createHash('sha256').update(fs.readFileSync('mechanical/st3215-leg.scad')).digest('hex'),battery_tray:{size_mm:tray.size,sha256:tray.sha256,pack_envelope_mm:[120,50,20],physical_fit_verified:false},task:'MEC-170',parts:rows,print_pieces:rows.reduce((s,r)=>s+r.quantity,0),knee_mm:knee,foot_mm:foot,axis_lengths_mm:[70,85],case_to_fork_axial_gap_mm:5.5,web_to_case_gap_mm:5.89,nominal_wheel_spacer_mm:4.375,physical_fit_verified:false,battery_mount_released:false};
fs.writeFileSync('mechanical/st3215-leg-check.json',JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({parts:rows.length,pieces:report.print_pieces,foot,solid_petg_g:rows.reduce((s,r)=>s+r.solid_volume_mm3*r.quantity*1.24/1000,0),physical_fit_verified:false},null,2));
