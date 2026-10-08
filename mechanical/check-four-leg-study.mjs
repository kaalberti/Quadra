import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import path from 'node:path';
import assert from 'node:assert/strict';
import fs from 'node:fs';
const here=path.dirname(fileURLToPath(import.meta.url));
const cad=path.join(here,'prototype-four-leg-study.scad');
const scad=fs.readFileSync(cad,'utf8');
const value=name=>Number(scad.match(new RegExp(`${name}=([0-9.]+)`))[1]);
const fk=spawnSync(path.join(here,'../firmware/test-output/geometry-cli.exe'),
  ['0',String(value('q2')),String(value('q3'))],{encoding:'utf8'});
assert.equal(fk.status,0,fk.stderr);
const data=JSON.parse(fk.stdout);
const run=mode=>spawnSync(path.join(here,'tools/openscad-2021.01/openscad.com'),
  ['-o',path.join(here,`four-leg-${mode}-probe.stl`),'-D',`mode="${mode}"`,cad],{encoding:'utf8'});
const modes=['case-deck-collision','case-pair-collision'];
if(process.argv.includes('--full')) modes.push('leg-deck-collision');
for(const mode of modes) {
  const r=run(mode);
  const output=r.stdout+r.stderr;
  assert.equal(r.status,1,output);
  assert.match(output,/Current top level object is empty/);
  assert.doesNotMatch(output,/ERROR|WARNING/);
  console.log(`${mode}: empty nominal intersection`);
}
// FK comes from the independently checked compiled model; transforms are
// tested against explicit expected nominal body-frame coordinates below.
const foot=data.foot;
assert.ok(Array.isArray(foot),'FK output must provide foot');
for(const f of [-1,1]) for(const s of [-1,1]) {
  const p=[f*(value('root_length')/2+foot[0]),s*(value('root_width')/2+foot[1]),value('root_height')+foot[2]];
  assert.ok(Math.abs(p[0]-f*160)<0.001);
  assert.ok(Math.abs(p[1]-s*87)<0.001);
  assert.ok(Math.abs(p[2])<0.001);
  console.log(`root ${f},${s}: foot ${p.join(', ')} mm; determinant ${f*s}`);
}
assert.match(scad,/function placement\(f,s\)=\[\[f,0,0,f\*root_length\/2\],\[0,s,0,s\*root_width\/2\],\[0,0,1,root_height\],\[0,0,0,1\]\]/);
console.log('PASS: four-leg nominal symmetry and case packaging screens. Not a swept clearance or physical fit test.');
