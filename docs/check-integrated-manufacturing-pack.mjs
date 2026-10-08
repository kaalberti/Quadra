import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {closedMesh} from '../mechanical/mesh-check.mjs';
const repo=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const pack=path.resolve(repo,process.argv[2]||'manufacturing');assert(pack.startsWith(repo+path.sep),'pack outside repo');
const read=p=>JSON.parse(fs.readFileSync(p));const sha=p=>createHash('sha256').update(fs.readFileSync(p)).digest('hex').toUpperCase();
const manifest=read(path.join(pack,'release-manifest.json'));assert.equal(manifest.pack_revision,'MFG-003');assert.equal(manifest.physical_fit_verified,false);
const actual=[];function walk(p){for(const f of fs.readdirSync(p,{withFileTypes:true})){const n=path.join(p,f.name);if(f.isDirectory())walk(n);else actual.push(path.relative(pack,n).replaceAll('\\','/'));}}walk(pack);
assert.deepEqual(actual.sort(),['release-manifest.json',...manifest.files.map(p=>p.file)].sort());
for(const f of manifest.files)assert.equal(sha(path.join(pack,f.file)),f.sha256,f.file);
const prints=manifest.parts.filter(p=>!p.fit_coupon),coupons=manifest.parts.filter(p=>p.fit_coupon);assert.equal(prints.length,15);assert.equal(prints.reduce((n,p)=>n+p.quantity,0),23);assert.equal(coupons.length,5);
const baseline=read(path.join(repo,'mechanical/rigid-bench-check.json'));
const removed=new Set(['J1 front arm','J1 rear arm','J1 carrier','J2 upper plate','J2 rear arm','J2 bridge','Lower plate','Knee rear arm','Knee bridge']);
const expected=baseline.placements.filter(p=>!removed.has(p.role));
const forks=read(path.join(repo,'mechanical/fork-leg-placement.json')).forks;
expected.push(...forks,{role:'Integrated hip',file:'prototype-integrated-hip.stl',matrix:[[1,0,0,0],[0,0,1,-28],[0,-1,0,0],[0,0,0,1]]});
const validation=read(path.join(pack,'validation.json'));assert.equal(validation.physical_fit_verified,false);assert.equal(validation.placements.length,23);
const generated=fs.readFileSync(path.join(pack,'cad/integrated-bench-parts.scad'),'utf8');
const count=new Map();
function proper(m){const a=m.slice(0,3).map(r=>r.slice(0,3));const det=a[0][0]*(a[1][1]*a[2][2]-a[1][2]*a[2][1])-a[0][1]*(a[1][0]*a[2][2]-a[1][2]*a[2][0])+a[0][2]*(a[1][0]*a[2][1]-a[1][1]*a[2][0]);assert(Math.abs(det-1)<1e-8);for(let i=0;i<3;i++)for(let j=0;j<3;j++)assert(Math.abs(a[i].reduce((s,n,k)=>s+n*a[j][k],0)-(i===j?1:0))<1e-8);}
for(const p of expected){const matched=validation.placements.find(r=>r.role===p.role);assert.deepEqual(matched,p,p.role);proper(p.matrix);count.set(p.file,(count.get(p.file)||0)+1);const line=generated.split('\n').find(l=>l.endsWith('// '+p.role));assert(line && line.includes('multmatrix('+JSON.stringify(p.matrix)+')') && line.includes('import(str(mesh_dir,"/'+p.file+'"))'),'wrong paired print pose '+p.role);}
assert.equal([...generated.matchAll(/import\(str\(mesh_dir,/g)].length,23);
assert.deepEqual(validation.servo_case_placements,baseline.servo_case_placements);assert.equal(validation.servo_case_placements.length,3);validation.servo_case_placements.forEach(p=>proper(p.matrix));
for(const p of prints){const file=path.basename(p.file);assert.equal(count.get(file),p.quantity);assert.equal(sha(path.join(pack,p.file)),p.sha256);assert.equal(sha(path.join(repo,'mechanical',file)),p.sha256);const m=closedMesh(path.join(pack,p.file));assert(Math.abs(m.bounds[2][0])<1e-5&&m.size.every(n=>n<=300));}
for(const p of coupons)assert.equal(sha(path.join(pack,p.file)),p.sha256);
for(const p of fs.readdirSync(path.join(pack,'cad'))){const full=path.join(pack,'cad',p),text=fs.readFileSync(full,'utf8');assert.equal(text.replaceAll('\r\n','\n'),fs.readFileSync(path.join(repo,'mechanical',p),'utf8').replaceAll('\r\n','\n'),p);for(const m of text.matchAll(/(?:use|include)\s*<([^>]+)>/g))assert(fs.existsSync(path.join(pack,'cad',m[1])),'missing CAD dependency');}
for(const p of actual.filter(p=>p.endsWith('.md'))){const full=path.join(pack,p);for(const m of fs.readFileSync(full,'utf8').matchAll(/\]\(([^)]+)\)/g))if(!/^(https?:|#)/.test(m[1]))assert(fs.existsSync(path.resolve(path.dirname(full),m[1])),p+': broken link '+m[1]);}
const hardware=read(path.join(pack,'bom-hardware.json'));const old=read(path.join(repo,'mechanical/three-dof-hardware.json'));old.scope=hardware.scope;old.M3_fastener_roles=old.M3_fastener_roles.filter(r=>!['two joint bridges','J1 carrier end tabs'].includes(r.role));old.M3_nuts-=8;old.M3_normal_washers-=16;assert.deepEqual(hardware,old);assert.equal(hardware.M3_nuts,27);assert.equal(hardware.M3_normal_washers,53);assert.equal(hardware.M3_fastener_roles.reduce((n,r)=>n+r.quantity,0),27);
assert.deepEqual(hardware,read(path.join(repo,'mechanical/integrated-bench-hardware.json')));
for(const [name,field] of [['hip','input_sha256'],['fork','input_sha256'],['coupon','source_sha256']]){const e=validation.evidence[name];assert(e[field],'missing source bindings '+name);for(const [p,h] of Object.entries(e[field]))assert.equal(sha(path.join(repo,'mechanical',p)),h.toUpperCase(),'stale evidence '+p);}
assert.equal(validation.evidence.coupon.interface_ray_checks,27);assert.equal(sha(path.join(pack,'coupons/prototype-fork-fit-coupon.stl')),validation.evidence.coupon.sha256.toUpperCase());assert.equal(validation.evidence.hip.physical_fit_verified,false);
console.log(`PASS: ${actual.length} self-contained release files;15 assembly STLs/23 proper placements/3 proper servo poses;five coupons;hashes,CAD dependencies,links,27-bolt BOM and source-bound sampled evidence.`);