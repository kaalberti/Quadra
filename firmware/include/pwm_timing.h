#pragma once
#include "bench_config.h"
namespace bench {
enum class TimingStatus { Passed, ConfigFailed, WriteFailed, NoSignal, OutOfRange, CleanupFailed };
struct TimingResult { TimingStatus status=TimingStatus::ConfigFailed; uint32_t highUs=0,periodUs=0; uint8_t samples=0; };
// IO: disable, healthy, allOff, testPulse, measure(high, timeoutUs).
// Caller must require DISARMED and explicit rail-off/no-servos acknowledgement.
template<class IO> TimingResult measurePwmTiming(IO& io) {
  TimingResult result;io.disable(true);
  if(io.healthy() && io.allOff()) {
    if(io.testPulse()) {
      io.disable(false);uint32_t highSum=0,periodSum=0;
      result.status=TimingStatus::Passed;
      for(unsigned i=0;i<3;++i) {
        const uint32_t high=io.measure(true,TimingWaitUs);
        const uint32_t low=high?io.measure(false,TimingWaitUs):0;
        if(!high || !low){result.status=TimingStatus::NoSignal;break;}
        // Defend against malformed measurement adapters as well as no input.
        if(high>TimingWaitUs || low>TimingWaitUs){result.status=TimingStatus::OutOfRange;break;}
        highSum+=high;periodSum+=high+low;++result.samples;
        if(high<1400 || high>1600 || high+low<19000 || high+low>21000) {
          result.status=TimingStatus::OutOfRange;break;
        }
      }
      if(result.samples) {
        result.highUs=highSum/result.samples;result.periodUs=periodSum/result.samples;
      }
      if(result.status==TimingStatus::Passed &&
         (result.highUs<1400 || result.highUs>1600 || result.periodUs<19000 || result.periodUs>21000))
        result.status=TimingStatus::OutOfRange;
    } else result.status=TimingStatus::WriteFailed;
  }
  io.disable(true); // before any potentially failing cleanup transaction
  const bool off=io.allOff(),healthy=io.healthy();
  if(!off || !healthy)result.status=TimingStatus::CleanupFailed;
  return result;
}
}
