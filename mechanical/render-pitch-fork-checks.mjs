import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
import assert from 'node:assert/strict';
const here=path.dirname(fileURLToPath(import.meta.url));
const exe=path.join(here,'tools/openscad-2021.01/openscad.com');
const checks=[];
for(const kind of ['upper','lower']) for(const angle of kind==='upper'?[20,44.0486,55]:[60,78.9786,90]) {
 const name=`pitch-fork-${kind}-clearance-${angle}`;
 const r=spawnSync(exe,['-o',path.join(here,name+'.stl'),'-D',`kind="${kind}"`,'-D',`angle=${angle}`,path.join(here,'prototype-pitch-fork-probe.scad')],{encoding:'utf8'});
 const output=r.stdout+r.stderr;
 fs.writeFileSync(path.join(here,name+'.log'),output);
 assert.match(output,/Current top level object is empty/,'intersection must be empty; export failure alone is not clearance evidence');
 assert.doesNotMatch(output,/ERROR:|WARNING:/);
 checks.push({kind,angle_deg:angle,intersection_empty:true});
 console.log(`${kind} ${angle}: empty case/support intersection`);
}
for(const kind of ['upper','lower']) {
 const r=spawnSync(exe,['-o',path.join(here,`prototype-pitch-fork-${kind}-mirrored.stl`),'-D',`part="${kind}"`,'-D','hand=-1',path.join(here,'prototype-pitch-fork.scad')],{encoding:'utf8'});
 assert.equal(r.status,0,r.stderr);assert.doesNotMatch(r.stderr,/ERROR:|WARNING:/);
}
fs.writeFileSync(path.join(here,'pitch-fork-clearance-check.json'),JSON.stringify({checks,scope:'Six sampled local pitch poses; not a continuous sweep, J1/carrier or actual servo ear/horn/lead check.',physical_tested:false},null,2)+'\n');
