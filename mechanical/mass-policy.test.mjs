import test from 'node:test';import assert from 'node:assert/strict';import {evaluateMassPolicy as evaluate} from './mass-policy.mjs';
const record={targetG:2000,qualifiedLimitG:null,estimatedG:2178,measuredG:null};
test('unknown operating capacity never becomes a zero or target ceiling',()=>{
 const r=evaluate(record);assert.equal(r.estimated_margin_to_preferred_target_g,-178);
 assert.equal(r.qualified_limit_g,null);assert.equal(r.estimated_margin_to_qualified_limit_g,null);
 assert.equal(r.status,'NOT_MEASURED');assert.equal(r.capacity_limit_status,'NOT_QUALIFIED');
});
test('weighing a heavier robot does not establish servo capacity',()=>{
 const r=evaluate({...record,measuredG:2200});assert.equal(r.status,'MEASURED_CAPACITY_NOT_QUALIFIED');
 assert.equal(r.measured_margin_to_preferred_target_g,-200);assert.equal(r.measured_margin_to_qualified_limit_g,null);
});
test('below preferred target still requires capacity qualification',()=>assert.equal(evaluate({...record,measuredG:1800}).status,'MEASURED_CAPACITY_NOT_QUALIFIED'));
test('qualified limit may exceed target independently',()=>{
 const r=evaluate({...record,qualifiedLimitG:2500,measuredG:2200});
 assert.equal(r.status,'MEASURED_WITHIN_QUALIFIED_LIMIT');assert.equal(r.measured_margin_to_qualified_limit_g,300);
 assert.equal(r.measured_margin_to_preferred_target_g,-200);
});
test('above qualified mass rejects even if a target is higher',()=>assert.equal(evaluate({...record,targetG:3000,qualifiedLimitG:2500,measuredG:2600}).status,'MEASURED_OVER_QUALIFIED_LIMIT'));
test('qualified capacity without measured whole mass remains unmeasured',()=>assert.equal(evaluate({...record,qualifiedLimitG:2500}).status,'NOT_MEASURED'));
test('exact qualified boundary retains zero margin',()=>assert.equal(evaluate({...record,qualifiedLimitG:2200,measuredG:2200}).measured_margin_to_qualified_limit_g,0));
test('nonfinite,zero,negative and omitted values are rejected',()=>{
 for(const key of ['targetG','estimatedG','qualifiedLimitG','measuredG'])for(const value of [NaN,Infinity,0,-1,undefined])assert.throws(()=>evaluate({...record,[key]:value}));
});
