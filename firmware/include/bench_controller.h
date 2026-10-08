#pragma once
#include "bench_config.h"
namespace bench {
enum class State { Disarmed, Armed, Fault };
enum class Fault { None, Bus, Timeout, Command };
// IO interface: disable(bool), initialize(), allOff(), healthy(), pulse(c,us).
template<class IO> class Controller {
  IO& io;
  State state_=State::Disarmed;
  Fault fault_=Fault::None;
  uint8_t channel_=0;
  uint16_t pulse_=CenterPulseUs;
  uint32_t lastCommand_=0,lastHealth_=0;
  void trip(Fault f) {
    io.disable(true); // isolate signals before attempting bus operations
    state_=State::Fault; fault_=f;
    io.allOff();
  }
public:
  explicit Controller(IO& i):io(i){}
  State state()const{return state_;}
  Fault fault()const{return fault_;}
  uint8_t channel()const{return channel_;}
  uint16_t pulse()const{return pulse_;}
  bool reset() {
    io.disable(true); state_=State::Fault; fault_=Fault::Bus;
    if(!io.initialize()) return false;
    state_=State::Disarmed; fault_=Fault::None; return true;
  }
  bool disarm() {
    io.disable(true);
    if(!io.allOff()) { trip(Fault::Bus); return false; }
    if(state_!=State::Fault) state_=State::Disarmed;
    return true; // disarm never clears a fault
  }
  bool arm(uint8_t c,uint32_t now) {
    if(state_!=State::Disarmed || c>=Channels) return false;
    io.disable(true);
    if(!io.healthy() || !io.allOff() || !io.pulse(c,CenterPulseUs)) {
      trip(Fault::Bus); return false;
    }
    channel_=c; pulse_=CenterPulseUs; lastCommand_=lastHealth_=now;
    state_=State::Armed; io.disable(false); return true;
  }
  bool move(uint16_t us,uint32_t now) {
    tick(now);
    if(state_!=State::Armed) return false;
    if(us<MinPulseUs || us>MaxPulseUs) { trip(Fault::Command); return false; }
    if(!io.healthy() || !io.pulse(channel_,us)) { trip(Fault::Bus); return false; }
    pulse_=us; lastCommand_=now; return true;
  }
  bool keepalive(uint32_t now) {
    tick(now);
    if(state_!=State::Armed) return false;
    if(!io.healthy()) { trip(Fault::Bus); return false; }
    lastCommand_=now; return true;
  }
  void badCommand() { if(state_==State::Armed) trip(Fault::Command); }
  void tick(uint32_t now) {
    if(state_!=State::Armed) return;
    if(uint32_t(now-lastCommand_)>=TimeoutMs) { trip(Fault::Timeout); return; }
    if(uint32_t(now-lastHealth_)>=HealthPeriodMs) {
      lastHealth_=now;
      if(!io.healthy()) trip(Fault::Bus);
    }
  }
};
}
