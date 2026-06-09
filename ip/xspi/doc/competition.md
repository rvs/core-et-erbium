# PSRAM Vendors

## ISSI, Integrated Silicon Solution Inc
8D-8D-8D mode
has configuration register similar to hyperbus.

## Commands

| CMD                                | B0      | B1  |
| ---                                | ---     | --- |
| Memory READ with continuous burst  | A0h     | 00h |
| Memory READ with wrapped burst     | 80h     | 00h |
| Memory WRITE with continuous burst | 20h     | 00h |
| Memory WRITE with wrapped burst    | 00h     | 00h |
| Configuration Register READ        | C0h/E0h | 00h |
| Configuration Register WRITE       | 40h/60h | 00h |
| Preamble READ                      | F0h     |     |

## Winbond

Has only hyperbus devices for PSRAM some devices have 16 bit DQ (e.g. W959D6NFKX).
Did not find mention of spi/qspi/octal in the few documents I read. i.e. no xspi features.

## Infineon
Has hyperbus only and xspi devices.
Has an optional feature called DCARS which provides an additional phase shifted.clock for Read
