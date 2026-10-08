import fs from 'node:fs';import assert from 'node:assert/strict';import {createHash} from 'node:crypto';
import {spawnSync} from 'node:child_process';import {fileURLToPath} from 'node:url';
import {closedMesh,rayCrosses} from './mesh-check.mjs';
const file=n=>new URL(n,import.meta.url),sha=n=>createHash('sha256').update(fs.readFileSync(file(n))).digest('hex');
const base=closedMesh(file('prototype-electronics-carrier-base.stl')),shelf=closedMesh(file('prototype-electronics-carrier-shelf.stl'));
assert.deepEqual(base.bounds,[[-81,81],[-44,44],[0,40]]);
assert.deepEqual(shelf.bounds,[[-81,81],[-44,44],[0,7]]);
assert(base.size[0]<180 && base.size[1]<110 && shelf.bounds[2][0]===0);
const clear=(mesh,p,d,l)=>assert(!rayCrosses(mesh.v,p,d,l),'blocked path '+JSON.stringify(p));
const solid=(mesh,p,d,l)=>assert(rayCrosses(mesh.v,p,d,l),'missing support '+JSON.stringify(p));
let rays=0;
for(const x of [-75,75])for(const s of [-1,1]){
 for(const [dx,dy] of [[0,0],[1.4,0],[-1.4,0],[0,1.4],[0,-1.4]]){
  clear(base,[x+dx,s*38+dy,31.6],[0,0,1],8.5);
  clear(shelf,[x+dx,s*38+dy,-1],[0,0,1],6);rays+=2;
 }
 for(const dx of [-2.7,0,2.7]){clear(base,[x+dx,s*46,34.5],[0,-s,0],9);rays++;}
 solid(base,[x+4,s*38,30],[0,0,1],11);rays++;
}
for(const x of [-60,60])for(const y of [-20,20])for(const dx of [-2.5,0,2.5]){
 clear(base,[x+dx,y,-1],[0,0,1],6);rays++;
}
for(const x of [-55,-25,25,55])for(const y of [-10,10]){
 clear(shelf,[x,y,-1],[0,0,1],9);rays++;
}
for(const x of [-46,46])for(const y of [-38,38]){
 clear(base,[x,y-4,.9],[0,1,0],8);solid(base,[x,y-4,3],[0,1,0],8);rays+=2;
}
for(const f of [-1,1])for(const s of [-1,1])for(const x of [-28,-16])for(const y of [-25,-10]){
 const px=f*(75+x),py=s*(55+y);
 for(let i=0;i<9;i++){
  const radius=i?3.5:0,angle=i*2*Math.PI/8;
  const point=[px+radius*Math.cos(angle),py+radius*Math.sin(angle),-1];
  clear(base,point,[0,0,1],75);clear(shelf,[point[0],point[1],-41],[0,0,1],75);rays+=2;
 }
}
for(const x of [-40,40])for(const y of [-37.5,37.5]){solid(base,[x,y,10.5],[0,0,-1],11);rays++;}
for(const x of [-65,-15,15,65])for(const y of [-10,10]){solid(shelf,[x,y,7.5],[0,0,-1],8);rays++;}
const compiler=fileURLToPath(file('tools/openscad-2021.01/openscad.com'));
const probe=spawnSync(compiler,['-o',fileURLToPath(file('electronics-carrier-board-collision.stl')),'-D','view="board-collision"',fileURLToPath(file('prototype-electronics-carrier.scad'))],{encoding:'utf8',timeout:60000});
const log=(probe.stdout??'')+(probe.stderr??'');fs.writeFileSync(file('electronics-carrier-board-collision.log'),log);
assert.equal(probe.error,undefined);assert.equal(probe.status,1);
assert(log.includes('Current top level object is empty.') && !/ERROR|WARNING|CGAL error/i.test(log),'unreliable Boolean evidence');
assert(!fs.existsSync(file('electronics-carrier-board-collision.stl')),'unexpected or stale collision mesh');
const report={closed_connected_bed_meshes:true,base_size_mm:base.size,shelf_size_mm:shelf.size,mesh_passage_checks:rays,
  retained_chassis_fixing_paths:16,mounting_hardware:{M3x12_bolts:4,M3_nuts:4,M3_washers:4},
  board_space_claims:{perfboard_mm:[100,80,21.6],esp32_mm:[70,35,20],pca9685_mm:[65,30,15]},
  lower_board_underside_clearance_mm:6,lower_board_to_shelf_clearance_mm:8.4,upper_board_underside_clearance_mm:3,
  base_solid_PETG_g:base.volume/1000*1.27,shelf_solid_PETG_g:shelf.volume/1000*1.27,
  total_solid_PETG_g:(base.volume+shelf.volume)/1000*1.27,nominal_board_intersection:'empty CGAL, intended support faces relieved0.001mm',
  source_sha256:Object.fromEntries(['prototype-electronics-carrier.scad','prototype-electronics-deck.scad','prototype-electronics-carrier-base.stl','prototype-electronics-carrier-shelf.stl'].map(n=>[n,sha(n)])),
  adopted_in_robot_manifest:false,physical_fit_verified:false,physical_strength_verified:false,actual_board_dimensions_measured:false};
fs.writeFileSync(file('electronics-carrier-check.json'),JSON.stringify(report,null,2)+'\n');
console.log(`PASS:two bed-oriented closed connected carrier meshes;${rays} passage/support checks;16 chassis fixing access paths;nominal board intersection empty;solid PETG${report.total_solid_PETG_g.toFixed(1)}g. Physical fit remains untested.`);
