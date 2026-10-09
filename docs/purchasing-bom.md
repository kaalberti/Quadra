# Buying BOM — active ST3215 /3S design
Last updated:2026-10-09

Buy/test one actuator first; the working leg needs three. User-selected12V
ST3215 replaces MG996R. Old MG996R manufacturing hardware and AHCT/PCA buffer
parts are no longer the active leg purchase list. DigiKey preferred for standard
electronics; actuator-specific parts may need Waveshare/compatible suppliers.

| Item | First trial /leg | Full robot | Selection /cost |
| --- | ---: | ---: | --- |
| ST3215 standard12V/30 kg.cm bus servo |1 then3|12|Selected model; landed NZD quote TBD |
| Compatible front/rear wheels |2/6|24|Verify supplied kit and rear-support behavior |
| Wheel retaining/mounting screws |Kit,up to24 per leg plus centres|Up to96 plus centres|Thread/length TBD; use supplied correct hardware |
| TTL half-duplex bus adapter |1|1 initially|Waveshare Bus Servo Adapter A candidate; no all-servo power through it |
| Servo bus cables and power-injection harness |For1 then3|12 joints|Actual pinout/current rating and lengths TBD |
| Conventional3S60 Wh LiPo |Not needed for PSU trial|1|User access; 120 x50 x20 mm assumed;mass,connector,discharge rating TBD |
|3S-compatible balance charger |1|1|Needed if not already available; model/cost TBD |
| Main fuse/holder and servo disconnect |Bench protection then robot kit|1 each|Rated and coordinated with real pack/wires; value TBD |
| Parallel power distribution and branch protection |For one leg|4 legs|40A main capacity screen; actual ratings TBD |
|3S-to5V logic buck |USB initially|1|Module/current capability TBD; DigiKey preferred |
| Cell-voltage monitor/alarm |Before battery use|1|3S balance connector compatible; part TBD |
| M3x60 through bolts/plain nuts |4 each per leg|16 each|Provisional J1/J2 mounting stacks |
| M3x65 through bolts/plain nuts |2 each per leg|8 each|Provisional J3 fork/clamp stack |
| M3 ordinary washers |12 external+4 internal per leg|64|Internal0.5 mm assumed; check actual stack |
| J1 fixture/chassis through bolts/nuts |4|16|Length depends on fixture/chassis; TBD |
| Rubber/EVA foot pads |1|4|20 x56 mm cheap replaceable contact; attachment to suit |
| Printed ST3215 parts |16|Robot count not released|Use docs/st3215-leg-build.md |

Owned:ESP32-S3 N16R8,Adafruit PCA9685 (unused for current leg control),multimeter,
load cells,60V/5A adjustable supply,and Creality K2 Pro access. Battery access is
reported; no specific pack checked. No actuator,horn or bearing ownership assumed.

Waveshare lists ST3215 familyUS$16.99–21.99 depending variant: twelveUS$203.88–
263.88 before shipping,GST/conversion. This is a family price screen,not a12V
variant checkout quote. Budget targetNZ$500–800 total,ceilingNZ$1000 remains.
Servo targetNZ$25–35 each; flag actual landed pricing aboveNZ$50 or significant
budget changes before purchase. No order or supplier contact authorized here.
https://www.waveshare.com/product/st3215-servo.htm

Deferred sensor buys:one 6-axis IMU,voltage/current sensing,and forwardToF sensor.
Choose modules when those bounded stages begin; no full navigation kit purchase.

Battery mount:one st3215-battery-tray.stl,two15 mm reusable straps (>=250 mm),1 mm soft padding,and fourM3 fixture bolts of length to suit eventual chassis. Tray layout provisional; pack actual fit untested.
