#include "../src/main.cpp"
#include <cstdlib>
unsigned checks=0;
void check(bool ok,const char* label){++checks;if(!ok){std::fprintf(stderr,"FAIL %s\n",label);std::exit(1);}}
void line(const std::string& text){Serial.input.assign(text.begin(),text.end());loop();}
int main(){
 setup();check(!busEnabled&&servo.begins==0&&servo.sent.empty(),"startup no UART or traffic");
 runCommand("feedback 1");check(servo.sent.empty()&&Serial.output.find("ERR BUS_DISABLED")!=std::string::npos,"closed bus blocks requests");
 runCommand("bus 4 5 rail-off one-servo");check(busEnabled&&servo.begins==1&&servo.sent.empty(),"explicit bus begin no request");
 runCommand("bus 6 7 rail-off one-servo");check(servo.begins==1,"cannot reconfigure live bus");
 runCommand("move 1 2048");runCommand("off 1");check(servo.sent.empty(),"invalid commands no traffic");
 sample.valid=true;line(std::string(100,'x')+"\n");check(!sample.valid&&servo.sent.empty(),"overflow no traffic and sample invalid");
 line(std::string("ping 1\0ignored\n",15));check(servo.sent.empty(),"binary input rejected");
 runCommand("feedback 1");check(!sample.valid&&lastFault==Fault::Timeout&&servo.sent.size()==1,"timeout no valid sample");
 runCommand("close rail-off");check(!busEnabled&&servo.ends==1,"explicit close");
 runCommand("ping 1");check(servo.sent.size()==1,"closed bus blocks traffic after close");
 std::printf("PASS %u console checks\n",checks);
}
