import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import assert from 'node:assert/strict';
const here=path.dirname(fileURLToPath(import.meta.url));
const hash=file=>createHash('sha256').update(fs.readFileSync(path.join(here,file))).digest('hex').toUpperCase();
const plan=JSON.parse(fs.readFileSync(path.join(here,'four-leg-working-print-manifest.json'),'utf8'));
for(const p of plan.parts)assert.equal(hash(path.basename(p.file)),p.sha256,'stale working mesh');
const correspondence=JSON.parse(fs.readFileSync(path.join(here,'handed-correspondence-check.json'),'utf8'));
for(const [file,digest]of Object.entries(correspondence.dependency_sha256))assert.equal(hash(file),digest,'stale source correspondence');
const local=m=>m.map((row,i)=>row.map((n,j)=>j===3&&i<3?n-[75,55,120][i]:n));
const printed=plan.placements.filter(p=>p.role.startsWith('front-left ')&&!p.role.includes('chassis mount')).map(p=>({...p,role:p.role.replace('front-left ',''),matrix:local(p.matrix)}));
printed.push({role:'Bench adapter',file:'prototype-bench-base.stl',matrix:[[0,0,1,-10],[1,0,0,10.35],[0,1,0,0],[0,0,0,1]]});
const servos=plan.servo_case_placements.filter(p=>p.role.startsWith('front-left ')).map(p=>({...p,role:p.role.replace('front-left ',''),matrix:local(p.matrix)}));
assert.equal(printed.length,29);assert.equal(servos.length,3);
for(const p of [...printed,...servos]) {
 const m=p.matrix;
 const d=m[0][0]*(m[1][1]*m[2][2]-m[1][2]*m[2][1])-m[0][1]*(m[1][0]*m[2][2]-m[1][2]*m[2][0])+m[0][2]*(m[1][0]*m[2][1]-m[1][1]*m[2][0]);
 assert.ok(Math.abs(d-1)<1e-8);
 for(let a=0;a<3;a++)for(let b=0;b<3;b++)assert.ok(Math.abs(m.slice(0,3).reduce((s,row)=>s+row[a]*row[b],0)-(a===b?1:0))<1e-8);
}
const counts=new Map();for(const p of printed)counts.set(p.file,(counts.get(p.file)||0)+1);
assert.equal(counts.size,18);
const parts=[...counts].map(([file,quantity])=>({file:'mechanical/'+file,quantity,fixture_only:file==='prototype-bench-base.stl',sha256:hash(file)}));
let cad='// Generated physically placeable bench geometry, MEC-159.\nmodule rigid_bench(mesh_dir=".") {\n';
for(const p of printed)cad+=` multmatrix(${JSON.stringify(p.matrix)}) color("${p.role==='Bench adapter'?'gray':p.role.includes('Lower')?'seagreen':p.role.includes('upper')?'royalblue':'gold'}") import(str(mesh_dir,"/${p.file}")); // ${p.role}\n`;
for(const p of servos)cad+=` multmatrix(${JSON.stringify(p.matrix)}) color("dimgray") translate([-10,-9.85,3]) cube([40.7,19.7,42.9]); // ${p.role}\n`;
cad+='}\n';
function write(name,text){const file=path.join(here,name);if(!fs.existsSync(file)||fs.readFileSync(file,'utf8')!==text)fs.writeFileSync(file,text);}
write('rigid-bench-parts.scad',cad);
write('prototype-rigid-bench-assembly.scad','use <rigid-bench-parts.scad>\nrigid_bench();\n');
write('prototype-rigid-bench-pack-assembly.scad','// Self-contained manufacturing entry point; copied to manufacturing/cad.\nuse <rigid-bench-parts.scad>\nrigid_bench("../stl");\n');
const report={revision:'three-dof-bench-3',proper_printed_poses:29,proper_servo_poses:3,physical_fit_verified:false,parts,placements:printed,servo_case_placements:servos,source_correspondence:correspondence.results,assembly_sha256:hash('rigid-bench-parts.scad')};
report.new_mesh_checks=plan.new_mesh_checks;
write('rigid-bench-check.json',JSON.stringify(report,null,2)+'\n');
console.log('PASS: 18 unique bench STLs/29 printed pieces and three servo cases, all with proper rigid poses.');
