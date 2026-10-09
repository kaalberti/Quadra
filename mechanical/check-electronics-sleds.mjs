import fs from 'node:fs';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';
import {spawnSync} from 'node:child_process';import {fileURLToPath} from 'node:url';
import {closedMesh,rayCrosses} from './mesh-check.mjs';
const file=n=>new URL(n,import.meta.url),sha=n=>createHash('sha256').update(fs.readFileSync(file(n))).digest('hex');
const parts=[['perfboard',0],['esp32',-70],['pca9685',70]].map(([name,x])=>({name,x,...closedMesh(file(`prototype-electronics-sled-${name}.stl`))}));
let rays=0;
const clear=(p,o,d,l)=>assert(!rayCrosses(p.v,o,d,l),'blocked path '+p.name+JSON.stringify(o));
const support=(p,o)=>assert(rayCrosses(p.v,o,[0,0,-1],9),'missing support '+p.name+JSON.stringify(o));
for(const p of parts){assert.equal(p.bounds[2][0],0);assert.equal(p.bounds[2][1],8);
 assert(p.bounds[0][0]+p.x>=-90 && p.bounds[0][1]+p.x<=90 && p.size[1]<=110);
 for(const x of p.name==='perfboard'?[-15,15]:[p.name==='esp32'?10:-10])for(const y of [-20,20])for(const dx of [-2.5,0,2.5]){
  clear(p,[x+dx,y,-1],[0,0,1],5);rays++;
 }
 for(const x of p.name==='perfboard'?[-40,40]:[-12,12])for(const y of p.name==='perfboard'?[-37.5,37.5]:[-22,22]){support(p,[x,y,8.5]);rays++;}
 for(const f of [-1,1])for(const s of [-1,1])for(const x of [-28,-16])for(const y of [-25,-10])for(let i=0;i<9;i++){
  const radius=i?3.5:0,angle=i*2*Math.PI/8;
  clear(p,[f*(75+x)+radius*Math.cos(angle)-p.x,s*(55+y)+radius*Math.sin(angle),-1],[0,0,1],10);rays++;
 }
}
for(let i=0;i<parts.length;i++)for(let j=i+1;j<parts.length;j++){
 const a=parts[i],b=parts[j];assert(a.bounds[0][1]+a.x<b.bounds[0][0]+b.x || b.bounds[0][1]+b.x<a.bounds[0][0]+a.x,'overlapping frames');
}
for(const x of [-46,46])for(const y of [-38,38]){clear(parts[0],[x,y-4,.7],[0,1,0],8);rays++;}
const compiler=fileURLToPath(file('tools/openscad-2021.01/openscad.com'));
const probe=spawnSync(compiler,['-o',fileURLToPath(file('electronics-sleds-board-collision.stl')),'-D','view="board-collision"',fileURLToPath(file('prototype-electronics-sleds.scad'))],{encoding:'utf8',timeout:60000});
const log=(probe.stdout??'')+(probe.stderr??'');fs.writeFileSync(file('electronics-sleds-board-collision.log'),log);
assert.equal(probe.error,undefined);assert.equal(probe.status,1);
assert(log.includes('Current top level object is empty.') && !/ERROR|WARNING|CGAL error/i.test(log));
assert(!fs.existsSync(file('electronics-sleds-board-collision.stl')),'unexpected or stale collision mesh');
const solidMass=parts.reduce((s,p)=>s+p.volume/1000*1.27,0);
const old=JSON.parse(fs.readFileSync(file('electronics-carrier-check.json'),'utf8')).total_solid_PETG_g;
assert(solidMass<old/2,'little practical mass reduction');
const report={closed_connected_bed_meshes:true,parts:parts.map(p=>({name:p.name,size_mm:p.size,placement_x_mm:p.x,solid_PETG_g:p.volume/1000*1.27,stl_sha256:p.sha256})),
 mesh_passage_checks:rays,deck_fixing_head_clearance_paths:16,head_envelope_assumption_mm:{diameter:7,height:4},
 pcb_underside_height_mm:8,underside_clearance_above_frame_mm:5,added_M3_mount_fasteners:0,
 assembled_prints_bounds_mm:[[-88,86],[-41,41],[0,8]],nominal_board_gap_mm:[2.5,5],
 total_solid_PETG_g:solidMass,two_tier_solid_PETG_g:old,solid_PETG_reduction_g:old-solidMass,
 nominal_populated_height_above_deck_mm:29.6,nominal_board_intersection:'empty CGAL, support faces relieved0.001mm',
 source_sha256:Object.fromEntries(['prototype-electronics-sleds.scad','prototype-electronics-deck.scad',...parts.map(p=>`prototype-electronics-sled-${p.name}.stl`)].map(n=>[n,sha(n)])),
 screwdriver_access_requires_board_removal:true,robot_manifest_adopted:false,physical_fit_verified:false,actual_board_dimensions_measured:false};
fs.writeFileSync(file('electronics-sleds-check.json'),JSON.stringify(report,null,2)+'\n');
console.log(`PASS:three bed-oriented closed connected sleds;${rays} checks;16 fixing-head paths and nominal board clearance;solid PETG${solidMass.toFixed(1)}g vs${old.toFixed(1)}g stack;no added M3 mount fasteners. Physical board/strap fit remains untested.`);
