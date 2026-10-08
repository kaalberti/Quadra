#pragma once
#include "bench_controller.h"
namespace bench {
constexpr uint8_t VoltageInput=8, VoltageSamples=16;
constexpr uint32_t VoltageDividerScale=16, VoltageAdcCeilingMv=2000;
enum class VoltageStatus { Reading, LowOrDisconnected, AdcOutOfRange, ReadFailed, NotDisarmed, PreflightFailed };
struct VoltageResult {
  VoltageStatus status=VoltageStatus::ReadFailed;
  uint32_t adcMv=0,inputMv=0,spreadMv=0,rawAverage=0;
  uint8_t samples=0;
};
// ADC IO: begin(), read(raw, calibratedMv), waitMs(ms). No servo-output methods.
// Fixed nominal150k/10k divider; estimates are not calibrated battery thresholds.
template<class Control,class ADC> VoltageResult measureVoltage(Control& controller,ADC& adc) {
  VoltageResult result;
  if(controller.state()!=State::Disarmed) {
    controller.badCommand();result.status=VoltageStatus::NotDisarmed;return result;
  }
  // Reassert OE high and full-off before initializing any ADC operation.
  if(!controller.disarm()){result.status=VoltageStatus::PreflightFailed;return result;}
  if(!adc.begin())return result;
  adc.waitMs(5);
  uint32_t sum=0,rawSum=0,minimum=VoltageAdcCeilingMv,maximum=0;
  for(unsigned i=0;i<VoltageSamples;++i) {
    uint32_t raw=0,mv=0;
    if(!adc.read(raw,mv))return result;
    if(raw>=4095 || mv>VoltageAdcCeilingMv) {
      result.status=VoltageStatus::AdcOutOfRange;return result;
    }
    sum+=mv;rawSum+=raw;if(mv<minimum)minimum=mv;if(mv>maximum)maximum=mv;
    ++result.samples;adc.waitMs(1);
  }
  result.adcMv=(sum+VoltageSamples/2)/VoltageSamples;
  result.inputMv=(sum*VoltageDividerScale+VoltageSamples/2)/VoltageSamples;
  result.rawAverage=(rawSum+VoltageSamples/2)/VoltageSamples;
  result.spreadMv=maximum-minimum;
  result.status=minimum<100?VoltageStatus::LowOrDisconnected:VoltageStatus::Reading;
  return result;
}
}
