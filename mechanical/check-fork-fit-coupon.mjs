import fs from 'node:fs';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const root=new URL('./',import.meta.url),file='prototype-fork-fit-coupon.stl',raw=fs.readFileSync(new URL(file,root));
const v=[...raw.toString().matchAll(/vertex\s+([-+\d.eE]+)\s+([-+\d.eE]+)\s+([-+\d.eE]+)/g)].map(m=>m.slice(1).map(Number));
assert.ok(v.length>0 && v.length%3===0 && v.flat().every(Number.isFinite));
const edges=new Map(),adj=Array.from({length:v.length/3},()=>[]);let volume=0;
for(let i=0;i<v.length;i+=3){const [a,b,c]=v.slice(i,i+3),keys=[a,b,c].map(p=>p.join(','));assert.equal(new Set(keys).size,3);for(const [j,k] of [[0,1],[1,2],[2,0]]){const key=[keys[j],keys[k]].sort().join('|');if(!edges.has(key))edges.set(key,[]);edges.get(key).push(i/3);}volume+=(a[0]*(b[1]*c[2]-b[2]*c[1])+a[1]*(b[2]*c[0]-b[0]*c[2])+a[2]*(b[0]*c[1]-b[1]*c[0]))/6;}
for(const owners of edges.values()){assert.equal(owners.length,2,'open/nonmanifold edge');adj[owners[0]].push(owners[1]);adj[owners[1]].push(owners[0]);}
const seen=new Set([0]),pending=[0];while(pending.length)for(const n of adj[pending.pop()])if(!seen.has(n)){seen.add(n);pending.push(n);}assert.equal(seen.size,adj.length,'disconnected coupon');
const bounds=[0,1,2].map(a=>[Math.min(...v.map(p=>p[a])),Math.max(...v.map(p=>p[a]))]),size=bounds.map(([a,b])=>b-a);
assert.ok(Math.abs(bounds[2][0])<1e-5);assert.ok(size.every(n=>n<=300));
const local=v.map(p=>[p[0],p[2]-16,-p[1]]);
const sub=(a,b)=>a.map((n,i)=>n-b[i]),dot=(a,b)=>a.reduce((s,n,i)=>s+n*b[i],0),cross=(a,b)=>[a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]];
function hit(p,a,b,c,length){const e1=sub(b,a),e2=sub(c,a),h=cross([0,0,1],e2),det=dot(e1,h);if(Math.abs(det)<1e-9)return false;const s=sub(p,a),q=cross(s,e1),u=dot(s,h)/det,w=dot([0,0,1],q)/det,t=dot(e2,q)/det;return u>=0&&w>=0&&u+w<=1&&t>1e-7&&t<length-1e-7;}
const ray=(p,len)=>local.some((_,i)=>i%3===0&&hit(p,...local.slice(i,i+3),len));
let checked=0;
function expect(p,len,blocked){assert.equal(ray(p,len),blocked,`interface ray ${p}`);checked++;}
for(const y of [-11,11])for(const x of [-1.5,0,1.5])expect([x,y,-24],9,false);
for(const y of [-11,11])expect([2,y,-24],9,true);
for(const [x,y] of [[9,0],[-9,0],[0,9],[0,-9]])expect([x,y,49],7,false);
for(const [x,y] of [[9,1],[-9,1],[1,9],[1,-9]])expect([x,y,49],7,false);
for(const [x,y] of [[9,1.5],[-9,1.5],[1.5,9],[1.5,-9]])expect([x,y,49],7,true);
expect([4.8,0,49],7,false);expect([5.2,0,49],7,true);
expect([6.5,0,-24],5.9,false);expect([6.8,0,-24],5.9,true);
expect([6.5,0,-24],6.5,true); // Counterbore floor, not a through13.2mm bore.
expect([3.8,0,-18],2,false);expect([4.2,0,-18],2,true);
const sources=['prototype-fork-fit-coupon.scad','prototype-pitch-fork.scad','prototype-upper-leg.scad','prototype-lower-leg.scad','hobby-joint-rear-arm.scad','hobby-joint-common.scad'];
const source_sha256=Object.fromEntries(sources.map(f=>[f,createHash('sha256').update(fs.readFileSync(new URL(f,root))).digest('hex')]));
const report={file,sha256:createHash('sha256').update(raw).digest('hex'),source_sha256,closed:true,connected:true,bed_origin:true,size_mm:size,solid_PETG_g:Math.abs(volume)*.00127,interface_ray_checks:checked,seat_nominal_mm:{diameter:13.2,depth:5.2},horn_bore_mm:10,retainer_hole_pitch_mm:22,print_performed:false,fit_performed:false,strength_test_coupon:false};
fs.writeFileSync(new URL('fork-fit-coupon-check.json',root),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report,null,2));
