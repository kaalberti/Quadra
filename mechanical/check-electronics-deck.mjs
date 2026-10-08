import fs from 'node:fs';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {closedMesh,rayCrosses} from './mesh-check.mjs';
const root=new URL('./',import.meta.url),file=n=>new URL(n,root),sha=n=>createHash('sha256').update(fs.readFileSync(file(n))).digest('hex');
const mesh=closedMesh(file('prototype-electronics-deck.stl')),base=closedMesh(file('prototype-chassis-deck.stl'));
assert.deepEqual(mesh.bounds,[[-90,90],[-55,55],[0,4]]);
const through=(x,y)=>rayCrosses(mesh.v,[x,y,-1],[0,0,1],6);
const slots=[];let rayChecks=0;
for(const x of [-60,-15,15,60])for(const y of [-20,20]){
 for(const dx of [-2.5,0,2.5])for(const dy of [-1.2,0,1.2]){assert(!through(x+dx,y+dy),'blocked tie slot');rayChecks++;}
 for(const dy of [-2.5,2.5]){assert(through(x,y+dy),'missing slot side wall');rayChecks++;}
 slots.push({centre_mm:[x,y],length_mm:8,width_mm:3});
}
const holes=[];for(const f of [-1,1])for(const s of [-1,1])for(const x of [-28,-16])for(const y of [-25,-10]){
 const p=[f*(75+x),s*(55+y)];holes.push(p);for(const [dx,dy] of [[0,0],[1.5,0],[-1.5,0],[0,1.5],[0,-1.5]]){assert(!through(p[0]+dx,p[1]+dy),'blocked retained M3 fixing');rayChecks++;}
}
assert(through(0,0),'missing central deck material');rayChecks++;
let minLigament=Infinity;for(const slot of slots)for(const hole of holes){const [x,y]=slot.centre_mm;const dx=Math.max(0,Math.abs(hole[0]-x)-2.5),dy=Math.abs(hole[1]-y);minLigament=Math.min(minLigament,Math.hypot(dx,dy)-1.5-1.75);}assert(minLigament>=6,'slot too close to chassis fixing');
const expectedRemoval=8*4*(5*3+Math.PI*1.5**2),removal=base.volume-mesh.volume;assert(Math.abs(removal-expectedRemoval)/expectedRemoval<.01,'volume change differs from eight slots');
const report={closed:true,connected:true,on_bed:true,size_mm:mesh.size,slots,retained_chassis_holes:holes,mesh_ray_checks:rayChecks,minimum_slot_to_fixing_ligament_mm:minLigament,solid_PETG_g:mesh.volume/1000*1.27,removed_volume_mm3:removal,expected_removed_volume_mm3:expectedRemoval,source_sha256:Object.fromEntries(['prototype-electronics-deck.scad','prototype-chassis-assembly.scad','prototype-chassis-deck.stl','prototype-electronics-deck.stl'].map(n=>[n,sha(n)])),nominal_clearance_basis:'Subtractive variant of unchanged deck; no geometry added to its envelope. Existing nominal deck clearance is retained. Electronics reservations and actual mounts are unverified.',physical_fit_verified:false,loaded_strength_verified:false};
fs.writeFileSync(file('electronics-deck-check.json'),JSON.stringify(report,null,2)+'\n');console.log('PASS:closed connected180x110x4mm deck;8 tie slots,16 retained fixings,'+rayChecks+' mesh rays;minimum ligament '+minLigament+'mm.');