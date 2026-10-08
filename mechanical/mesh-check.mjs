import fs from 'node:fs';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
export const sub=(a,b)=>a.map((n,i)=>n-b[i]);
export const dot=(a,b)=>a.reduce((s,n,i)=>s+n*b[i],0);
export const cross=(a,b)=>[a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]];
export function closedMesh(file) {
 const raw=fs.readFileSync(file),v=[...raw.toString().matchAll(/vertex\s+([-+\d.eE]+)\s+([-+\d.eE]+)\s+([-+\d.eE]+)/g)].map(m=>m.slice(1).map(Number));
 assert.ok(v.length>0 && v.length%3===0 && v.flat().every(Number.isFinite));
 const edges=new Map(),adj=Array.from({length:v.length/3},()=>[]);let volume=0;
 for(let i=0;i<v.length;i+=3){const [a,b,c]=v.slice(i,i+3),keys=[a,b,c].map(p=>p.join(','));assert.equal(new Set(keys).size,3);for(const [j,k] of [[0,1],[1,2],[2,0]]){const key=[keys[j],keys[k]].sort().join('|');if(!edges.has(key))edges.set(key,[]);edges.get(key).push(i/3);}volume+=dot(a,cross(b,c))/6;}
 for(const owners of edges.values()){assert.equal(owners.length,2,'open/nonmanifold edge');adj[owners[0]].push(owners[1]);adj[owners[1]].push(owners[0]);}
 const seen=new Set([0]),pending=[0];while(pending.length)for(const n of adj[pending.pop()])if(!seen.has(n)){seen.add(n);pending.push(n);}assert.equal(seen.size,adj.length,'disconnected mesh');
 const bounds=[0,1,2].map(a=>[Math.min(...v.map(p=>p[a])),Math.max(...v.map(p=>p[a]))]);
 assert.ok(Math.abs(volume)>1e-5);
 return {v,bounds,size:bounds.map(([a,b])=>b-a),volume:Math.abs(volume),sha256:createHash('sha256').update(raw).digest('hex')};
}
export function rayCrosses(v,p,direction,length) {
 for(let i=0;i<v.length;i+=3){const [a,b,c]=v.slice(i,i+3),e1=sub(b,a),e2=sub(c,a),h=cross(direction,e2),det=dot(e1,h);if(Math.abs(det)<1e-9)continue;const s=sub(p,a),q=cross(s,e1),u=dot(s,h)/det,w=dot(direction,q)/det,t=dot(e2,q)/det;if(u>=0&&w>=0&&u+w<=1&&t>1e-7&&t<length-1e-7)return true;}return false;
}
