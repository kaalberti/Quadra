#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <vector>
#include <string>
#include "bench_controller.h"
#include "bench_command.h"
#include "pca9685.h"
using namespace bench;
struct MockIO {
  bool disabled=false,initOk=true,offOk=true,healthOk=true,pulseOk=true;
  std::vector<std::string> events;
  void disable(bool d){disabled=d;events.push_back(d?"disable":"enable");}
  bool initialize(){events.push_back("initialize");return initOk;}
  bool allOff(){events.push_back("off");return offOk;}
  bool healthy(){events.push_back("health");return healthOk;}
  bool pulse(uint8_t,uint16_t){events.push_back("pulse");return pulseOk;}
};
struct MockBus {
  uint8_t bytes[256]={}; bool works=true; unsigned slept=0,writes=0;
  std::vector<uint8_t> registers;
  bool write(uint8_t r,const uint8_t* data,size_t n){
    ++writes;registers.push_back(r);if(!works)return false;
    for(size_t i=0;i<n;++i) {
      bytes[r+i]=data[i];
      // ALL_LED writes broadcast into individual registers (NXP section7.3.4).
      if(r+i>=0xfa && r+i<=0xfd)
        for(unsigned c=0;c<16;++c)bytes[6+4*c+(r+i-0xfa)]=data[i];
    }
    return true;
  }
  bool read(uint8_t r,uint8_t& v){if(!works)return false;v=bytes[r];return true;}
  void waitUs(unsigned us){slept=us;}
};
int main(){
  unsigned tests=0;
  {MockIO io;Controller<MockIO> c(io);assert(c.reset());assert(io.disabled);
   assert(c.state()==State::Disarmed);assert(io.events[0]=="disable");
   assert(!c.move(1500,0));assert(!c.arm(3,0));assert(io.disabled);++tests;}
  {MockIO io;Controller<MockIO> c(io);c.reset();io.events.clear();
   assert(c.arm(2,10));assert(!io.disabled);assert(c.channel()==2);
   assert((io.events==std::vector<std::string>{"disable","health","off","pulse","enable"}));
   assert(!c.arm(1,20));assert(c.channel()==2);assert(c.move(1450,20));
   assert(c.move(1550,30));assert(c.disarm());assert(io.disabled);++tests;}
  {MockIO io;Controller<MockIO> c(io);c.reset();c.arm(0,0);
   assert(!c.move(1551,1));assert(c.fault()==Fault::Command && io.disabled);
   assert(!c.arm(0,2));c.disarm();assert(c.state()==State::Fault);
   assert(c.reset());assert(c.state()==State::Disarmed && io.disabled);++tests;}
  {MockIO io;Controller<MockIO> c(io);c.reset();c.arm(0,100);
   c.tick(1599);assert(c.state()==State::Armed);c.tick(1600);
   assert(c.fault()==Fault::Timeout && io.disabled);assert(!c.keepalive(1601));++tests;}
  {MockIO io;Controller<MockIO> c(io);c.reset();c.arm(0,0xfffffff0u);
   assert(c.keepalive(0x100u));c.tick(0x6dbu);assert(c.state()==State::Armed);
   c.tick(0x6dcu);assert(c.fault()==Fault::Timeout);++tests;}
  {MockIO io;Controller<MockIO> c(io);c.reset();c.arm(0,0);io.healthOk=false;
   c.tick(100);assert(c.fault()==Fault::Bus && io.disabled);++tests;}
  {MockIO io;Controller<MockIO> c(io);c.reset();io.pulseOk=false;
   assert(!c.arm(0,0));assert(io.disabled && c.fault()==Fault::Bus);
   for(auto& e:io.events)assert(e!="enable");++tests;}
  {MockIO io;Controller<MockIO> c(io);c.reset();c.arm(0,0);io.events.clear();io.pulseOk=false;
   assert(!c.move(1500,1));assert(io.disabled);assert(io.events[2]=="disable");
   io.initOk=false;assert(!c.reset());assert(c.state()==State::Fault);++tests;}
  {MockIO io;Controller<MockIO> c(io);c.reset();c.arm(0,0);io.events.clear();io.offOk=false;
   assert(!c.disarm());assert(io.events[0]=="disable" && io.disabled);++tests;}
  {MockBus b;b.bytes[7]=0x10;Pca9685<MockBus> p(b);assert(p.initialize());
   assert(b.slept>=500 && b.bytes[0]==0x20 && b.bytes[1]==4 && b.bytes[0xfe]==121);
   for(unsigned i=0;i<16;++i)assert(b.bytes[9+4*i]==0x10);
   assert(b.bytes[7]==0);assert(p.pulse(2,1500));
   assert(b.bytes[16]==51 && b.bytes[17]==1); // channel2 OFF=307
   assert(b.bytes[9]==0x10 && b.bytes[13]==0x10);
   b.bytes[0]=0x11;assert(!p.healthy());++tests;}
  {MockBus b;b.bytes[0]=0x40;Pca9685<MockBus> p(b);assert(!p.initialize());assert(b.writes==0);
   b.bytes[0]=0;b.works=false;assert(!p.initialize());++tests;}
  {assert(pulseTicks(1450)==297 && pulseTicks(1500)==307 && pulseTicks(1550)==318);
   const char* bad[]={"arm -1","arm 3","arm 256","arm 65536","arm 1x","pulse +1500","pulse 1500 extra","pulse ","","ARM 0"};
   for(auto text:bad)assert(parseCommand(text).command==Command::Invalid);
   assert(parseCommand("arm 2").value==2);
   assert(parseCommand("pulse 1500").value==1500);
   assert(parseCommand("status").command==Command::Status);++tests;}
  printf("PASS: %u independent bench-controller scenarios\n",tests);
}
