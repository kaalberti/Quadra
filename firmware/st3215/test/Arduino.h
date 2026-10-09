#pragma once
#include <stdint.h>
#include <stddef.h>
#include <vector>
#include <string>
#include <cstdio>
#define SERIAL_8N1 0
inline uint32_t fakeClock=0;
inline uint32_t millis(){return fakeClock;}
inline void delay(unsigned n){fakeClock+=n;}
class HardwareSerial {
public:
 unsigned begins=0,ends=0;std::vector<uint8_t> input;std::vector<std::vector<uint8_t>> sent;std::string output;
 explicit HardwareSerial(int=0){}
 void begin(unsigned,int=0,int=-1,int=-1){++begins;}
 void end(){++ends;}void flush(){}
 int available(){return int(input.size());}
 int read(){if(input.empty())return -1;int v=input.front();input.erase(input.begin());return v;}
 size_t write(const uint8_t* b,size_t n){sent.emplace_back(b,b+n);return n;}
 void println(const char* s){output+=s;output+='\n';}
 template<class... A>void printf(const char* format,A... args){char b[1024];std::snprintf(b,sizeof(b),format,args...);output+=b;}
};
inline HardwareSerial Serial;
