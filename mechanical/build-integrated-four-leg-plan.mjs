import fs from 'node:fs';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {closedMesh} from './mesh-check.mjs';
const root=new URL('./',import.meta.url),read=f=>JSON.parse(fs.readFileSync(new URL(f,root))),sha=f=>createHash('sha256').update(fs.readFileSync(new URL(f,root))).digest('hex').toUpperCase();
const old=read('four-leg-working-print-manifest.json');for(const p of old.parts)assert.equal(sha(p.file.replace('mechanical/','')),p.sha256);
const hip=read('integrated-hip-clearance-check.json');for(const [f,h] of Object.entries(hip.input_sha256))assert.equal(sha(f),h.toUpperCase());
assert.equal(sha('prototype-integrated-hip-mirrored.stl'),hip.mirrored_mesh.sha256.toUpperCase());
const forks=read('fork-leg-placement.json').forks;
const I=[[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]],S=[[1,0,0,0],[0,-1,0,0],[0,0,1,0],[0,0,0,1]];
const mul=(a,b)=>a.map(row=>b[0].map((_,j)=>row.reduce((s,n,k)=>s+n*b[k][j],0))),chain=(...m)=>m.reduce(mul,I);
const T=(x,y,z)=>[[1,0,0,x],[0,1,0,y],[0,0,1,z],[0,0,0,1]];
const rx90=[[1,0,0,0],[0,0,-1,0],[0,1,0,0],[0,0,0,1]],rxMinus90=[[1,0,0,0],[0,0,1,0],[0,-1,0,0],[0,0,0,1]];
const remove=new Set(['J1 front arm','J1 rear arm','J1 carrier','J2 upper plate','J2 rear arm','J2 bridge','Lower plate','Knee rear arm','Knee bridge']);
const placements=old.placements.filter(p=>!remove.has(p.role.replace(/^(front|rear)-(left|right) /,'')));
assert.equal(placements.length,81);
const additions=[];
for(const [name,f,s] of [['front-left',1,1],['front-right',1,-1],['rear-left',-1,1],['rear-right',-1,-1]]){
 const reflected=f*s<0,frame=[[f,0,0,f*75],[0,s,0,s*55],[0,0,1,120],[0,0,0,1]];
 const hipMatrix=reflected?chain(frame,S,rx90,T(0,0,-28)):chain(frame,rxMinus90,T(0,0,-28));
 additions.push({role:`${name} integrated hip`,file:`prototype-integrated-hip${reflected?'-mirrored':''}.stl`,matrix:hipMatrix,leg_frame:frame,family:'hip'});
 // Bench pitch poses use mirrored prints. An improper body-side frame switches
 // to the original physical print; My in PRINT coordinates relates the variants.
 for(const fork of forks){const file=reflected?fork.file.replace('-mirrored',''):fork.file;const m=reflected?chain(frame,fork.matrix,S):chain(frame,fork.matrix);additions.push({role:`${name} ${fork.role}`,file,matrix:m,leg_frame:frame,family:fork.role==='Upper fork'?'upper':'lower'});}
}
placements.push(...additions);assert.equal(placements.length,93);
for(const p of [...placements,...old.servo_case_placements]){const m=p.matrix,det=m[0][0]*(m[1][1]*m[2][2]-m[1][2]*m[2][1])-m[0][1]*(m[1][0]*m[2][2]-m[1][2]*m[2][0])+m[0][2]*(m[1][0]*m[2][1]-m[1][1]*m[2][0]);assert.ok(Math.abs(det-1)<1e-8,p.role);for(let a=0;a<3;a++)for(let b=0;b<3;b++)assert.ok(Math.abs(m.slice(0,3).reduce((sum,row)=>sum+row[a]*row[b],0)-(a===b?1:0))<1e-8);}
const counts=new Map();for(const p of placements)counts.set(p.file,(counts.get(p.file)||0)+1);
assert.equal(counts.size,21);const parts=[...counts].map(([file,quantity])=>({file:'mechanical/'+file,quantity,sha256:sha(file)}));
const mesh_checks=[];for(const p of parts){const file=p.file.replace('mechanical/',''),m=closedMesh(new URL(file,root));assert.ok(Math.abs(m.bounds[2][0])<1e-5&&m.size.every(n=>n<=300));mesh_checks.push({file,closed:true,connected:true,size_mm:m.size,solid_volume_mm3:m.volume});}
const plan={revision:'integrated-four-leg-1',scope:'Experimental nominal physical assembly; not manufacturing release',physical_fit_verified:false,printed_pieces:93,parts,placements,servo_case_placements:old.servo_case_placements,new_placements:additions,mesh_checks};
fs.writeFileSync(new URL('integrated-four-leg-print-manifest.json',root),JSON.stringify(plan,null,2)+'\n');
let cad='// MEC-165 generated physical integrated assembly.\nmodule integrated_robot(){\n';
for(const p of placements)cad+=`multmatrix(${JSON.stringify(p.matrix)}) color("${p.family==='hip'?'mediumorchid':p.family?'royalblue':'gold'}") import("${p.file}"); // ${p.role}\n`;
for(const p of old.servo_case_placements)cad+=`multmatrix(${JSON.stringify(p.matrix)}) color([.25,.25,.25,.6]) translate([-10,-9.85,3]) cube([40.7,19.7,42.9]);\n`;
cad+='}\nmodule new_integrated_parts(){\n';for(const p of additions)cad+=`multmatrix(${JSON.stringify(p.matrix)}) import("${p.file}");\n`;cad+='}\nmodule existing_chassis(){\n';for(const p of placements.filter(p=>/chassis mount|deck/i.test(p.role)))cad+=`multmatrix(${JSON.stringify(p.matrix)}) import("${p.file}");\n`;cad+='}\n';
fs.writeFileSync(new URL('integrated-four-leg-parts.scad',root),cad);
fs.writeFileSync(new URL('prototype-integrated-four-leg-assembly.scad',root),'use <integrated-four-leg-parts.scad>\nintegrated_robot();\n');
const input=read('robot-mass-inputs.json');input.scope='Experimental integrated four-leg BOM; excludes bench fixture';input.print_unit_inputs=Object.fromEntries(parts.map(p=>{const name=p.file.replace('mechanical/','');return [name,input.print_unit_inputs[name]??{slicer_unit_g:null,measured_unit_g:null}];}));
const inputFile=new URL('integrated-robot-mass-inputs.json',root);if(!fs.existsSync(inputFile))fs.writeFileSync(inputFile,JSON.stringify(input,null,2)+'\n');
console.log('PASS: 93 pieces/21 unique closed connected bed-sized STLs, proper printed/servo poses.');
