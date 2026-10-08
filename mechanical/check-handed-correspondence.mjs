// Independent source CAD export versus physically placed working mesh.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const here=path.dirname(fileURLToPath(import.meta.url)),results=[];
const dependencies=['prototype-handed-correspondence-probe.scad','working-handed-probe-data.scad','prototype-j1-layout.scad','prototype-j1-carrier.scad','prototype-upper-leg.scad','hobby-joint-common.scad','hobby-joint-support.scad','prototype-j1-carrier-mirrored.stl','prototype-upper-leg-saddle-mirrored.stl'];
const hash=file=>createHash('sha256').update(fs.readFileSync(path.join(here,file))).digest('hex').toUpperCase();
const dependencyHashes=Object.fromEntries(dependencies.map(file=>[file,hash(file)]));
const exportHashes={};
function readMesh(file) {
 const text=fs.readFileSync(file,'utf8');
 const v=[...text.matchAll(/vertex\s+([-+\d.eE]+)\s+([-+\d.eE]+)\s+([-+\d.eE]+)/g)].map(m=>m.slice(1).map(Number));
 assert.ok(v.length && v.length%3===0);
 const points=[...new Map(v.map(p=>[p.map(n=>Math.round(n*1e6)).join(','),p])).values()];
 let volume=0;for(let i=0;i<v.length;i+=3){const [a,b,c]=v.slice(i,i+3);volume+=(a[0]*(b[1]*c[2]-b[2]*c[1])+a[1]*(b[2]*c[0]-b[0]*c[2])+a[2]*(b[0]*c[1]-b[1]*c[0]))/6;}
 return {points,volume:Math.abs(volume)};
}
function distance(a,b) {
 let max=0;for(const p of a){let min=Infinity;for(const q of b){const d=p.reduce((s,n,i)=>s+(n-q[i])**2,0);if(d<min)min=d;}max=Math.max(max,Math.sqrt(min));}return max;
}
for(const part of ['carrier','saddle']) {
 const meshes=[];
 for(const mode of ['source','placed']) {
  const file=path.join(here,`handed-${part}-${mode}-probe.stl`);
  let log;
  if(process.argv.includes('--reuse-exports')) {
   const outputTime=fs.statSync(file).mtimeMs;
   for(const dependency of dependencies)assert.ok(fs.statSync(path.join(here,dependency)).mtimeMs<=outputTime,`stale export: ${dependency}`);
   log=fs.readFileSync(file.replace('.stl','.log'),'utf8');
  } else {
   const r=spawnSync(path.join(here,'tools/openscad-2021.01/openscad.com'),['-o',file,'-D',`part="${part}"`,'-D',`mode="${mode}"`,path.join(here,'prototype-handed-correspondence-probe.scad')],{encoding:'utf8'});
   log=r.stdout+r.stderr;assert.equal(r.status,0,log);
  }
  assert.doesNotMatch(log,/ERROR|WARNING/);
  assert.match(log,/Top level object is a 3D object/);
  // Direct import/transform exports do not enter CGAL and omit its Simple field.
  if(/Simple:/.test(log))assert.match(log,/Simple:\s+yes/);
  fs.writeFileSync(file.replace('.stl','.log'),log);meshes.push(readMesh(file));
  exportHashes[path.basename(file)]=hash(path.basename(file));
 }
 const [a,b]=meshes,max=Math.max(distance(a.points,b.points),distance(b.points,a.points));
 // OpenSCAD ASCII STL coordinates use limited significant digits; separately
 // rounded transformed exports can differ by about1um in this size envelope.
 assert.ok(max<=0.002,`${part}: source/placed vertices differ ${max}mm`);
 const volumeRelative=Math.abs(a.volume-b.volume)/a.volume;
 assert.ok(volumeRelative<0.0001,`${part}: source/placed volumes differ`);
 results.push({part,source_points:a.points.length,placed_points:b.points.length,max_bidirectional_vertex_difference_mm:max,relative_volume_difference:volumeRelative,source_volume_mm3:a.volume,placed_volume_mm3:b.volume});
}
const report={method:'Fresh source CAD exports vs physically placed meshes; no coplanar Boolean operations',vertex_tolerance_mm:0.002,tolerance_note:'Allows separate ASCII STL coordinate rounding; not manufacturing tolerance.',results,physical_fit_verified:false};
for(const [file,digest]of Object.entries(dependencyHashes))assert.equal(hash(file),digest,'dependency changed during check');
report.dependency_sha256=dependencyHashes;report.export_sha256=exportHashes;
fs.writeFileSync(path.join(here,'handed-correspondence-check.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(report,null,2));
