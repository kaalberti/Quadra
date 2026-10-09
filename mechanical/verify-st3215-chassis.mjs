import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {verifyArtifacts} from './verify-st3215-artifacts.mjs';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const inputs=['mechanical/st3215-chassis.scad','mechanical/st3215-leg.scad','mechanical/st3215-battery-tray.stl','mechanical/st3215-hip.stl','mechanical/st3215-mount.stl','mechanical/st3215-leg-check.json','mechanical/check-st3215-chassis.mjs'];
export function verifyChassis(read=file=>fs.readFileSync(path.join(root,file))){
 const report=JSON.parse(read('mechanical/st3215-chassis-check.json').toString('utf8'));
 const match=(file,value)=>{assert.match(value??'',/^[a-f0-9]{64}$/);assert.equal(createHash('sha256').update(read(file)).digest('hex'),value,`Stale chassis evidence: ${file}`);};
 assert.deepEqual(Object.keys(report.inputs_sha256).sort(),[...inputs].sort());
 for(const file of inputs)match(file,report.inputs_sha256[file]);
 assert.equal(report.parts.length,3);
 for(const [part,quantity] of [['body',1],['deck',1],['riser',4]]){
  const row=report.parts.find(r=>r.part===part);assert(row);assert.equal(row.quantity,quantity);
  assert.equal(row.file,`mechanical/st3215-chassis-${part}.stl`);match(row.file,row.sha256);
 }
 assert.equal(report.physical_fit_verified,false);assert.equal(report.loaded_range_released,false);
 return 'PASS: chassis inputs and three print meshes match the recorded checks. Physical fit and loaded motion remain unverified.';
}
if(process.argv[1] && path.resolve(process.argv[1])===fileURLToPath(import.meta.url)){
 try{console.log(verifyArtifacts());console.log(verifyChassis());}catch(error){console.error(error.message);process.exitCode=1;}
}
