import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {execFileSync} from 'node:child_process';
const repo=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'../..');
const cad=fs.readFileSync(path.join(repo,'mechanical/prototype-pitch-leg.scad'),'utf8');
const match=cad.match(/translate\(\[(-?\d+),(-?\d+),(-?\d+)\]\) cube\(\[(\d+),(\d+),(\d+)\]\)/);
assert(match,'Actual foot patch literal must be located; revise probe if CAD changes');
const [,x,y,z,thickness,width,height]=match.map(Number);
const pad=[x,y+width/2,z+height/2];
assert.equal(thickness,1);assert.deepEqual(pad,[-85,0,51]);
const layout=JSON.parse(fs.readFileSync(path.join(repo,'mechanical/prototype-three-dof-layout.json'),'utf8'));
assert.equal(layout.pitch_forward_mm,85);assert.equal(layout.pitch_floor_y_mm,-18);
const compiler=path.join(repo,'mechanical/tools/openscad-2021.01/openscad.com');
for(const angles of [[0,0,0],[0,44.0486,78.9786],[-25,20,60],[30,55,90],[15,44.0486,78.9786]]) {
  test(`compiled C++ agrees with CAD transform chain ${angles}`,()=>{
    const actual=JSON.parse(execFileSync(path.join(repo,'firmware/test-output/geometry-cli.exe'),angles.map(String),{encoding:'utf8'}));
    // OpenSCAD writes echo output to stderr; capture through spawn, not a shell.
    const args=['-o',path.join(repo,'firmware/test-output/geometry-reference.csg'),
      '-D',`q1=${angles[0]}`,'-D',`q2=${angles[1]}`,'-D',`q3=${angles[2]}`,
      '-D',`pad_point=[${pad.join(',')}]`,path.join(repo,'mechanical/geometry-reference-probe.scad')];
    const result=spawn(compiler,args);
    for(const [tag,key] of [['FK_KNEE','knee'],['FK_FOOT','foot'],['FK_PAD','pad_center']]) {
      const m=result.match(new RegExp(`ECHO: "${tag}", (\\[[^\\]]+\\])`));
      assert(m,`Missing CAD echo ${tag}: ${result}`);
      const expected=JSON.parse(m[1]);assert.equal(expected[3],1);
      for(let i=0;i<3;i++)assert(Math.abs(expected[i]-actual[key][i])<0.001,`${key} axis${i}: ${expected[i]} vs ${actual[key][i]}`);
    }
  });
}
import {spawnSync} from 'node:child_process';
function spawn(command,args){
  const result=spawnSync(command,args,{encoding:'utf8'});
  assert.equal(result.status,0,result.stderr);assert(!/WARNING|ERROR/.test(result.stderr),result.stderr);
  return result.stdout+result.stderr;
}
