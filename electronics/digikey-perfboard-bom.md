> Superseded MG996R/PWM design reference. Active design is ST3215 12V with3S power; see README.md,docs/st3215-leg-build.md and electronics/st3215-power-plan.md. These quantities,interfaces and mass estimates are not the current ST3215 design.

# DigiKey perfboard population shortlist — ELEC-007

Initial prototypes use isolated-pad perfboard. SMT is deferred until the
prototype works; DigiKey is the preferred supplier. This list populates the
complete 12-channel buffer carrier, not the motor-power distribution.
Parts remain PROVISIONAL and no order has been placed.

## Parts and quantity-adjusted cost

NZD reference prices checked from public DigiKey NZ listings/search snapshots
on 2026-10-09. Some pages could not be fetched directly and cached prices vary;
these are planning references, not a live quotation or stock reservation.
Prices exclude GST and shipping. Recheck the linked product and cart before
ordering. Reuse suitable existing parts and subtract them from these totals.

| Item | Manufacturer part | DigiKey number / public listing | Needed | Suggested pack quantity | Reference unit NZ$ | Extended NZ$ |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| Quad buffer, PDIP14 | TI SN74AHCT125N | [296-4655-5-ND](https://www.digikey.co.nz/en/products/detail/texas-instruments/SN74AHCT125N/375798) | 3 | 3 | 1.69 | 5.07 |
| DIP14 socket | Assmann A 14-LC-TT | [AE9989-ND](https://www.digikey.co.nz/en/products/detail/assmann-wsw-components/A-14-LC-TT/821743) | 3 | 3 | 1.01 | 3.03 |
| 220 ohm axial resistor | Stackpole CF18JT220R | [CF18JT220RCT-ND](https://www.digikey.co.nz/en/products/detail/stackpole-electronics-inc/CF18JT220R/1741639) | 13 | 25 | 0.0352 | 0.88 |
| 10k ohm axial resistor | Stackpole CF18JT10K0 | [CF18JT10K0CT-ND](https://www.digikey.co.nz/en/products/detail/stackpole-electronics-inc/CF18JT10K0/1741566) | 24 | 25 | 0.0348 | 0.87 |
| 1k ohm axial resistor | Stackpole CF18JT1K00 | [CF18JT1K00CT-ND](https://www.digikey.co.nz/en/products/detail/stackpole-electronics-inc/CF18JT1K00/1741612) | 1 | 1 | 0.18 | 0.18 |
| 100nF radial capacitor | KEMET C322C104K5R5TA | [399-4329-ND](https://www.digikey.co.nz/en/products/detail/kemet/C322C104K5R5TA/818105) | 3 | 3 | 1.57 | 4.71 |
| Isolated-pad perfboard | BusBoard PAD2 | [4526-PAD2-ND](https://www.digikey.co.nz/en/products/detail/busboard-prototype-systems/PAD2/19200351) | 1 | 1 | 13.64 | 13.64 |
| Breakaway 40-pin male strip | Sullins PRPC040SAAN-RC | [S1011EC-40-ND](https://www.digikey.co.nz/en/products/detail/sullins-connector-solutions/PRPC040SAAN-RC/2775214) | 41 header positions | 2 strips | 2.22 | 4.44 |

Reference component subtotal **NZ$32.82 excluding GST/shipping**, or **NZ$37.74
with 15% GST before shipping**. Allow about NZ$40 before shipping for these
components; this is not the complete harness or robot cost. No expensive
regulator, battery or motor connector is selected by this list. Insulated
hookup wire, solder, insulation, removable mounting supports and mating signal
leads are additional/reusable workshop items, not included in this subtotal.
Listings indicated available stock when indexed; confirm availability at checkout.

For just the first one-servo bench, do not buy all three buffer blocks unless
wanted for later: retain its existing small harness and staged testing plan.
The quantity-25 resistor packs provide inexpensive spares; no reel is required.

## Compatibility check

- SN74AHCT125N is the through-hole AHCT device already specified by the harness:
  PDIP14, 2.54mm pin pitch, 7.62mm row spacing. Its 4.5–5.5V supply range
  covers the provisional switched 5.2V rail with 5.3V maximum. TTL input levels
  accept 3.3V logic. Keep the common active-low OE wiring and chip orientation.
  [TI primary datasheet](https://www.ti.com/lit/ds/symlink/sn74ahct125.pdf).
- A 14-LC-TT has 14 pins, 2.54mm pitch and 7.62mm row spacing, matching the
  layout. Socket bodies/notches must still be dry fitted; no physical clearance
  is claimed. [Assmann primary product data](https://www.assmann-wsw.com/us/product/a-14-lc-tt/).
- CF18 resistors are 1/8W, 5%, axial, nominal 3.3mm long by 1.7mm diameter.
  Their small bodies suit adjacent 2.54mm rows and 10.16mm formed lead span.
  Normal worst pull-down dissipation is under 3mW at 5.3V; the 1k pull-up
  dissipates about 11mW at 3.3V. Series parts carry signal current, not motor
  current. This is a normal-operation rating check, not a short-circuit test.
  [Stackpole primary catalog, CF series](https://www.seielect.com/catalog/sei-catalog.pdf).
- C322C104K5R5TA is 100nF, 50V, X7R, 10%, with 5.08mm formed lead spacing.
  Its nominal body is 5.08 x3.18mm, maximum seated height 6.60mm. The two-row
  spacing matches C1..C3; keep local decoupling wires short.
  [KEMET primary Goldmax datasheet](https://yageogroup.com/content/datasheet/asset/file/KEM_C1050_GOLDMAX_X7R).
- PAD2 is 100 x80 x1.6mm FR4, with a 31 x39 hole pattern on 2.54mm pitch,
  double-sided isolated pads and 0.94mm holes. Orient the 39-hole dimension
  horizontally for the logical 35 x25 layout. Reserve **100 x80mm**, rather
  than the earlier generic 100 x70mm estimate. Choose a usable central grid
  origin during dry fit, avoiding its four corner mounting holes. The published
  pattern fits the required grid count; actual pad/body/mount clearance remains
  untested. No cutting or chassis adoption is required by this shortlist.
  [BusBoard primary data](https://www.busboard.com/PAD2),
  [datasheet](https://www.busboard.com/documents/datasheets/BPS-DAT-%28PAD2%29-Datasheet.pdf).
- PRPC040SAAN-RC is a single-row, straight through-hole, breakaway 2.54mm header.
  Cut 3 x6 input, 3 x4 output, 3 x3 supply and 1 x2 CTRL sections: **41 positions**.
  The supply sections use the two outer pins, 5.08mm apart; remove the centre
  pin and leave its pad unwired. One 40-pin strip is insufficient. Use the
  supplier's linked Sullins drawing to check the purchased lead/body variant,
  then dry fit in the 0.94mm holes. These unkeyed headers need clear polarity
  labels and suitable matching female leads. Their use is limited to signals,
  logic reference and buffer supply; no servo motor current goes through them.

The original pad coordinates, net endpoints and 12 signal chains are unchanged.
Existing independent checker: `node electronics/check-buffer-perfboard.mjs`.
No physical fit, soldering, powered operation or final SMT footprint is verified.

## Later SMT revision

Retain the same functional netlist and enable behavior as the starting point.
After measurements, consider SOIC AHCT125 and commodity SMT resistors/capacitors
on a simple PCB. Recheck package pinouts, decoupling, connector placement and
actual current paths then. Do not copy the PDIP placement as a PCB footprint.
