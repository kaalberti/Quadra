#include <Arduino.h>
#include "st3215_bench.h"
using namespace st3215;
HardwareSerial servo(1);
struct UartIO {
 void clear(){unsigned n=0;while(servo.available() && n++<128)servo.read();}
 bool send(const uint8_t* bytes,size_t n){const size_t sent=servo.write(bytes,n);servo.flush();return sent==n;}
 int next(){return servo.available()?servo.read():-1;}
 uint32_t now(){return millis();}void wait(unsigned ms){delay(ms);}
} io;
bool busEnabled=false;Feedback sample;Fault lastFault=Fault::None;
char input[96];size_t used=0;bool overflow=false;
void runCommand(const char* line){
 const Command c=parseCommand(line);sample.valid=false;
 if(c.kind==CommandKind::Invalid){Serial.println("ERR BAD_COMMAND");return;}
 if(c.kind==CommandKind::Status){Serial.printf("BUS=%s LAST_FAULT=%s TORQUE=UNKNOWN\n",busEnabled?"ENABLED":"DISABLED",faultName(lastFault));return;}
 if(c.kind==CommandKind::Close){if(busEnabled)servo.end();busEnabled=false;lastFault=Fault::None;Serial.println("BUS=DISABLED TORQUE=UNKNOWN");return;}
 if(c.kind==CommandKind::Bus){
  if(busEnabled){Serial.println("ERR CLOSE_RAIL_OFF_FIRST");return;}
  servo.begin(Baud,SERIAL_8N1,int(c.rx),int(c.tx));busEnabled=true;lastFault=Fault::None;
  Serial.printf("BUS=ENABLED RX=%u TX=%u BAUD=%lu TORQUE=UNKNOWN\n",c.rx,c.tx,static_cast<unsigned long>(Baud));return;
 }
 if(!busEnabled){Serial.println("ERR BUS_DISABLED");return;}
 if(c.kind==CommandKind::Ping){Packet p;Reply reply;makePacket(Request::Ping,c.id,p);lastFault=exchange(io,p,reply);}
 else if(c.kind==CommandKind::Feedback)lastFault=feedback(io,c.id,sample);
 else if(c.kind==CommandKind::Off)lastFault=torqueOff(io,c.id);
 if(lastFault!=Fault::None){Serial.printf("ERR %s ID=%u FEEDBACK_VALID=0 TORQUE=UNKNOWN\n",faultName(lastFault),c.id);return;}
 if(c.kind==CommandKind::Feedback){
  Serial.printf("FEEDBACK ID=%u POSITION=%ld SPEED=%ld LOAD_RAW_SIGNED=%ld VOLTAGE_TENTHS=%u TEMP_RAW=%u MOVING_RAW=%u CURRENT_RAW_SIGNED=%ld TORQUE_RAW=%u SAMPLE_MS=%lu\n",c.id,static_cast<long>(sample.position),static_cast<long>(sample.speed),static_cast<long>(sample.load),sample.voltageTenths,sample.temperature,sample.moving,static_cast<long>(sample.current),sample.torque,static_cast<unsigned long>(sample.sampleMs));
 }else Serial.printf("OK %s ID=%u\n",c.kind==CommandKind::Off?"TORQUE_OFF_READBACK":"PING",c.id);
}
void setup(){Serial.begin(115200);Serial.println("ST3215 FEEDBACK BENCH. BUS DISABLED. NO MOTION COMMANDS.");}
void loop(){
 while(Serial.available()){
  const char ch=char(Serial.read());
  if(ch=='\r')continue;
  if(ch=='\n'){
   if(overflow){sample.valid=false;Serial.println("ERR LINE_TOO_LONG_OR_BINARY");}
   else{input[used]=0;runCommand(input);}used=0;overflow=false;
  }else if(ch==0 || used>=sizeof(input)-1){overflow=true;}
  else if(!overflow)input[used++]=ch;
 }
 delay(1);
}
