// Small fit/parameter checks; working probe meshes stay outside manufacturing/.
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import {closedMesh,rayCrosses} from './mesh-check.mjs';
const source='mechanical/st3215-leg.scad';
const sourceHash=()=>createHash('sha256').update(fs.readFileSync(source)).digest('hex');
const initialHash=sourceHash();
const compiler=path.resolve('mechanical/tools/openscad-2021.01/openscad.com');
const folder='mechanical/st3215-fit-probes';fs.mkdirSync(folder,{recursive:true});
function render(name,part,settings){
 const file=`${folder}/${name}.stl`;
 const args=['-o',file,'-D',`part="${part}"`];
 for(const [key,value] of Object.entries(settings))args.push('-D',`${key}=${value}`);
 const result=spawnSync(compiler,[...args,source],{encoding:'utf8',timeout:60000});
 assert.equal(result.status,0,result.stderr);
 assert(!/ERROR|WARNING/.test(result.stderr+result.stdout));
 return closedMesh(file);
}
const close=(actual,expected,message)=>assert(Math.abs(actual-expected)<.002,`${message}: ${actual} versus ${expected}`);
for(const top of [false,true]){
 const coupon=closedMesh(`mechanical/st3215-clamp-fit29-${top?'top':'bottom'}.stl`);
 close(coupon.bounds[2][0],0,'coupon print bed');
 assert.deepEqual(coupon.size,[11,44,22]);
 for(const y of [-18,18])assert(!rayCrosses(coupon.v,[23.5,y,-1],[0,0,1],25),'coupon bolt bore blocked');
 assert(!rayCrosses(coupon.v,[23.5,0,8],[0,0,1],13.9),'29 mm band blocks pocket');
 assert(rayCrosses(coupon.v,[23.5,0,1],[0,0,1],10),'coupon grip wall missing');
}
const upper=render('upper-L1-75','upper',{L1:75});
close(upper.size[0],closedMesh('mechanical/st3215-upper.stl').size[0]+5,'L1 moves knee clamp');
const lower=render('lower-L2-90','lower',{L2:90});
close(lower.size[0],closedMesh('mechanical/st3215-lower.stl').size[0]+5,'L2 moves foot');
const hip=render('hip-offset-90','hip',{pitch_forward:90});
close(hip.size[0],closedMesh('mechanical/st3215-hip.stl').size[0]+5,'hip offset moves J2 carrier');
const front=render('front-face-19','shims',{wheel_face_front:19,wheel_face_rear:20});
const rear=render('rear-face-20','shim-rear',{wheel_face_front:19,wheel_face_rear:20});
close(front.size[2],4,'front spacer');close(rear.size[2],3,'rear spacer');
close(19+front.size[2],23,'front reaches fork without forced gap');
close(20+rear.size[2],23,'rear reaches fork without forced gap');
assert.equal(sourceHash(),initialHash,'source changed during fit checks');
const report={source_sha256:initialHash,physical_fit_verified:false,coupon_grip_mm:29,
 coupon_pocket_mm:[25.52,29.8],parameter_checks:['L1 +5 moves upper clamp +5','L2 +5 moves foot +5','hip offset +5 moves carrier +5','front/rear faces19/20 produce independent4/3 mm spacers'],
 limitations:'No real wheel/case/screw/cable fit or loaded qualification. Perturbed meshes are checks, not selected dimensions.'};
fs.writeFileSync('mechanical/st3215-fit-check.json',JSON.stringify(report,null,2)+'\n');
console.log('PASS: 29 mm grip coupons, open bolt bores and independent link/hip/spacer parameter changes.');
