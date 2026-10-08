import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {closedMesh} from './mesh-check.mjs';
const here=path.dirname(fileURLToPath(import.meta.url)),exe=path.join(here,'tools/openscad-2021.01/openscad.com');
const sha=f=>createHash('sha256').update(fs.readFileSync(path.join(here,f))).digest('hex');
const plan=JSON.parse(fs.readFileSync(path.join(here,'integrated-four-leg-print-manifest.json')));
const dependencies=['integrated-four-leg-print-manifest.json','integrated-four-leg-parts.scad','prototype-integrated-four-leg-probe.scad','prototype-integrated-hip.scad','prototype-j1-carrier.scad','prototype-j1-layout.scad','hobby-joint-common.scad','hobby-joint-support.scad','hobby-joint-front-arm.scad','hobby-joint-rear-arm.scad','prototype-fork-placement-probe.scad','prototype-pitch-fork.scad','prototype-upper-leg.scad','prototype-lower-leg.scad',...plan.parts.map(p=>p.file.replace('mechanical/',''))];
const hashes=Object.fromEntries(dependencies.map(f=>[f,sha(f)]));
function run(name,source,defs){const r=spawnSync(exe,['-o',path.join(here,name+'.stl'),...defs.flatMap(d=>['-D',d]),path.join(here,source)],{encoding:'utf8'}),log=r.stdout+r.stderr;fs.writeFileSync(path.join(here,name+'.log'),log);assert.doesNotMatch(log,/ERROR:|WARNING:/);return {status:r.status,log};}
const sources=new Map();
const sourceDependencies=['prototype-integrated-hip.scad','prototype-j1-carrier.scad','prototype-j1-layout.scad','hobby-joint-common.scad','hobby-joint-support.scad','hobby-joint-front-arm.scad','hobby-joint-rear-arm.scad','prototype-fork-placement-probe.scad','prototype-pitch-fork.scad','prototype-upper-leg.scad','prototype-lower-leg.scad','fork-leg-parts.scad'];
const exportHashes={};
for(const family of ['hip','upper','lower']) {
 const name=`integrated-four-leg-${family}-source`;
 if(process.argv.includes('--reuse-source-exports')) {
  const time=fs.statSync(path.join(here,name+'.stl')).mtimeMs;
  for(const dep of sourceDependencies)assert.ok(fs.statSync(path.join(here,dep)).mtimeMs<=time,'stale source export');
  const log=fs.readFileSync(path.join(here,name+'.log'),'utf8');assert.doesNotMatch(log,/ERROR:|WARNING:/);assert.match(log,/Top level object is a 3D object/);
 } else {const r=family==='hip'?run(name,'prototype-integrated-hip.scad',['view="world"']):run(name,'prototype-fork-placement-probe.scad',[`kind="${family}"`,'mode="source"']);assert.equal(r.status,0,r.log);}
 sources.set(family,closedMesh(path.join(here,name+'.stl')));exportHashes[name+'.stl']=sha(name+'.stl');console.log(`${family}: intended source export checked`);
}
const point=(m,p)=>m.slice(0,3).map(row=>row.slice(0,3).reduce((s,n,i)=>s+n*p[i],row[3]));
const unique=v=>[...new Map(v.map(p=>[p.join(','),p])).values()];
function distance(a,b){let max=0;for(const p of a){let min=Infinity;for(const q of b)min=Math.min(min,p.reduce((s,n,i)=>s+(n-q[i])**2,0));max=Math.max(max,Math.sqrt(min));}return max;}
const correspondence=[];
for(const p of plan.new_placements){const source=sources.get(p.family),mesh=closedMesh(path.join(here,p.file));const expected=unique(source.v).map(v=>point(p.leg_frame,v)),actual=unique(mesh.v).map(v=>point(p.matrix,v));const diff=Math.max(distance(expected,actual),distance(actual,expected));assert.ok(diff<=.002,p.role);assert.ok(Math.abs(source.volume-mesh.volume)/source.volume<.0001);correspondence.push({role:p.role,file:p.file,max_bidirectional_vertex_difference_mm:diff});}
console.log('12 new physical placements match fresh source geometry');
const cache=new Map();function bounds(p){if(!cache.has(p.file))cache.set(p.file,closedMesh(path.join(here,p.file)));const v=cache.get(p.file).v.map(v=>point(p.matrix,v));return [0,1,2].map(a=>[Math.min(...v.map(p=>p[a])),Math.max(...v.map(p=>p[a]))]);}
const pairs=[],clearance=[];
for(const part of plan.new_placements)for(const chassis of plan.placements.filter(p=>/chassis mount|deck/i.test(p.role))){const a=bounds(part),b=bounds(chassis),separated=a.some(([lo,hi],i)=>hi<b[i][0]-1e-8 || b[i][1]<lo-1e-8);if(separated)clearance.push({part:part.role,chassis:chassis.role,method:'disjoint actual-mesh bounds',intersection_empty:true});else pairs.push({part,chassis});}
const data='// Generated nominal candidates; all other pairs have disjoint mesh bounds.\nchassis_pairs='+JSON.stringify(pairs.map(({part,chassis})=>[part.matrix,part.file,chassis.matrix,chassis.file]))+';\n';fs.writeFileSync(path.join(here,'integrated-four-leg-probe-data.scad'),data);hashes['integrated-four-leg-probe-data.scad']=sha('integrated-four-leg-probe-data.scad');
for(let i=0;i<pairs.length;i++){const r=run(`integrated-four-leg-chassis-pair-${i}`,'prototype-integrated-four-leg-probe.scad',[`pair_index=${i}`]);assert.match(r.log,/Current top level object is empty/);const {part,chassis}=pairs[i];clearance.push({part:part.role,chassis:chassis.role,method:'pairwise CGAL intersection',intersection_empty:true});console.log(`chassis pair ${i+1}/${pairs.length}: empty`);}
assert.equal(clearance.length,60);
for(const [f,h] of Object.entries(hashes))assert.equal(sha(f),h,'input changed during check');
fs.writeFileSync(path.join(here,'integrated-four-leg-check.json'),JSON.stringify({correspondence,vertex_tolerance_mm:.002,clearance,new_parts_nominal_chassis_intersection_empty:true,scope:'All60 nominal new-part/chassis pairs, using disjoint actual-mesh bounds or pairwise CGAL. Combined union export failed CGAL and is not counted. Unchanged geometry/placements reuse previous validation. Not a continuous sweep or actual fit/load claim.',input_sha256:hashes,source_export_sha256:exportHashes,physical_fit_verified:false},null,2)+'\n');
