#pragma once
#include <stdint.h>
#include <stddef.h>
#include <string.h>
namespace st3215 {
constexpr uint32_t Baud=1000000, ReplyTimeoutMs=25;
enum class Request { Ping, Feedback, TorqueState, TorqueOff };
enum class Fault { None, InvalidId, Send, Timeout, Length, Checksum, WrongId, Device, Noise, NotOff };
struct Packet { uint8_t data[8]{}; size_t size=0; uint8_t expected=0; };
inline bool makePacket(Request kind,unsigned id,Packet& p){
 p=Packet{}; if(id<1 || id>253)return false;
 p.data[0]=255;p.data[1]=255;p.data[2]=uint8_t(id);
 p.size=kind==Request::Ping?6:8;p.data[3]=uint8_t(p.size-4);
 p.data[4]=kind==Request::Ping?1:kind==Request::TorqueOff?3:2;
 if(kind!=Request::Ping){p.data[5]=kind==Request::Feedback?56:40;p.data[6]=kind==Request::Feedback?15:kind==Request::TorqueOff?0:1;}
 p.expected=kind==Request::Feedback?15:kind==Request::TorqueState?1:0;
 uint8_t sum=0;for(size_t i=2;i<p.size-1;i++)sum=uint8_t(sum+p.data[i]);
 p.data[p.size-1]=uint8_t(~sum);return true;
}
struct Reply { uint8_t id=0,error=0,count=0,data[15]{}; };
class Decoder {
 uint8_t bytes[21]{};size_t used=0,total=0;bool complete=false;
public:
 Fault fault=Fault::None; Reply reply{};
 bool push(uint8_t b){
  if(fault!=Fault::None || complete)return false;
  if(used<2){if(b==255)bytes[used++]=b;else used=0;return false;}
  if(used==2 && b==255)return false; // Extra header byte, not a legal selected ID.
  bytes[used++]=b;
  if(used==4){if(b<2 || b>17){fault=Fault::Length;return false;}total=size_t(b)+4;}
  if(!total || used<total)return false;
  uint8_t sum=0;for(size_t i=2;i<total;i++)sum=uint8_t(sum+bytes[i]);
  if(sum!=255){fault=Fault::Checksum;return false;}
  reply.id=bytes[2];reply.error=bytes[4];reply.count=uint8_t(bytes[3]-2);
  memcpy(reply.data,bytes+5,reply.count);complete=true;return true;
 }
};
// IO: clear(), send(bytes,n), next() (-1=no byte), now(), wait(ms).
template<class IO> Fault exchange(IO& io,const Packet& p,Reply& out){
 out=Reply{};io.clear();if(!io.send(p.data,p.size))return Fault::Send;
 Decoder decoder;const uint32_t start=io.now();unsigned received=0;
 while(uint32_t(io.now()-start)<ReplyTimeoutMs){
  const int byte=io.next();if(byte<0){io.wait(1);continue;}
  if(++received>128)return Fault::Noise;
  if(decoder.push(uint8_t(byte))){
   if(decoder.reply.id!=p.data[2])return Fault::WrongId;
   if(decoder.reply.error)return Fault::Device;
   if(decoder.reply.count!=p.expected)return Fault::Length;
   out=decoder.reply;return Fault::None;
  }
  if(decoder.fault!=Fault::None)return decoder.fault;
 }
 return Fault::Timeout;
}
inline uint16_t word(const uint8_t* b){return uint16_t(b[0])|uint16_t(uint16_t(b[1])<<8);}
inline int32_t magnitude(uint16_t value,unsigned bit){const uint16_t mask=uint16_t(1u<<bit);return value&mask?-int32_t(value&uint16_t(~mask)):int32_t(value);}
struct Feedback { bool valid=false;int32_t position=0,speed=0,load=0,current=0;uint8_t voltageTenths=0,temperature=0,moving=0,torque=0;uint32_t sampleMs=0; };
template<class IO> Fault feedback(IO& io,unsigned id,Feedback& out){
 out=Feedback{};Packet p;Reply r;if(!makePacket(Request::Feedback,id,p))return Fault::InvalidId;
 Fault f=exchange(io,p,r);if(f!=Fault::None)return f;
 Feedback value;value.position=magnitude(word(r.data),15);value.speed=magnitude(word(r.data+2),15);
 value.load=magnitude(word(r.data+4),10);value.voltageTenths=r.data[6];value.temperature=r.data[7];value.moving=r.data[10];value.current=magnitude(word(r.data+13),15);
 makePacket(Request::TorqueState,id,p);f=exchange(io,p,r);if(f!=Fault::None)return f;
 value.torque=r.data[0];value.sampleMs=io.now();value.valid=true;out=value;return Fault::None;
}
template<class IO> Fault torqueOff(IO& io,unsigned id){
 Packet p;if(!makePacket(Request::TorqueOff,id,p))return Fault::InvalidId;
 io.clear();if(!io.send(p.data,p.size))return Fault::Send;
 // Read back regardless of whether this servo returns a write acknowledgement.
 io.wait(2);makePacket(Request::TorqueState,id,p);Reply r;
 Fault f=exchange(io,p,r);if(f!=Fault::None)return f;
 return r.data[0]==0?Fault::None:Fault::NotOff;
}
enum class CommandKind { Invalid, Status, Bus, Close, Ping, Feedback, Off };
struct Command {CommandKind kind=CommandKind::Invalid;unsigned id=0,rx=0,tx=0;};
inline bool unsignedToken(const char* s,unsigned& value){value=0;if(!*s)return false;for(;*s;s++){if(*s<'0'||*s>'9')return false;value=value*10+unsigned(*s-'0');if(value>253)return false;}return true;}
inline Command parseCommand(const char* line){
 Command c;char tokens[5][24]{};size_t n=0,k=0;
 while(*line){while(*line==' '||*line=='\t')line++;if(!*line)break;if(n==5)return c;k=0;
  while(*line && *line!=' ' && *line!='\t'){if(k==23 || uint8_t(*line)<32 || uint8_t(*line)>126)return c;tokens[n][k++]=*line++;}n++;
 }
 if(n==1 && strcmp(tokens[0],"status")==0)c.kind=CommandKind::Status;
 else if(n==2 && strcmp(tokens[0],"close")==0 && strcmp(tokens[1],"rail-off")==0)c.kind=CommandKind::Close;
 else if(n==5 && strcmp(tokens[0],"bus")==0 && strcmp(tokens[3],"rail-off")==0 && strcmp(tokens[4],"one-servo")==0 && unsignedToken(tokens[1],c.rx) && unsignedToken(tokens[2],c.tx) && c.rx>=4 && c.rx<=7 && c.tx>=4 && c.tx<=7 && c.rx!=c.tx)c.kind=CommandKind::Bus;
 else if(n>=2 && unsignedToken(tokens[1],c.id) && c.id>=1){
  if(n==2 && strcmp(tokens[0],"ping")==0)c.kind=CommandKind::Ping;
  else if(n==2 && strcmp(tokens[0],"feedback")==0)c.kind=CommandKind::Feedback;
  else if(n==4 && strcmp(tokens[0],"off")==0 && strcmp(tokens[2],"supported")==0 && strcmp(tokens[3],"one-servo")==0)c.kind=CommandKind::Off;
 }
 return c;
}
inline const char* faultName(Fault f){switch(f){case Fault::None:return "NONE";case Fault::InvalidId:return "INVALID_ID";case Fault::Send:return "SEND";case Fault::Timeout:return "TIMEOUT";case Fault::Length:return "LENGTH";case Fault::Checksum:return "CHECKSUM";case Fault::WrongId:return "WRONG_ID";case Fault::Device:return "DEVICE_ERROR";case Fault::Noise:return "NOISE";case Fault::NotOff:return "TORQUE_OFF_UNCONFIRMED";}return "UNKNOWN";}
}
