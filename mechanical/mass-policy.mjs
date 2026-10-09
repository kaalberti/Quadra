import assert from 'node:assert/strict';
export function evaluateMassPolicy({targetG,qualifiedLimitG,estimatedG,measuredG}) {
 const positive=v=>Number.isFinite(v)&&v>0;
 assert(positive(targetG) && positive(estimatedG),'invalid target/estimate');
 assert(qualifiedLimitG===null || positive(qualifiedLimitG),'invalid qualified maximum');
 assert(measuredG===null || positive(measuredG),'invalid measured mass');
 return {
  preferred_target_g:targetG,qualified_limit_g:qualifiedLimitG,
  estimated_margin_to_preferred_target_g:targetG-estimatedG,
  measured_margin_to_preferred_target_g:measuredG===null?null:targetG-measuredG,
  estimated_margin_to_qualified_limit_g:qualifiedLimitG===null?null:qualifiedLimitG-estimatedG,
  measured_margin_to_qualified_limit_g:qualifiedLimitG===null || measuredG===null?null:qualifiedLimitG-measuredG,
  capacity_limit_status:qualifiedLimitG===null?'NOT_QUALIFIED':'APPROVED_LIMIT_SUPPLIED',
  status:measuredG===null?'NOT_MEASURED':qualifiedLimitG===null?'MEASURED_CAPACITY_NOT_QUALIFIED':
   measuredG<=qualifiedLimitG?'MEASURED_WITHIN_QUALIFIED_LIMIT':'MEASURED_OVER_QUALIFIED_LIMIT'
 };
}
