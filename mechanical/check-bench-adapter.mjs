import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const here=path.dirname(fileURLToPath(import.meta.url));
const text=fs.readFileSync(path.join(here,'prototype-bench-base.stl'),'utf8');
const v=[...text.matchAll(/vertex\s+([-+\d.eE]+)\s+([-+\d.eE]+)\s+([-+\d.eE]+)/g)].map(m=>m.slice(1).map(Number));
assert.ok(v.length && v.length%3===0 && v.flat().every(Number.isFinite));
const edges=new Map(),adj=Array.from({length:v.length/3},()=>[]);
let volume=0;
for(let i=0;i<v.length;i+=3) {
  const keys=v.slice(i,i+3).map(p=>p.join(','));
  assert.equal(new Set(keys).size,3);
  for(const [a,b] of [[0,1],[1,2],[2,0]]) {const key=[keys[a],keys[b]].sort().join('|');if(!edges.has(key)) edges.set(key,[]);edges.get(key).push(i/3);}
  const [a,b,c]=v.slice(i,i+3);
  volume+=(a[0]*(b[1]*c[2]-b[2]*c[1])+a[1]*(b[2]*c[0]-b[0]*c[2])+a[2]*(b[0]*c[1]-b[1]*c[0]))/6;
}
for(const owners of edges.values()) {assert.equal(owners.length,2);adj[owners[0]].push(owners[1]);adj[owners[1]].push(owners[0]);}
const seen=new Set([0]),queue=[0];while(queue.length) for(const n of adj[queue.pop()]) if(!seen.has(n)){seen.add(n);queue.push(n);}
assert.equal(seen.size,adj.length,'disconnected adapter');
const bounds=[0,1,2].map(a=>[Math.min(...v.map(p=>p[a])),Math.max(...v.map(p=>p[a]))]);
const size=bounds.map(([a,b])=>b-a);
[67.75,40.5,7].forEach((n,i)=>assert.ok(Math.abs(size[i]-n)<0.001));
assert.ok(Math.abs(bounds[2][0])<1e-5);
assert.ok(size.every(n=>n<=300));
// Barycentric projected-triangle test of vertical fastener paths in the STL.
function blocked(x,y) {
  for(let i=0;i<v.length;i+=3) {
    const [a,b,c]=v.slice(i,i+3),d=(b[1]-c[1])*(a[0]-c[0])+(c[0]-b[0])*(a[1]-c[1]);
    if(Math.abs(d)<1e-9) continue;
    const u=((b[1]-c[1])*(x-c[0])+(c[0]-b[0])*(y-c[1]))/d;
    const w=((c[1]-a[1])*(x-c[0])+(a[0]-c[0])*(y-c[1]))/d;
    if(u>=0 && w>=0 && u+w<=1) return true;
  }
  return false;
}
const holes=[];
for(const x of [-14,14]) for(const y of [-17.25,17.25]) holes.push([x,y,1.5]);
for(const y of [-12,12]) holes.push([-35,y,2]);
holes.push([-10.35,0,10.5]);
for(const [x,y,r] of holes) for(const [dx,dy] of [[0,0],[r,0],[-r,0],[0,r],[0,-r]]) assert.ok(!blocked(x+dx,y+dy),'blocked fixing/pivot access');
const probe=spawnSync(path.join(here,'tools/openscad-2021.01/openscad.com'),['-o',path.join(here,'prototype-bench-fit-probe.stl'),path.join(here,'prototype-bench-fit-probe.scad')],{encoding:'utf8'});
const log=probe.stdout+probe.stderr;
assert.equal(probe.status,1,log);assert.match(log,/Current top level object is empty/);assert.doesNotMatch(log,/ERROR|WARNING/);
fs.writeFileSync(path.join(here,'prototype-bench-fit-probe.log'),log);
const report={revision:'bench-adapter-rib-clearance-1',closed:true,connected:true,triangles:v.length/3,size_mm:size,volume_mm3:Math.abs(volume),fixing_and_pivot_paths_clear:true,support_intersection_empty:true,intended_contact_excluded_mm:0.001,rib_clearance_mm:0.2,physical_fit_verified:false};
const hash=file=>createHash('sha256').update(fs.readFileSync(path.join(here,file))).digest('hex').toUpperCase();
report.stl_sha256=hash('prototype-bench-base.stl');
report.cad_sha256=hash('prototype-bench-base.scad');
fs.writeFileSync(path.join(here,'prototype-bench-fit-check.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(report,null,2));
