import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import test from 'node:test';
import assert from 'node:assert/strict';
import {verifyArtifacts} from './verify-st3215-artifacts.mjs';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const read=file=>fs.readFileSync(path.join(root,file));
function changed(file){return name=>name===file?Buffer.concat([read(name),Buffer.from('\nchanged')]):read(name);}
function changedReport(edit){
 const report=JSON.parse(read('mechanical/st3215-leg-check.json'));
 edit(report);
 return name=>name==='mechanical/st3215-leg-check.json'?Buffer.from(JSON.stringify(report)):read(name);
}
test('current evidence passes without writes',()=>assert.match(verifyArtifacts(read),/^PASS/));
for(const file of ['mechanical/st3215-leg.scad','mechanical/st3215-battery-tray.scad','mechanical/check-st3215-leg.mjs','mechanical/st3215-upper.stl','mechanical/st3215-shim-rear.stl','mechanical/st3215-clamp-fit29-top.stl','mechanical/st3215-battery-tray.stl']){
 test(`reject changed ${file}`,()=>assert.throws(()=>verifyArtifacts(changed(file)),/Stale validation/));
}
test('reject absent tray provenance',()=>assert.throws(()=>verifyArtifacts(changedReport(r=>delete r.tray_source_sha256)),/Missing\/invalid hash/));
test('reject missing part',()=>assert.throws(()=>verifyArtifacts(changedReport(r=>r.parts.pop())),/Incomplete part manifest/));
test('reject duplicated part',()=>assert.throws(()=>verifyArtifacts(changedReport(r=>r.parts[1]=r.parts[0])),/Duplicate part/));
test('reject wrong print quantity',()=>assert.throws(()=>verifyArtifacts(changedReport(r=>r.parts[0].quantity=99)),/Wrong print quantity/));
test('reject redirected path',()=>assert.throws(()=>verifyArtifacts(changedReport(r=>r.parts[0].file='../other.stl')),/Unexpected artifact path/));
test('reject obsolete schema',()=>assert.throws(()=>verifyArtifacts(changedReport(r=>r.schema_version=1)),/Validation schema/));
