#include <assert.h>
#include <stdio.h>
#include <stdint.h>
#include "voltage_monitor.h"
#include "bench_command.h"
using namespace bench;
struct ControlIO {
  bool disabled=true,off=true;
  unsigned enableCalls=0;
  void disable(bool b){disabled=b;if(!b)++enableCalls;}
  bool initialize(){return true;}
  bool allOff(){return off;}
  bool healthy(){return true;}
  bool pulse(uint8_t,uint16_t){return true;}
};
struct ADC {
  bool starts=true,reads=true;
  unsigned begins=0,calls=0,waits=0;
  uint32_t mv=325,raw=430;
  bool spike=false,noise=false;
  bool begin(){++begins;return starts;}
  bool read(uint32_t& r,uint32_t& v){++calls;r=raw;v=spike && calls==8?2001:(noise && calls%2?mv+2:mv);return reads;}
  void waitMs(unsigned n){waits+=n;}
};
int main(){
  ControlIO io;Controller<ControlIO> c(io);assert(c.reset());ADC adc;
  auto r=measureVoltage(c,adc);assert(r.status==VoltageStatus::Reading);
  assert(r.inputMv==5200 && r.adcMv==325 && r.samples==16 && r.rawAverage==430);
  assert(adc.calls==16 && adc.waits==21 && c.state()==State::Disarmed && io.disabled && !io.enableCalls);
  adc=ADC{};adc.noise=true;r=measureVoltage(c,adc);assert(r.spreadMv==2 && r.adcMv==326 && r.inputMv==5216);
  adc=ADC{};adc.mv=1575;r=measureVoltage(c,adc);assert(r.inputMv==25200 && r.status==VoltageStatus::Reading);
  adc=ADC{};adc.mv=0;adc.raw=0;r=measureVoltage(c,adc);assert(r.status==VoltageStatus::LowOrDisconnected && r.inputMv==0);
  adc=ADC{};adc.mv=99;r=measureVoltage(c,adc);assert(r.status==VoltageStatus::LowOrDisconnected);
  adc=ADC{};adc.mv=100;r=measureVoltage(c,adc);assert(r.status==VoltageStatus::Reading);
  adc=ADC{};adc.spike=true;r=measureVoltage(c,adc);assert(r.status==VoltageStatus::AdcOutOfRange && r.samples==7 && r.inputMv==0);
  adc=ADC{};adc.raw=4095;r=measureVoltage(c,adc);assert(r.status==VoltageStatus::AdcOutOfRange && r.samples==0);
  adc=ADC{};adc.mv=UINT32_MAX;r=measureVoltage(c,adc);assert(r.status==VoltageStatus::AdcOutOfRange && r.inputMv==0);
  adc=ADC{};adc.reads=false;r=measureVoltage(c,adc);assert(r.status==VoltageStatus::ReadFailed && r.samples==0);
  adc=ADC{};adc.starts=false;r=measureVoltage(c,adc);assert(r.status==VoltageStatus::ReadFailed && !adc.calls);
  adc=ADC{};io.off=false;r=measureVoltage(c,adc);assert(r.status==VoltageStatus::PreflightFailed && !adc.begins && io.disabled && c.state()==State::Fault);
  io.off=true;adc=ADC{};r=measureVoltage(c,adc);assert(r.status==VoltageStatus::NotDisarmed && !adc.begins && c.state()==State::Fault);
  assert(c.reset());assert(c.arm(0,0));adc=ADC{};r=measureVoltage(c,adc);
  assert(r.status==VoltageStatus::NotDisarmed && !adc.calls && !adc.begins && c.state()==State::Fault && c.fault()==Fault::Command && io.disabled);
  assert(c.reset());assert(c.arm(0,100));c.tick(1599);adc=ADC{};measureVoltage(c,adc);
  assert(c.state()==State::Fault && c.fault()==Fault::Command && !adc.calls);
  assert(parseCommand("voltage rail-off no-servos").command==Command::Voltage);
  const char* invalid[]={"voltage","voltage rail-off","voltage rail-off no-servos extra","VOLTAGE rail-off no-servos"};
  for(auto text:invalid)assert(parseCommand(text).command==Command::Invalid);
  puts("PASS: voltage scale,16-sample bound,zero/low,spike/saturation/failure rejection,disarmed gating and no automatic recovery");
}
