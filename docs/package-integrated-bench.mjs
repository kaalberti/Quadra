import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {closedMesh} from '../mechanical/mesh-check.mjs';
const repo=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const at=p=>path.join(repo,p), read=p=>JSON.parse(fs.readFileSync(at(p))), hash=p=>createHash('sha256').update(fs.readFileSync(at(p))).digest('hex').toUpperCase();
const json=(p,v)=>fs.writeFileSync(at(p),JSON.stringify(v,null,2)+'\n');
const pending='manufacturing-pending-MFG-003';
assert(!fs.existsSync(at(pending)),'Pending pack already exists; inspect instead of overwriting');
const old=read('manufacturing/release-manifest.json');assert.equal(old.revision,'three-dof-bench-3');
for(const f of old.files)assert.equal(hash('manufacturing/'+f.file),f.sha256);
const fork=read('mechanical/fork-leg-placement.json');
const removed=new Set(['J1 front arm','J1 rear arm','J1 carrier']);
const placements=fork.placements.filter(p=>!removed.has(p.role));
placements.push({role:'Integrated hip',file:'prototype-integrated-hip.stl',matrix:[[1,0,0,0],[0,0,1,-28],[0,-1,0,0],[0,0,0,1]]});
assert.equal(placements.length,23);
const counts=new Map();for(const p of placements)counts.set(p.file,(counts.get(p.file)||0)+1);
const parts=[];
for(const [file,quantity] of counts){
 const previous=old.parts.find(p=>p.file==='stl/'+file);
 const p=previous?{...previous,quantity}:{file:'stl/'+file,quantity,fixture_only:false,fit_coupon:false,cad:'cad/'+(file.includes('hip')?'prototype-integrated-hip.scad':'prototype-pitch-fork.scad'),selector:null};
 if(file.includes('pitch-fork'))p.defines={part:file.includes('upper')?'upper':'lower',hand:-1,view:'print'};
 if(file==='prototype-integrated-hip.stl')p.defines={hand:1,view:'print'};
 p.sha256=hash('mechanical/'+file);parts.push(p);
}
assert.equal(parts.length,15);
parts.push(...old.parts.filter(p=>p.fit_coupon).map(p=>({...p})));
parts.push({file:'coupons/prototype-fork-fit-coupon.stl',quantity:1,fixture_only:false,fit_coupon:true,cad:'cad/prototype-fork-fit-coupon.scad',selector:null,sha256:hash('mechanical/prototype-fork-fit-coupon.stl')});
function couponMesh(file){
 const raw=fs.readFileSync(file),v=[...raw.toString().matchAll(/vertex\s+([-+\d.eE]+)\s+([-+\d.eE]+)\s+([-+\d.eE]+)/g)].map(m=>m.slice(1).map(Number));assert(v.length&&v.length%3===0&&v.flat().every(Number.isFinite));
 const edges=new Map();for(let i=0;i<v.length;i+=3){const k=v.slice(i,i+3).map(p=>p.join(','));for(const [a,b] of [[0,1],[1,2],[2,0]]){const e=[k[a],k[b]].sort().join('|');edges.set(e,(edges.get(e)||0)+1);}}assert([...edges.values()].every(n=>n===2),'open coupon surface');
 const bounds=[0,1,2].map(a=>[Math.min(...v.map(p=>p[a])),Math.max(...v.map(p=>p[a]))]);return {bounds,size:bounds.map(([a,b])=>b-a)};
}
const meshes=[];for(const p of parts){const m=p.fit_coupon?couponMesh(at('mechanical/'+path.basename(p.file))):closedMesh(at('mechanical/'+path.basename(p.file)));assert(Math.abs(m.bounds[2][0])<1e-5 && m.size.every(n=>n<=300));meshes.push({file:p.file,closed:true,connected:p.fit_coupon?null:true,on_bed:true,size_mm:m.size,sha256:p.sha256});}
const hardware=read('mechanical/three-dof-hardware.json');hardware.scope='One experimental integrated3DOF bench leg; physical fit/load NOT_PERFORMED';
hardware.M3_fastener_roles=hardware.M3_fastener_roles.filter(r=>!['two joint bridges','J1 carrier end tabs'].includes(r.role));hardware.M3_nuts-=8;hardware.M3_normal_washers-=16;assert.equal(hardware.M3_fastener_roles.reduce((n,r)=>n+r.quantity,0),27);
json('mechanical/integrated-bench-hardware.json',hardware);
let cad='// MFG-003 nominal physical bench assembly; proper rigid poses.\n';
cad+='module integrated_bench_parts(mesh_dir="."){\n';
for(const p of placements)cad+=`multmatrix(${JSON.stringify(p.matrix)}) color("${p.role==='Integrated hip'?'mediumorchid':p.role.includes('fork')?'royalblue':'gold'}") import(str(mesh_dir,"/${p.file}")); // ${p.role}\n`;
for(const p of fork.servo_case_placements)cad+=`multmatrix(${JSON.stringify(p.matrix)}) color([.25,.25,.25,.6]) translate([-10,-9.85,3]) cube([40.7,19.7,42.9]); // ${p.role} case\n`;
cad+='}\n';fs.writeFileSync(at('mechanical/integrated-bench-parts.scad'),cad);
fs.writeFileSync(at('mechanical/prototype-integrated-bench-pack-assembly.scad'),'use <integrated-bench-parts.scad>\nintegrated_bench_parts("../stl");\n');
json('mechanical/integrated-bench-print-manifest.json',{revision:'integrated-bench-1',printed_pieces:23,parts,placements,servo_case_placements:fork.servo_case_placements,physical_fit_verified:false});
for(const d of ['cad','stl','coupons','docs'])fs.mkdirSync(at(pending+'/'+d),{recursive:true});
for(const p of parts)fs.copyFileSync(at('mechanical/'+path.basename(p.file)),at(pending+'/'+p.file));
const queue=['prototype-integrated-bench-pack-assembly.scad',...parts.map(p=>path.basename(p.cad))],seen=new Set();
while(queue.length){const name=queue.shift();if(seen.has(name))continue;seen.add(name);assert.equal(path.basename(name),name);const source=at('mechanical/'+name);fs.copyFileSync(source,at(pending+'/cad/'+name));for(const m of fs.readFileSync(source,'utf8').matchAll(/(?:use|include)\s*<([^>]+)>/g))queue.push(m[1]);}
json(pending+'/bom-hardware.json',hardware);
json(pending+'/layout.json',{revision:'integrated-bench-1',nominal_angles_deg:[0,44.0486,78.9786],pitch_datum_mm:[85,-18,0],links_mm:[70,85],foot_reference_mm:[85,32,-120],trial_envelope_deg:{J1:[-25,30],J2:[20,55],J3:[60,90]},loaded_ranges_approved:false});
for(const [source,target] of [['docs/integrated-leg-build.md','docs/assembly.md'],['docs/integrated-leg-printing.md','docs/printing.md'],['docs/fork-fit-coupon.md','docs/fork-fit-coupon.md']]){let text=fs.readFileSync(at(source),'utf8').replace('(../mechanical/prototype-integrated-hip-assembly.png)','(assembly.png)').replace('(integrated-leg-printing.md)','(printing.md)').replace('(../manufacturing/BOM.md)','(../BOM.md)').replace('(../manufacturing/docs/print-list.md)','(print-list.md)');if(source.endsWith('fork-fit-coupon.md'))text=text.replace('mechanical/prototype-fork-fit-coupon.stl','../coupons/prototype-fork-fit-coupon.stl').replace('and the supported manufacturing kit stays\nunchanged.','and the bench-3 fallback remains archived intact.');fs.writeFileSync(at(pending+'/'+target),text);}
fs.copyFileSync(at('mechanical/prototype-integrated-hip-assembly.png'),at(pending+'/docs/assembly.png'));
let list='# Print list — integrated-bench-1\n\n15 unique assembly STLs/23 pieces; five optional fit coupons. Print coupons before full parts.\n\n| File | Qty | Use |\n| --- | ---: | --- |\n';for(const p of parts)list+=`| [${path.basename(p.file)}](../${p.file}) | ${p.quantity} | ${p.fit_coupon?'Fit coupon':p.fixture_only?'Bench adapter':'Leg'} |\n`;fs.writeFileSync(at(pending+'/docs/print-list.md'),list);
let bom='# Buying BOM — one integrated bench leg\n\nProvisional MG996R fit; buy/test one servo before ordering all12. Use supplied horns and original centre screws. Owned ESP32-S3/PCA9685 boards need no replacements.\n\n| Item | Qty |\n| --- | ---: |\n| MG996R positional servo/horn/centre screw | 3 |\n| 624 bearing,4 x13 x5mm nominal | 3 |\n';const lengths=new Map();for(const r of hardware.M3_fastener_roles)lengths.set(r.length_mm,(lengths.get(r.length_mm)||0)+r.quantity);for(const [n,q] of lengths)bom+=`| M3 x${n} through bolt | ${q} |\n`;bom+='| M3 nut | 27 |\n| M3 ordinary flat washer | 53 |\n| M3 washer,12mm OD backing | 1 |\n| M4 x35 pivot / locknut / washer | 3 each |\n| M2 x10 horn bolt / nut / washer | Up to12 /12 /24 |\n| Rubber/EVA foot pad,18 x8 x1mm assumed | 1 |\n| Small cable tie | 4 |\n\nBench-only: two M4 anchors/nuts/washers and two40mm standoffs(max10mm OD); choose bolt length for the actual rigid vertical board. Reuse existing hardware packs. Prices are unverified; budget unchanged. No M3x90 bridge bolts or J1 tab bolts are needed.\n\nElectrical commissioning uses the separate bench wiring plan; never power servos through the controller boards. The adjustable60V/5A supply must be set near5.2V; its5A rating permits staged tests rather than the7.5A three-servo planning target. No robot battery/regulator purchase is selected here.\n';fs.writeFileSync(at(pending+'/BOM.md'),bom);
fs.writeFileSync(at(pending+'/README.md'),'# MFG-003 — integrated single-leg build checkpoint\n\nExperimental integrated-bench-1:23 printed assembly pieces, three MG996R candidates, five fit coupons. Physical fit/load/powered operation NOT_PERFORMED. This is a print and unpowered assembly checkpoint.\n\nStart with [printing](docs/printing.md), [print list](docs/print-list.md), [assembly](docs/assembly.md), and [buying BOM](BOM.md). Open cad/prototype-integrated-bench-pack-assembly.scad for the self-contained nominal assembly. Editable CAD and all imported STLs are included; OpenSCAD is not bundled.\n\nOriginal integrated hip, mirrored upper/lower pitch forks and mirrored knee saddle are deliberate physical print hands. Bearings, horns and fasteners are described in the guide but not all drawn. The previous bench-3 pack is preserved under ARCHIVE/MFG-002-three-dof-bench-3 in the repository. Complete robot2kg compliance is not established.\n');
json(pending+'/validation.json',{revision:'integrated-bench-1',meshes,placements,servo_case_placements:fork.servo_case_placements,physical_fit_verified:false,evidence:{hip:read('mechanical/integrated-hip-clearance-check.json'),fork:read('mechanical/fork-leg-check.json'),coupon:read('mechanical/fork-fit-coupon-check.json')}});
const files=[];function walk(dir){for(const f of fs.readdirSync(at(dir),{withFileTypes:true})){const p=dir+'/'+f.name;if(f.isDirectory())walk(p);else files.push({file:p.slice(pending.length+1),sha256:hash(p)});}}walk(pending);
json(pending+'/release-manifest.json',{pack_revision:'MFG-003',revision:'integrated-bench-1',date:'2026-10-09',parts,files,physical_fit_verified:false});
console.log('Prepared pending integrated pack; current manufacturing remains intact.');