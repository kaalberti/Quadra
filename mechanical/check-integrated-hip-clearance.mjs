import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {closedMesh} from './mesh-check.mjs';
const here=path.dirname(fileURLToPath(import.meta.url)),exe=path.join(here,'tools/openscad-2021.01/openscad.com');
const sha=f=>createHash('sha256').update(fs.readFileSync(path.join(here,f))).digest('hex');
const dependencies=['prototype-integrated-hip.scad','prototype-integrated-hip-assembly.scad','prototype-integrated-hip-probe.scad','prototype-j1-carrier.scad','hobby-joint-front-arm.scad','hobby-joint-rear-arm.scad','hobby-joint-support.scad','hobby-joint-common.scad','prototype-j1-layout.scad','fork-leg-parts.scad','prototype-integrated-hip.stl',...JSON.parse(fs.readFileSync(path.join(here,'fork-leg-placement.json'))).placements.map(p=>p.file)];
const hashes=Object.fromEntries(dependencies.map(f=>[f,sha(f)]));
function run(name,source,defs){const r=spawnSync(exe,['-o',path.join(here,name+'.stl'),...defs.flatMap(d=>['-D',d]),path.join(here,source)],{encoding:'utf8'}),log=r.stdout+r.stderr;fs.writeFileSync(path.join(here,name+'.log'),log);assert.doesNotMatch(log,/ERROR:|WARNING:/);return {status:r.status,log};}
const poses=[[0,44.0486,78.9786],[-25,20,60],[30,55,90]],clearance=[];
for(let i=0;i<poses.length;i++){const [q1,q2,q3]=poses[i],r=run(`integrated-hip-clearance-${i}`,'prototype-integrated-hip-probe.scad',[`q1=${q1}`,`q2=${q2}`,`q3=${q3}`]);assert.match(r.log,/Current top level object is empty/);clearance.push({angles_deg:poses[i],intersection_empty:true});console.log(`pose ${i}: integrated hip clearance passed`);}
const source=run('integrated-hip-world-source','prototype-integrated-hip.scad',['view="world"']);assert.equal(source.status,0,source.log);
const a=closedMesh(path.join(here,'integrated-hip-world-source.stl')),
 b=closedMesh(path.join(here,'prototype-integrated-hip.stl'));
const points=v=>[...new Map(v.map(p=>[p.join(','),p])).values()];
const expected=points(a.v),placed=points(b.v.map(p=>[p[0],p[2]-28,-p[1]]));
function distance(a,b){let max=0;for(const p of a){let min=Infinity;for(const q of b)min=Math.min(min,p.reduce((s,n,i)=>s+(n-q[i])**2,0));max=Math.max(max,Math.sqrt(min));}return max;}
const difference=Math.max(distance(expected,placed),distance(placed,expected));assert.ok(difference<=.002);
assert.ok(Math.abs(a.volume-b.volume)/a.volume<.0001);
console.log('source/proper-print placement correspondence passed');
const mirrored=run('prototype-integrated-hip-mirrored','prototype-integrated-hip.scad',['hand=-1']);assert.equal(mirrored.status,0,mirrored.log);
const mirror=closedMesh(path.join(here,'prototype-integrated-hip-mirrored.stl'));
const key=p=>p.map(n=>Math.round(n*1000)).join(',');
const signature=v=>[...new Set(v.map(key))].sort().join('|');
assert.equal(signature(b.v.map(p=>[p[0],-p[1],p[2]])),signature(mirror.v));
assert.ok(Math.abs(mirror.bounds[2][0])<1e-5 && mirror.size.every(n=>n<=300));
for(const [f,h] of Object.entries(hashes))assert.equal(sha(f),h,'input changed during verification');
fs.writeFileSync(path.join(here,'integrated-hip-clearance-check.json'),JSON.stringify({clearance,source_placement_vertex_difference_mm:difference,mirrored_mesh:{sha256:mirror.sha256,closed:true,connected:true,size_mm:mirror.size},input_sha256:hashes,scope:'Three sampled poses, modeled J1 fixed prints/case/bench adapter, J2 case and moving pitch parts. Intended J2 support/carrier and J1 retainer contacts excluded. Not a continuous sweep or actual horn/ear/lead check.',physical_fit_verified:false},null,2)+'\n');
