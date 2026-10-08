// MEC-158. Nominal working assembly from real printable meshes and proper poses.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import assert from 'node:assert/strict';
const here=path.dirname(fileURLToPath(import.meta.url));
function writeIfChanged(name,text){const file=path.join(here,name);if(!fs.existsSync(file)||fs.readFileSync(file,'utf8')!==text)fs.writeFileSync(file,text);}
const I=[[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]];
const mul=(a,b)=>a.map((row,i)=>row.map((_,j)=>row.reduce((s,n,k)=>s+n*b[k][j],0)));
const chain=(...m)=>m.reduce(mul,I);
const T=(x,y,z)=>[[1,0,0,x],[0,1,0,y],[0,0,1,z],[0,0,0,1]];
const trig=a=>[Math.cos(a*Math.PI/180),Math.sin(a*Math.PI/180)];
const Rx=a=>{const [c,s]=trig(a);return [[1,0,0,0],[0,c,-s,0],[0,s,c,0],[0,0,0,1]];};
const Rz=a=>{const [c,s]=trig(a);return [[c,-s,0,0],[s,c,0,0],[0,0,1,0],[0,0,0,1]];};
const My=[[1,0,0,0],[0,-1,0,0],[0,0,1,0],[0,0,0,1]];
const det=a=>a[0][0]*(a[1][1]*a[2][2]-a[1][2]*a[2][1])-a[0][1]*(a[1][0]*a[2][2]-a[1][2]*a[2][0])+a[0][2]*(a[1][0]*a[2][1]-a[1][1]*a[2][0]);
function assertRigid(m,role) {
 assert.ok(Math.abs(det(m)-1)<1e-8,`improper pose: ${role}`);
 for(let a=0;a<3;a++)for(let b=0;b<3;b++)assert.ok(Math.abs(m.slice(0,3).reduce((sum,row)=>sum+row[a]*row[b],0)-(a===b?1:0))<1e-8,`scaled/sheared pose: ${role}`);
}
const point=(m,p)=>m.slice(0,3).map(row=>row.slice(0,3).reduce((s,n,i)=>s+n*p[i],row[3]));
const signature=points=>[...new Set(points.map(p=>p.map(n=>Math.round(n*1000)).join(',')))].sort().join('|');
const centre=v=>[0,1,2].map(a=>(Math.min(...v.map(p=>p[a]))+Math.max(...v.map(p=>p[a])))/2);
const bounds=v=>[0,1,2].map(a=>[Math.min(...v.map(p=>p[a])),Math.max(...v.map(p=>p[a]))]);
function mesh(name) {
 const file=path.join(here,name+'.stl'),bytes=fs.readFileSync(file),text=bytes.toString();
 const facets=[...text.matchAll(/vertex\s+([-+\d.eE]+)\s+([-+\d.eE]+)\s+([-+\d.eE]+)/g)].map(m=>m.slice(1).map(Number));
 assert.ok(facets.length && facets.length%3===0 && facets.flat().every(Number.isFinite));
 const unique=[...new Map(facets.map(p=>[p.join(','),p])).values()];
 return {name,facets,unique,centre:centre(unique),sha256:createHash('sha256').update(bytes).digest('hex').toUpperCase()};
}
// All proper signed permutations: translations are resolved from mesh centres.
const rotations=[];
for(const perm of [[0,1,2],[0,2,1],[1,0,2],[1,2,0],[2,0,1],[2,1,0]]) for(const x of [-1,1]) for(const y of [-1,1]) for(const z of [-1,1]) {
 const r=I.map(row=>row.slice());for(let a=0;a<3;a++){for(let b=0;b<3;b++)r[a][b]=0;r[a][perm[a]]=[x,y,z][a];}
 if(det(r)>0) rotations.push(r);
}
assert.equal(rotations.length,24);
const baseline=JSON.parse(fs.readFileSync(path.join(here,'three-dof-print-manifest.json'),'utf8').replace(/^\uFEFF/,''));
const names=baseline.parts.filter(p=>!p.fixture_only).map(p=>path.basename(p.file,'.stl').replace(/-mirrored$/,''));
names.push('prototype-chassis-mount-left','prototype-chassis-mount-right','prototype-chassis-deck');
const library=new Map(names.map(n=>[n,mesh(n)]));
const mirrors=new Map();
const newMeshChecks=[];
function validateNewMesh(m) {
 const edges=new Map(),adj=Array.from({length:m.facets.length/3},()=>[]);
 for(let i=0;i<m.facets.length;i+=3) {
  const keys=m.facets.slice(i,i+3).map(p=>p.join(','));assert.equal(new Set(keys).size,3);
  for(const [a,b]of [[0,1],[1,2],[2,0]]){const key=[keys[a],keys[b]].sort().join('|');if(!edges.has(key))edges.set(key,[]);edges.get(key).push(i/3);}
 }
 for(const owners of edges.values()){assert.equal(owners.length,2,'open/nonmanifold mirror');adj[owners[0]].push(owners[1]);adj[owners[1]].push(owners[0]);}
 const seen=new Set([0]),queue=[0];while(queue.length)for(const n of adj[queue.pop()])if(!seen.has(n)){seen.add(n);queue.push(n);}
 assert.equal(seen.size,adj.length,'disconnected mirror');
 const b=bounds(m.unique),size=b.map(([a,z])=>z-a);
 assert.ok(Math.abs(b[2][0])<1e-5);assert.ok(size.every(n=>n<=300));
 return {file:m.name+'.stl',triangles:adj.length,closed:true,connected:true,on_bed:true,size_mm:size};
}
for(const name of names) {
 const source=library.get(name),target=source.unique.map(p=>point(My,p)),tc=centre(target),sig=signature(target);
 let match;
 for(const candidateName of [name,...names.filter(n=>n!==name)]) {
  const candidate=library.get(candidateName);
  if(candidate.unique.length!==source.unique.length)continue;
  for(const r of rotations) {
   const rc=point(r,candidate.centre),q=chain(T(...tc.map((n,i)=>n-rc[i])),r);
   if(signature(candidate.unique.map(p=>point(q,p)))===sig){match={file:candidateName,transform:q,reused:true};break;}
  }
  if(match)break;
 }
 if(!match) {
  const variant=name+'-mirrored',candidate=mesh(variant);
  assert.equal(signature(candidate.unique),sig,`mirrored source correspondence: ${name}`);
  newMeshChecks.push(validateNewMesh(candidate));
  library.set(variant,candidate);match={file:variant,transform:I,reused:false};
 }
 mirrors.set(name,match);
}
const study=fs.readFileSync(path.join(here,'prototype-four-leg-study.scad'),'utf8');
const common=fs.readFileSync(path.join(here,'hobby-joint-common.scad'),'utf8');
const layout=fs.readFileSync(path.join(here,'prototype-j1-layout.scad'),'utf8');
const number=(text,key)=>Number(text.match(new RegExp(`${key}=([-0-9.]+)`))[1]);
const [q1,q2,q3]=['q1','q2','q3'].map(n=>number(study,n));
const shaft=number(common,'shaft_x'),horn=number(common,'horn_z'),rear=number(common,'rear_top'),rt=number(common,'rear_t'),bridge=number(common,'bridge_r');
const J=[[0,0,1,0],[1,0,0,0],[0,1,0,0],[0,0,0,1]];
const P=chain(Rx(q1),[[0,-1,0,number(layout,'j1_pitch_forward')],[0,0,1,number(layout,'j1_pitch_floor_y')],[1,0,0,number(layout,'j1_pitch_vertical')],[0,0,0,1]]);
const C=chain(Rx(q1),[[1,0,0,0],[0,0,1,number(layout,'j1_carrier_back_y')],[0,1,0,0],[0,0,0,1]]);
const instances=[];
const add=(role,file,m)=>instances.push({role,file,target:m});
function fixed(prefix,m) {
 for(const side of ['left','right'])add(prefix+' cradle '+side,'hobby-servo-cradle-'+side,chain(m,T(-shaft,0,0)));
 add(prefix+' support','hobby-joint-support',chain(m,T(-shaft,0,0),Rx(180)));
 add(prefix+' 8mm spacer','hobby-joint-front-spacer',chain(m,T(0,0,-18)));
 add(prefix+' 3mm spacer','hobby-joint-rear-spacer',chain(m,T(0,0,-26)));
}
fixed('J1',J);
const fork=chain(Rx(q1),J,Rz(90));
add('J1 front arm','hobby-joint-front-arm',chain(fork,T(0,0,horn)));
add('J1 rear arm','hobby-joint-rear-arm',chain(fork,T(0,0,rear),Rx(180)));
add('J1 retainer','hobby-joint-retainer',chain(fork,T(0,0,rear-rt),Rx(180)));
add('J1 carrier','prototype-j1-carrier',C);
fixed('J2',P);
const upper=chain(P,Rz(q2));
add('J2 upper plate','prototype-upper-leg-plate',chain(upper,T(0,0,horn)));
add('J2 rear arm','hobby-joint-rear-arm',chain(upper,T(0,0,rear),Rz(180),Rx(180)));
add('J2 bridge','hobby-joint-bridge',chain(upper,T(bridge,0,rear)));
add('J2 retainer','hobby-joint-retainer',chain(upper,T(0,0,rear-rt),Rx(180)));
add('Knee saddle','prototype-upper-leg-saddle',chain(upper,T(0,0,28)));
add('Cable guide','prototype-cable-guide',chain(upper,T(-24.5,0,55)));
const K=chain(upper,T(-70,0,0)),lower=chain(K,Rz(-q3));
add('Knee support','prototype-knee-support',chain(K,T(0,0,-8)));
add('Knee 10mm spacer','prototype-knee-spacer',chain(K,T(0,0,-18)));
add('Knee 3mm spacer','hobby-joint-rear-spacer',chain(K,T(0,0,-26)));
add('Lower plate','prototype-lower-leg',chain(lower,T(0,0,50)));
add('Knee rear arm','hobby-joint-rear-arm',chain(lower,T(0,0,rear),Rx(180)));
add('Knee bridge','hobby-joint-bridge',chain(lower,T(-bridge,0,rear)));
add('Knee retainer','hobby-joint-retainer',chain(lower,T(0,0,rear-rt),Rx(180)));
add('Foot carrier','prototype-foot',chain(lower,T(-76,0,47)));
assert.equal(instances.length,28);
const counts=new Map(),placed=[],servos=[];
function place(role,name,target) {
 const d=det(target),selection=d>0?{file:name,transform:I}:mirrors.get(name);
 assert.ok(Math.abs(Math.abs(d)-1)<1e-8);
 const pose=d>0?target:chain(target,My,selection.transform);
 assertRigid(pose,role);
 const original=library.get(name),selected=library.get(selection.file);
 assert.equal(signature(original.unique.map(p=>point(target,p))),signature(selected.unique.map(p=>point(pose,p))),`assembled geometry correspondence: ${role}`);
 counts.set(selection.file,(counts.get(selection.file)||0)+1);
 placed.push({role,file:selection.file+'.stl',matrix:pose});
}
const mountPose=[[0,0,-1,-3],[1,0,0,0],[0,-1,0,0],[0,0,0,1]];
for(const f of [-1,1])for(const s of [-1,1]) {
 const body=[[f,0,0,f*number(study,'root_length')/2],[0,s,0,s*number(study,'root_width')/2],[0,0,1,number(study,'root_height')],[0,0,0,1]];
 const leg=(f>0?'front':'rear')+'-'+(s>0?'left':'right');
 for(const i of instances)place(leg+' '+i.role,i.file,chain(body,i.target));
 place(leg+' chassis mount','prototype-chassis-mount-left',chain(body,mountPose));
 for(const [joint,parent] of [['J1',J],['J2',P],['J3',chain(K,Rz(90))]]) {
  const target=chain(body,parent),pose=det(target)>0?target:chain(target,My);
  assertRigid(pose,leg+' '+joint);
  const box=[];for(const x of [-10,30.7])for(const y of [-9.85,9.85])for(const z of [3,45.9])box.push([x,y,z]);
  assert.equal(signature(box.map(p=>point(target,p))),signature(box.map(p=>point(pose,p))));
  servos.push({role:leg+' '+joint,matrix:pose});
 }
}
place('Deck','prototype-chassis-deck',T(0,0,155));
assert.equal(placed.length,117);assert.equal(servos.length,12);
const parts=[...counts].map(([name,quantity])=>({file:'mechanical/'+name+'.stl',quantity,sha256:library.get(name).sha256}));
const plan={revision:'four-leg-working-1',scope:'Unpowered nominal assembly study, not manufacturing release',physical_fit_verified:false,parts,placements:placed,servo_case_placements:servos,mirrored_variants:[...mirrors].filter(([,v])=>!v.reused).map(([name,v])=>({source:name+'.stl',variant:v.file+'.stl'})),checks:{proper_part_poses:117,proper_servo_poses:12,mesh_coordinate_quantization_mm:0.001,axis_aligned_reuse_orientations:24}};
plan.new_mesh_checks=newMeshChecks;
writeIfChanged('four-leg-working-print-manifest.json',JSON.stringify(plan,null,2)+'\n');
let scad='// Generated by build-four-leg-working-plan.mjs. All placement matrices are proper.\n';
const colour=role=>role.includes('chassis')?'tomato':role==='Deck'?'gray':role.includes('Lower')||role.includes('Knee rear')||role.includes('Knee bridge')?'seagreen':role.includes('upper')||role.includes('J2 rear')||role.includes('J2 bridge')?'royalblue':role.includes('J1')&&!role.includes('carrier')?'mediumpurple':'gold';
for(const p of placed) scad+=`multmatrix(${JSON.stringify(p.matrix)}) color("${colour(p.role)}") import("${p.file}"); // ${p.role}\n`;
for(const p of servos)scad+=`multmatrix(${JSON.stringify(p.matrix)}) color("dimgray") translate([-10,-9.85,3]) cube([40.7,19.7,42.9]); // ${p.role}\n`;
writeIfChanged('prototype-four-leg-working-assembly.scad',scad);
const carrier=placed.find(p=>p.role==='front-left J1 carrier'),saddle=placed.find(p=>p.role==='front-left Knee saddle');
writeIfChanged('working-handed-probe-data.scad',`// Generated physical poses, checked independently against source CAD.\ncarrier_pose=${JSON.stringify(carrier.matrix)};\nsaddle_pose=${JSON.stringify(saddle.matrix)};\n`);
console.log(JSON.stringify({unique_prints:parts.length,pieces:placed.length,new_mirrored_variants:plan.mirrored_variants,checks:plan.checks},null,2));
