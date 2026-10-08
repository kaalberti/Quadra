#include <Arduino.h>
#include <Wire.h>
#include <string.h>
#include "bench_controller.h"
#include "bench_command.h"
#include "pca9685.h"

struct WireBus {
  bool write(uint8_t reg,const uint8_t* data,size_t n) {
    Wire.beginTransmission(bench::Address);
    if(Wire.write(reg)!=1 || Wire.write(data,n)!=n) { Wire.endTransmission(); return false; }
    return Wire.endTransmission()==0;
  }
  bool read(uint8_t reg,uint8_t& value) {
    Wire.beginTransmission(bench::Address);
    Wire.write(reg);
    if(Wire.endTransmission(false)!=0) return false;
    if(Wire.requestFrom(bench::Address,uint8_t(1))!=1) return false;
    value=Wire.read(); return true;
  }
  void waitUs(unsigned us) { delayMicroseconds(us); }
} bus;
bench::Pca9685<WireBus> pwm(bus);
struct Hardware {
  void disable(bool disabled){digitalWrite(bench::Oe,disabled?HIGH:LOW);}
  bool initialize(){return pwm.initialize();}
  bool allOff(){return pwm.allOff();}
  bool healthy(){return pwm.healthy();}
  bool pulse(uint8_t c,uint16_t us){return pwm.pulse(c,us);}
} hardware;
bench::Controller<Hardware> controller(hardware);
char line[48]; size_t used=0; bool overflow=false;

void status() {
  const char* names[]={"DISARMED","ARMED","FAULT"};
  const char* faults[]={"NONE","I2C","TIMEOUT","COMMAND"};
  Serial.printf("state=%s fault=%s channel=%u pulse_us=%u\n",
    names[int(controller.state())],faults[int(controller.fault())],
    controller.channel(),controller.pulse());
}
void command(const char* text) {
  bool ok=false;
  const uint32_t now=millis(); controller.tick(now);
  const auto parsed=bench::parseCommand(text);
  switch(parsed.command) {
    case bench::Command::Status:status();return;
    case bench::Command::Disarm:ok=controller.disarm();break;
    case bench::Command::Reset:ok=controller.reset();break;
    case bench::Command::Keepalive:ok=controller.keepalive(now);break;
    case bench::Command::Arm:ok=controller.arm(uint8_t(parsed.value),now);break;
    case bench::Command::Pulse:ok=controller.move(parsed.value,now);break;
    default:controller.badCommand();break;
  }
  Serial.println(ok?"OK":"REJECTED"); status();
}
void setup() {
  digitalWrite(bench::Oe,HIGH); pinMode(bench::Oe,OUTPUT);
  Serial.begin(115200);
  Wire.begin(bench::Sda,bench::Scl,100000); Wire.setTimeOut(10);
  controller.reset();
  Serial.println("Quadra bench only: rail OFF before wiring; status/arm 0..2/pulse 1450..1550/keepalive/disarm/reset");
  status();
}
void loop() {
  controller.tick(millis());
  // Bound work per loop so a serial flood cannot prevent timeout/health checks.
  for(unsigned count=0;count<32 && Serial.available();++count) {
    char c=char(Serial.read());
    if(c=='\r') continue;
    if(c=='\n') {
      if(overflow){controller.badCommand();Serial.println("REJECTED oversized line");}
      else if(used){line[used]=0;command(line);}
      used=0;overflow=false;
    } else if(c<' ' || c>'~') overflow=true;
    else if(!overflow && used<sizeof(line)-1) line[used++]=c;
    else overflow=true;
  }
  delay(1);
}
