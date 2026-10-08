import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const here=path.dirname(fileURLToPath(import.meta.url)),exe=path.join(here,'tools/openscad-2021.01/openscad.com');
const sha=file=>createHash('sha256').update(fs.readFileSync(path.join(here,file))).digest('hex');
const inputs=['fork-leg-parts.scad','prototype-fork-leg-probe.scad','prototype-fork-placement-probe.scad','prototype-pitch-fork.scad','prototype-upper-leg.scad','prototype-lower-leg.scad','hobby-joint-rear-arm.scad','hobby-joint-common.scad','prototype-j1-layout.scad',...JSON.parse(fs.readFileSync(path.join(here,'rigid-bench-check.json'))).parts.map(p=>p.file.replace('mechanical/','')),'prototype-pitch-fork-upper-mirrored.stl','prototype-pitch-fork-lower-mirrored.stl'];
const hashes=Object.fromEntries(inputs.map(f=>[f,sha(f)]));
function run(name,source,defs){const r=spawnSync(exe,['-o',path.join(here,name+'.stl'),...defs.flatMap(d=>['-D',d]),path.join(here,source)],{encoding:'utf8'});const log=r.stdout+r.stderr;fs.writeFileSync(path.join(here,name+'.log'),log);assert.doesNotMatch(log,/ERROR:|WARNING:/);return {status:r.status,log};}
function mesh(file){const v=[...fs.readFileSync(path.join(here,file),'utf8').matchAll(/vertex\s+([-+\d.eE]+)\s+([-+\d.eE]+)\s+([-+\d.eE]+)/g)].map(m=>m.slice(1).map(Number));assert.ok(v.length && v.length%3===0);let volume=0;for(let i=0;i<v.length;i+=3){const [a,b,c]=v.slice(i,i+3);volume+=(a[0]*(b[1]*c[2]-b[2]*c[1])+a[1]*(b[2]*c[0]-b[0]*c[2])+a[2]*(b[0]*c[1]-b[1]*c[0]))/6;}return {points:[...new Map(v.map(p=>[p.join(','),p])).values()],volume:Math.abs(volume)};}
function distance(a,b){let max=0;for(const p of a){let min=Infinity;for(const q of b)min=Math.min(min,p.reduce((s,n,i)=>s+(n-q[i])**2,0));max=Math.max(max,Math.sqrt(min));}return max;}
const correspondence=[];
for(const kind of ['upper','lower']){const meshes=[];for(const mode of ['source','placed']){const name=`fork-leg-${kind}-${mode}`;const r=run(name,'prototype-fork-placement-probe.scad',[`kind="${kind}"`,`mode="${mode}"`]);assert.equal(r.status,0,r.log);meshes.push(mesh(name+'.stl'));}const [a,b]=meshes,max=Math.max(distance(a.points,b.points),distance(b.points,a.points)),relative=Math.abs(a.volume-b.volume)/a.volume;assert.ok(max<=.002,`placed fork mismatch ${max}mm`);assert.ok(relative<.0001);correspondence.push({kind,max_bidirectional_vertex_difference_mm:max,relative_volume_difference:relative});console.log(`${kind}: physical/source correspondence passed`);}
const poses=[[0,44.0486,78.9786],[-25,20,60],[30,55,90],[-25,55,60],[30,20,90]],clearance=[];
for(let i=0;i<poses.length;i++){const [q1,q2,q3]=poses[i];const r=run(`fork-leg-carrier-check-${i}`,'prototype-fork-leg-probe.scad',[`q1=${q1}`,`q2=${q2}`,`q3=${q3}`]);assert.match(r.log,/Current top level object is empty/,'fork/hip intersection must be empty');clearance.push({angles_deg:poses[i],intersection_empty:true});console.log(`pose ${i}: fork/hip clearance passed`);}
for(const [f,h] of Object.entries(hashes))assert.equal(sha(f),h,'input changed during check');
fs.writeFileSync(path.join(here,'fork-leg-check.json'),JSON.stringify({correspondence,vertex_tolerance_mm:.002,clearance,input_sha256:hashes,scope:'New forks versus J1 fixed prints/case/bench adapter and moving arms/retainer/carrier at five sampled poses; not a continuous sweep or physical fit approval.',physical_tests_performed:false},null,2)+'\n');
