#pragma once
#include <stdint.h>
namespace bench {
constexpr uint8_t Address=0x40, Sda=4, Scl=5, Oe=6;
constexpr uint32_t OscillatorHz=25000000, TimeoutMs=1500, HealthPeriodMs=100;
constexpr uint8_t Prescale=121; // round(25MHz / (4096 * 50Hz)) - 1
constexpr uint16_t MinPulseUs=1450, CenterPulseUs=1500, MaxPulseUs=1550;
constexpr uint8_t Channels=3;
constexpr uint8_t TimingInput=7,TimingChannel=15;
constexpr uint32_t TimingWaitUs=50000;
constexpr uint16_t pulseTicks(uint16_t us) {
  return uint16_t((uint64_t(us)*OscillatorHz + uint64_t(Prescale+1)*500000) /
                  (uint64_t(Prescale+1)*1000000));
}
}
