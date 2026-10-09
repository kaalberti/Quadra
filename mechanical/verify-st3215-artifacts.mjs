import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';

const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const quantities={'clamp-bottom':3,'clamp-top':3,upper:1,lower:1,hip:1,mount:1,shims:6};
export function verifyArtifacts(readFile=file=>fs.readFileSync(path.join(root,file))) {
 const report=JSON.parse(readFile('mechanical/st3215-leg-check.json').toString('utf8'));
 const hash=file=>createHash('sha256').update(readFile(file)).digest('hex');
 const match=(file,expected)=>{
  assert.match(expected??'',/^[a-f0-9]{64}$/,`Missing/invalid hash: ${file}`);
  assert.equal(hash(file),expected,`Stale validation: ${file}; rerun check-st3215-leg.mjs`);
 };
 assert.equal(report.schema_version,2,'Validation schema must be 2; regenerate evidence');
 match('mechanical/st3215-leg.scad',report.source_sha256);
 match('mechanical/st3215-battery-tray.scad',report.tray_source_sha256);
 match('mechanical/check-st3215-leg.mjs',report.checker_sha256);
 assert.equal(report.parts.length,Object.keys(quantities).length,'Incomplete part manifest');
 assert.equal(new Set(report.parts.map(row=>row.part)).size,report.parts.length,'Duplicate part');
 for(const [part,quantity] of Object.entries(quantities)){
  const row=report.parts.find(row=>row.part===part);
  assert(row,`Missing part: ${part}`);
  const file=`mechanical/st3215-${part}.stl`;
  assert.equal(row.file,file,'Unexpected artifact path');
  assert.equal(row.quantity,quantity,`Wrong print quantity: ${part}`);
  match(file,row.sha256);
 }
 match('mechanical/st3215-battery-tray.stl',report.battery_tray.sha256);
 assert.equal(report.print_pieces,16);
 assert.equal(report.physical_fit_verified,false,'Physical qualification requires a separate release workflow');
 assert.equal(report.battery_tray.physical_fit_verified,false);
 assert.equal(report.battery_mount_released,false);
 return 'PASS: current CAD sources, generator and eight STL hashes match the complete report. Physical fit remains unverified.';
}
if(process.argv[1] && path.resolve(process.argv[1])===fileURLToPath(import.meta.url)){
 try { console.log(verifyArtifacts()); }
 catch(error){console.error(error.message);process.exitCode=1;}
}
