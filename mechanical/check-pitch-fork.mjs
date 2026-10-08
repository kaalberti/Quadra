import fs from 'node:fs';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
const root=new URL('./',import.meta.url);
const results=[];
const vertices={};
const sub=(a,b)=>a.map((n,i)=>n-b[i]);
const dot=(a,b)=>a.reduce((s,n,i)=>s+n*b[i],0);
const cross=(a,b)=>[a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]];
function hit(origin,a,b,c,length) {
 const direction=[0,0,1],e1=sub(b,a),e2=sub(c,a),h=cross(direction,e2),det=dot(e1,h);
 if(Math.abs(det)<1e-9)return false;
 const s=sub(origin,a),u=dot(s,h)/det,q=cross(s,e1),w=dot(direction,q)/det,t=dot(e2,q)/det;
 return u>=0 && w>=0 && u+w<=1 && t>1e-7 && t<length-1e-7;
}
for(const kind of ['upper','lower']) for(const suffix of ['', '-mirrored']) {
 const file=`prototype-pitch-fork-${kind}${suffix}.stl`,raw=fs.readFileSync(new URL(file,root));
 const v=[...raw.toString().matchAll(/vertex\s+([-+\d.eE]+)\s+([-+\d.eE]+)\s+([-+\d.eE]+)/g)].map(m=>m.slice(1).map(Number));
 assert.ok(v.length>0 && v.length%3===0 && v.flat().every(Number.isFinite));
 vertices[file]=v;
 const edges=new Map(),adj=Array.from({length:v.length/3},()=>[]);let volume=0;
 for(let i=0;i<v.length;i+=3){
  const [a,b,c]=v.slice(i,i+3),keys=[a,b,c].map(p=>p.join(','));
  assert.equal(new Set(keys).size,3);
  for(const [j,k] of [[0,1],[1,2],[2,0]]){const key=[keys[j],keys[k]].sort().join('|');if(!edges.has(key))edges.set(key,[]);edges.get(key).push(i/3);}
  volume+=(a[0]*(b[1]*c[2]-b[2]*c[1])+a[1]*(b[2]*c[0]-b[0]*c[2])+a[2]*(b[0]*c[1]-b[1]*c[0]))/6;
 }
 for(const owners of edges.values()){assert.equal(owners.length,2,'open/nonmanifold edge');adj[owners[0]].push(owners[1]);adj[owners[1]].push(owners[0]);}
 const seen=new Set([0]),pending=[0];while(pending.length)for(const n of adj[pending.pop()])if(!seen.has(n)){seen.add(n);pending.push(n);}
 assert.equal(seen.size,adj.length,'disconnected mesh');
 const bounds=[0,1,2].map(a=>[Math.min(...v.map(p=>p[a])),Math.max(...v.map(p=>p[a]))]);
 assert.ok(Math.abs(bounds[2][0])<1e-5);assert.ok(bounds.every(([a,b])=>b-a<=300));
 results.push({file,sha256:crypto.createHash('sha256').update(raw).digest('hex'),closed:true,connected:true,bounds_mm:bounds,solid_PETG_g:Math.abs(volume)*.00127});
}
for(const kind of ['upper','lower']) {
 const key=p=>p.map(n=>Math.round(n*1000)).join(',');
 const a=new Set(vertices[`prototype-pitch-fork-${kind}.stl`].map(p=>key([p[0],-p[1],p[2]])));
 const b=new Set(vertices[`prototype-pitch-fork-${kind}-mirrored.stl`].map(key));
 assert.equal(a.size,b.size);for(const k of a)assert.ok(b.has(k),'opposite print mismatch');
 const local=vertices[`prototype-pitch-fork-${kind}.stl`].map(p=>[p[0],p[2]-16,-p[1]]);
 const paths=[{p:[0,0,49],length:7},{p:[0,0,-24],length:9}];
 for(const [x,y] of [[9,0],[-9,0],[0,9],[0,-9]])paths.push({p:[x,y,49],length:7});
 for(const y of [-4,4])paths.push({p:[kind==='upper'?-48:-76,y,49],length:7});
 for(const y of [-11,11])paths.push({p:[0,y,-24],length:9});
 for(const [x,y] of [[6,0],[-6,0],[0,6],[0,-6]])paths.push({p:[x,y,-23.1],length:5});
 for(const {p,length} of paths)for(let i=0;i<local.length;i+=3)assert.ok(!hit(p,...local.slice(i,i+3),length),'blocked retained interface');
}
const old=JSON.parse(fs.readFileSync(new URL('robot-working-mass-check.json',root)));
const mass=file=>old.prints.find(p=>p.file===file).solid_unit_g;
const upper=old.prints.find(p=>p.file.includes('upper-leg') && !p.file.includes('saddle')).solid_unit_g;
const oldSolid=4*(upper+mass('prototype-lower-leg.stl')+2*mass('hobby-joint-rear-arm.stl')+2*mass('hobby-joint-bridge.stl'));
const newSolid=4*(results[0].solid_PETG_g+results[2].solid_PETG_g);
const fastener=item=>old.fasteners.find(p=>p.item===item).unit_g_estimated;
const removedHardware=16*(fastener('M3x90')+fastener('M3 nuts'))+32*fastener('M3 ordinary washers');
const reduction=(oldSolid-newSolid)*.65+removedHardware;
const clearance=JSON.parse(fs.readFileSync(new URL('pitch-fork-clearance-check.json',root)));
assert.equal(clearance.checks.length,6);assert.ok(clearance.checks.every(p=>p.intersection_empty));
const report={stage:'experimental fork CAD; not released',meshes:results,opposite_print_correspondence_mm:.001,retained_interface_mesh_rays:true,placement:'Local viewer uses T(0,-16,0)*Rx(-90), a proper rotation. Reflected pitch frame requires opposite physical prints; assembly integration remains deferred.',clearance,
 comparison:{old_fork_solid_g:oldSolid,new_fork_solid_g:newSolid,removed_hardware_estimated_g:removedHardware,material_fraction_assumed:.65,total_estimated_reduction_g:reduction,variant_estimated_robot_g:old.estimated_complete_g-reduction,printed_pieces:101,removed:{M3x90:16,M3_nuts:16,M3_ordinary_washers:32}},physical_fit_verified:false,print_verified:false};
fs.writeFileSync(new URL('prototype-pitch-fork-check.json',root),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(report,null,2));
