#include "st3215_bench.h"
#include <vector>
#include <cstdio>
#include <cstdlib>
#include <initializer_list>
using namespace st3215;
unsigned checks=0;
void check(bool ok,const char* label){++checks;if(!ok){std::fprintf(stderr,"FAIL %s\n",label);std::exit(1);}}
std::vector<uint8_t> frame(unsigned id,std::vector<uint8_t> data={},uint8_t error=0){
 std::vector<uint8_t> b={255,255,uint8_t(id),uint8_t(data.size()+2),error};b.insert(b.end(),data.begin(),data.end());uint8_t sum=0;for(size_t i=2;i<b.size();++i)sum=uint8_t(sum+b[i]);b.push_back(uint8_t(~sum));return b;
}
struct IO {
 uint32_t clock=0;bool sendOK=true;size_t cursor=0,script=0;
 std::vector<std::vector<uint8_t>> responses,sent;std::vector<uint8_t> active;
 void clear(){active.clear();cursor=0;}
 bool send(const uint8_t* p,size_t n){sent.emplace_back(p,p+n);active=script<responses.size()?responses[script++]:std::vector<uint8_t>{};cursor=0;return sendOK;}
 int next(){return cursor<active.size()?active[cursor++]:-1;}
 uint32_t now(){return clock;}void wait(unsigned n){clock+=n;}
};
int main(){
 Packet p;
 const std::vector<std::vector<uint8_t>> golden={{255,255,1,2,1,251},{255,255,1,4,2,56,15,177},{255,255,1,4,2,40,1,207},{255,255,1,4,3,40,0,207}};
 unsigned n=0;for(Request r:{Request::Ping,Request::Feedback,Request::TorqueState,Request::TorqueOff}){check(makePacket(r,1,p),"packet accepted");check(std::vector<uint8_t>(p.data,p.data+p.size)==golden[n++],"exact manufacturer-format packet");}
 for(unsigned id:{0u,254u,255u,999u}){check(!makePacket(Request::Ping,id,p)&&p.size==0,"invalid ID");IO io;Feedback f;f.valid=true;check(feedback(io,id,f)==Fault::InvalidId&&!f.valid&&io.sent.empty(),"invalid feedback no traffic");check(torqueOff(io,id)==Fault::InvalidId&&io.sent.empty(),"invalid off no traffic");}
 makePacket(Request::Ping,1,p);
 auto run=[&](std::vector<uint8_t> bytes,Fault expected,const char* label){IO io;io.responses={bytes};Reply out;out.id=88;check(exchange(io,p,out)==expected,label);check(expected==Fault::None?out.id==1:out.id==0,"reply never stale");};
 run({255,255,1,2,0,252},Fault::None,"golden ping reply");
 run({0,12,255,1,255,255,255,1,2,0,252},Fault::None,"noise and repeated header");
 auto b=frame(1);b.back()^=1;run(b,Fault::Checksum,"bad checksum");
 run(frame(2),Fault::WrongId,"wrong ID");run(frame(1,{},4),Fault::Device,"device error");run(frame(1,{0}),Fault::Length,"wrong payload length");
 for(uint8_t length:{0,1,18,255})run({255,255,1,length},Fault::Length,"invalid frame length");
 run({},Fault::Timeout,"no reply");run({255,255,1,2,0},Fault::Timeout,"truncated reply");run(std::vector<uint8_t>(129,0),Fault::Noise,"bounded noise");
 IO wrap;wrap.clock=0xfffffff0;Reply out;check(exchange(wrap,p,out)==Fault::Timeout&&wrap.clock==9,"timeout across clock wrap");
 IO fail;fail.sendOK=false;check(exchange(fail,p,out)==Fault::Send,"send failure");
 Decoder d;for(uint8_t byte:frame(1))d.push(byte);check(!d.push(12)&&d.reply.id==1,"completed decoder bounded");
 std::vector<uint8_t> data={0,8,100,128,200,4,120,35,0,0,1,0,0,30,128};
 IO io;io.responses={frame(1,data),frame(1,{0})};Feedback f;
 check(feedback(io,1,f)==Fault::None&&f.valid,"fresh feedback");
 check(f.position==2048&&f.speed==-100&&f.load==-200&&f.current==-30,"signed magnitude fields");
 check(f.voltageTenths==120&&f.temperature==35&&f.moving==1&&f.torque==0,"feedback offsets");
 check(io.sent==std::vector<std::vector<uint8_t>>{golden[1],golden[2]},"feedback and torque requests only");
 IO bad;bad.responses={frame(1,data),frame(1,{1},8)};check(feedback(bad,1,f)==Fault::Device&&!f.valid&&f.position==0,"second read failure invalidates sample");
 IO off;off.responses={frame(1),frame(1,{0})};check(torqueOff(off,1)==Fault::None,"off ACK drained readback");check(off.sent==std::vector<std::vector<uint8_t>>{golden[3],golden[2]},"only torque zero write");
 IO noack;noack.responses={{},frame(1,{0})};check(torqueOff(noack,1)==Fault::None,"off without write ACK");
 IO on;on.responses={{},frame(1,{1})};check(torqueOff(on,1)==Fault::NotOff,"off not confirmed");
 IO timeout;check(torqueOff(timeout,1)==Fault::Timeout,"off timeout");
 check(magnitude(32768,15)==0&&magnitude(32767,15)==32767&&magnitude(65535,15)==-32767,"signed boundaries");
 for(const char* command:{"status","close rail-off","bus 4 5 rail-off one-servo","ping 1","feedback 253","off 1 supported one-servo"})check(parseCommand(command).kind!=CommandKind::Invalid,"supported command");
 for(const char* command:{"","move 1 2000","enable 1","arm 1","ping 0","ping 254","ping -1","ping 1 extra","feedback 1x","off 1","off 1 supported","off 1 supported two-servos","bus 4 4 rail-off one-servo","bus 3 5 rail-off one-servo","bus 4 8 rail-off one-servo","bus 4 5 rail-on one-servo","bus 4 5 rail-off one-servo extra","close","status extra","ping 99999999999999999999999999"})check(parseCommand(command).kind==CommandKind::Invalid,"unsafe or malformed command rejected");
 std::printf("PASS %u checks\n",checks);
}
