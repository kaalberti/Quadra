#include <assert.h>
#include <stdio.h>
#include <string>
#include <vector>
#include "pwm_timing.h"
#include "bench_command.h"
#include "pca9685.h"
using namespace bench;
struct IO {
  bool disabled=true,config=true,write=true,cleanup=true,preflight=true,spike=false;
  unsigned offCalls=0,healthCalls=0,measures=0;
  uint32_t high=1498,low=18490;
  std::vector<std::string> events;
  void disable(bool b){disabled=b;events.push_back(b?"disable":"enable");}
  bool healthy(){++healthCalls;events.push_back("health");return config;}
  bool allOff(){++offCalls;events.push_back("off");return offCalls==1?preflight:cleanup;}
  bool testPulse(){events.push_back("test15");return write;}
  uint32_t measure(bool b,uint32_t timeout){assert(timeout==50000 && !disabled);++measures;
    events.push_back("measure");return b?(spike && measures==3?2500:high):low;}
};
struct Bus {
  uint8_t bytes[256]={};
  bool write(uint8_t r,const uint8_t* data,size_t n){for(size_t i=0;i<n;++i)bytes[r+i]=data[i];return true;}
  bool read(uint8_t,uint8_t&){return true;}
  void waitUs(unsigned){}
};
void cleaned(const IO& io){
  assert(io.disabled);assert(io.events[io.events.size()-3]=="disable");
  assert(io.events[io.events.size()-2]=="off");assert(io.events.back()=="health");
}
int main(){
  IO io;auto r=measurePwmTiming(io);assert(r.status==TimingStatus::Passed);
  assert(r.highUs==1498 && r.periodUs==19988 && r.samples==3 && io.measures==6);
  assert((std::vector<std::string>(io.events.begin(),io.events.begin()+5)==
    std::vector<std::string>{"disable","health","off","test15","enable"}));cleaned(io);
  io=IO{};io.write=false;r=measurePwmTiming(io);assert(r.status==TimingStatus::WriteFailed && io.measures==0);cleaned(io);
  io=IO{};io.high=0;r=measurePwmTiming(io);assert(r.status==TimingStatus::NoSignal && io.measures==1);cleaned(io);
  io=IO{};io.low=0;r=measurePwmTiming(io);assert(r.status==TimingStatus::NoSignal && io.measures==2);cleaned(io);
  io=IO{};io.high=10000;io.low=10000;r=measurePwmTiming(io);assert(r.status==TimingStatus::OutOfRange);cleaned(io);
  io=IO{};io.cleanup=false;r=measurePwmTiming(io);assert(r.status==TimingStatus::CleanupFailed);cleaned(io);
  io=IO{};io.config=false;r=measurePwmTiming(io);assert(r.status==TimingStatus::CleanupFailed && io.measures==0);cleaned(io);
  io=IO{};io.preflight=false;r=measurePwmTiming(io);assert(r.status==TimingStatus::ConfigFailed && io.measures==0);cleaned(io);
  io=IO{};io.spike=true;r=measurePwmTiming(io);assert(r.status==TimingStatus::OutOfRange && r.samples==2);cleaned(io);
  assert(parseCommand("timing rail-off no-servos").command==Command::Timing);
  assert(parseCommand("timing").command==Command::Invalid);
  Bus b;Pca9685<Bus> pwm(b);assert(pwm.allOff());assert(pwm.loopbackPulse());
  for(unsigned c=0;c<15;++c)assert(b.bytes[9+4*c]==0x10);
  assert(b.bytes[68]==51 && b.bytes[69]==1); // channel15 OFF=307
  assert(!pwm.pulse(15,1500) && !pwm.off(16));
  puts("PASS: timing sequence, bounded missing-input paths, cleanup failures and channel15-only output");
}
