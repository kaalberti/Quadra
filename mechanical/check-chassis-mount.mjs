import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import assert from 'node:assert/strict';
const here=path.dirname(fileURLToPath(import.meta.url));
const results=[];
const sub=(a,b)=>a.map((n,i)=>n-b[i]);
const dot=(a,b)=>a.reduce((sum,n,i)=>sum+n*b[i],0);
const cross=(a,b)=>[a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]];
function rayHits(origin,direction,a,b,c) {
  const e1=sub(b,a),e2=sub(c,a),h=cross(direction,e2),det=dot(e1,h);
  if(Math.abs(det)<1e-9) return false;
  const inv=1/det,s=sub(origin,a),u=inv*dot(s,h);
  if(u<0 || u>1) return false;
  const q=cross(s,e1),w=inv*dot(direction,q);
  return w>=0 && u+w<=1 && inv*dot(e2,q)>1e-8;
}
for(const part of ['mount-left','mount-right','deck']) {
  const text=fs.readFileSync(path.join(here,`prototype-chassis-${part}.stl`),'utf8');
  const v=[...text.matchAll(/vertex\s+([-+\d.eE]+)\s+([-+\d.eE]+)\s+([-+\d.eE]+)/g)].map(m=>m.slice(1).map(Number));
  assert.ok(v.length>0 && v.length%3===0);
  assert.ok(v.flat().every(Number.isFinite));
  const edges=new Map(),adj=Array.from({length:v.length/3},()=>[]);
  let volume=0;
  for(let i=0;i<v.length;i+=3) {
    const keys=v.slice(i,i+3).map(p=>p.join(','));
    assert.equal(new Set(keys).size,3,'degenerate facet');
    for(const [a,b] of [[0,1],[1,2],[2,0]]) {
      const key=[keys[a],keys[b]].sort().join('|');
      if(!edges.has(key)) edges.set(key,[]);
      edges.get(key).push(i/3);
    }
    const [a,b,c]=v.slice(i,i+3);
    volume+=(a[0]*(b[1]*c[2]-b[2]*c[1])+a[1]*(b[2]*c[0]-b[0]*c[2])+a[2]*(b[0]*c[1]-b[1]*c[0]))/6;
  }
  for(const owners of edges.values()) {
    assert.equal(owners.length,2,'nonmanifold/open edge');
    adj[owners[0]].push(owners[1]);adj[owners[1]].push(owners[0]);
  }
  const seen=new Set([0]),pending=[0];
  while(pending.length) for(const n of adj[pending.pop()]) if(!seen.has(n)) {seen.add(n);pending.push(n);}
  assert.equal(seen.size,adj.length,'disconnected surface');
  const bounds=[0,1,2].map(a=>[Math.min(...v.map(p=>p[a])),Math.max(...v.map(p=>p[a]))]);
  const size=bounds.map(([a,b])=>b-a);
  assert.ok(Math.abs(bounds[2][0])<1e-5,'bed origin');
  assert.ok(size.every(n=>n<=300),'conservative 300mm bed envelope');
  const expected=part==='deck'?[180,110,4]:[66,59,33];
  size.forEach((n,i)=>assert.ok(Math.abs(n-expected[i])<0.001,'unexpected dimensions'));
  const holes=[];
  if(part==='deck') {
    for(const f of [-1,1]) for(const s of [-1,1]) for(const x of [-28,-16]) for(const y of [-25,-10])
      holes.push({centre:[f*(75+x),s*(55+y),-10],axis:2});
  } else {
    const hand=part==='mount-left'?1:-1;
    for(const y of [-3.65,24.35]) for(const z of [-17.25,17.25]) holes.push({centre:[hand*y,-z,-10],axis:2});
    for(const x of [-28,-16]) for(const y of [-25,-10]) holes.push({centre:[hand*y,-40,-x-3],axis:1});
    holes.push({centre:[0,0,-10],axis:2}); // Pivot access, not a fixing hole.
  }
  // Test the actual mesh, including points on a nominal 3mm bolt envelope.
  for(const {centre,axis} of holes) {
    const direction=[0,0,0];direction[axis]=1;
    const offsets=[[0,0,0]];
    for(const a of [0,1,2].filter(a=>a!==axis)) for(const sign of [-1,1]) {
      const offset=[0,0,0];offset[a]=sign*1.5;offsets.push(offset);
    }
    for(const offset of offsets) {
      const origin=centre.map((n,i)=>n+offset[i]);
      for(let i=0;i<v.length;i+=3) assert.ok(!rayHits(origin,direction,...v.slice(i,i+3)),`blocked fixing/access path in ${part}`);
    }
  }
  results.push({part,triangles:v.length/3,closed:true,connected:true,size_mm:size,volume_mm3:Math.abs(volume),solid_PETG_g:Math.abs(volume)/1000*1.27});
}
assert.ok(Math.abs(results[0].volume_mm3-results[1].volume_mm3)<0.01,'mirror volume mismatch');
const report={revision:'chassis-attachment-prototype',meshes:results,physical_fit_verified:false,loaded_strength_verified:false,mass_note:'Solid CAD estimate, not slicer or measured print mass.'};
fs.writeFileSync(path.join(here,'prototype-chassis-check.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(report,null,2));
