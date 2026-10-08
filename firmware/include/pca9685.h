#pragma once
#include "bench_config.h"
namespace bench {
// Bus interface: write(reg, bytes, length), read(reg, byte), waitUs(us).
template<class Bus> class Pca9685 {
  Bus& bus;
  bool reg(uint8_t r,uint8_t v) { return bus.write(r,&v,1); }
public:
  explicit Pca9685(Bus& b):bus(b){}
  bool off(uint8_t channel) {
    const uint8_t data[]={0,0,0,0x10};
    return bus.write(uint8_t(6+4*channel),data,4);
  }
  bool allOff() {
    bool ok=true;
    for(uint8_t c=0;c<16;++c) { if(!off(c)) ok=false; }
    return ok;
  }
  bool healthy() {
    uint8_t mode1=0,mode2=0,scale=0;
    return bus.read(0,mode1) && bus.read(1,mode2) && bus.read(0xfe,scale)
      && (mode1 & 0x7f)==0x20 && mode2==0x04 && scale==Prescale;
  }
  bool initialize() {
    uint8_t previous=0;
    if(!bus.read(0,previous) || (previous & 0x40)) return false; // sticky EXTCLK
    if(!reg(0,0x30) || !reg(1,0x04) || !reg(0xfe,Prescale)) return false;
    if(!reg(0,0x20)) return false;
    bus.waitUs(600);
    if(!allOff()) return false;
    return healthy();
  }
  bool pulse(uint8_t channel,uint16_t us) {
    if(channel>=Channels || us<MinPulseUs || us>MaxPulseUs) return false;
    const uint16_t ticks=pulseTicks(us);
    const uint8_t data[]={0,0,uint8_t(ticks&0xff),uint8_t(ticks>>8)};
    return bus.write(uint8_t(6+4*channel),data,4);
  }
};
}
