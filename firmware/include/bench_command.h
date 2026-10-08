#pragma once
#include <stdint.h>
#include <string.h>
namespace bench {
enum class Command { Invalid, Status, Disarm, Reset, Keepalive, Arm, Pulse, Timing, Voltage };
struct ParsedCommand { Command command; uint16_t value; };
inline bool parseNumber(const char* text,uint16_t& value) {
  if(!*text) return false;
  unsigned n=0;
  for(;*text;++text) {
    if(*text<'0'||*text>'9') return false;
    n=n*10+unsigned(*text-'0'); if(n>65535) return false;
  }
  value=uint16_t(n); return true;
}
inline ParsedCommand parseCommand(const char* text) {
  if(strcmp(text,"status")==0)return {Command::Status,0};
  if(strcmp(text,"disarm")==0)return {Command::Disarm,0};
  if(strcmp(text,"reset")==0)return {Command::Reset,0};
  if(strcmp(text,"keepalive")==0)return {Command::Keepalive,0};
  if(strcmp(text,"timing rail-off no-servos")==0)return {Command::Timing,0};
  if(strcmp(text,"voltage rail-off no-servos")==0)return {Command::Voltage,0};
  uint16_t n=0;
  if(strncmp(text,"arm ",4)==0 && parseNumber(text+4,n) && n<3)return {Command::Arm,n};
  if(strncmp(text,"pulse ",6)==0 && parseNumber(text+6,n))return {Command::Pulse,n};
  return {Command::Invalid,0};
}
}
