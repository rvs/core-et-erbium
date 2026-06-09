# Research Notes
## Winbond PSRAM
The subset of winbond PSRAM analysed support Hyperbus1/2/3 only, there is no support for SPI/QSPI/OSPI mode.
## Potential Standards Involved

JESD has the following standard related to the SPI family
 
| Standard                                                                       | Code                     | Status  |
| -------                                                                        | ---                      | ---     |
| EXPANDED SERIAL PERIPHERAL INTERFACE (xSPI) FOR NONVOLATILE MEMORY DEVICES     | JESD251C	May 2022 | Read    |
| Serial Flash Discoverable Parameters (SFDP)                                    | JESD216H	Aug 2025 | Skimmed |
| Addendum No. 1 to JESD251 - OPTIONAL x4 QUAD I/O WITH DATA STROBE              | JESD251-1.01 Sep 2021    | Read    |
| Secure Serial Flash Bus Transactions Release Number: Version 1.0               | JESD254	Dec 2022         | TBD     |
| SPI Safety Extensions (CRC) for Non Volatile SPI Flash Memories (QPI and xSPI) | JESD255	Mar 2024         | TBD     |
| Inband Reset                                                                   | JESD252                  |         |

Note: These standards are by the serial flash working group. The standard consists of flash specific stuff which are not applicable to RAM/NV-RAM.

## Standard Overview
 
## 251C

* Describes x1,x8 SDR and DDR interfaces with 3 profiles, 1S-1S-1S(Legacy SPI), 8D-8D-8D (HB1) and 8D-8D-8D(Octal SPI)
* It lists a minimal set of commands that need to be implemented and makes reference to 216H.

## 251-1.01

* Adds support for x4 SDR and DDR.
* Differences with base spec are:
   * The x4 option uses a single 8-bit byte for the Command whereas the x8 option requires two 8-bit bytes (Word) for the Command.
   * The x4 option uses a slightly different command protocol: The x8 option uses DDR mode for Commands, Address, and Data while the x4 option uses SDR mode for Commands and DDR mode for Address and Data.

## 216H

* Is an information dense document filled will tables of configuration parameters. Detailed review will be required to identify the sections relevant to RAM.

## 254 and 255

Ignoring these for the timebeing unless there is a specific requirement for components from these standards.

# Device Features

* Input/Output Power Supplies Options: 1.2 V, 1.8 V, or 3 V
* Data width: 1, 4 8
* Rate: SDR, DDR
* SDR & DDR modes of operation:
	* 1S-1S-1S
	* 4S-4D-4D
	* 8D-8D-8D (Profile 2)
	* 8D-8D-8D (Profile 2, HB)
* Default mode at bootup controlled via 2 pins:
	* 00: SPI Mode
	* 01: QSPI Mode
	* 10: Hyperbus mode
	* 11: Octal SPI mode
* Reset options POR, Inband, Separate signal
* Deep Power down
* In 1X mode Bit0 is from controller to target, Bit1 is from target to controller. MSB First.
* In 8X mode LSB on bit 0 and MSB on bit 7
* Command Modifier sends highest byte first.
* DS can be used as Read clock.
* upto 12pF capacitance on each line.

*PNR Team should read chapter 8 for IO timing specification*

# Implementation

3 layers of implementation

1. IO layer which take in the 1S/8D signal and provides 16 bit output.
2. Protocol layer which separates out the command, modifier and data
3. SFDP layer which decodes the commands and puts our transactions on AXI bus.

# SFDP Specification

This document is a 200 page dense spec filled with tables for each command. We will have to review this carefully and select the subset we want to implement.
I recommend starting with sec6.9 of xspi spec and then moving to SFDP spec.

## Overview

* The database consists of one SFDP Header(8 bytes) followed by 1 or more parameter header(8 bytes each).
* Each parameter header contains a pointer to Parameter table and id field which defines the type of parameter table
* The types are Vendor Specific, Function Specific(vendor), Function Specific(JEDEC), Basic Parameter Table.
* A fees of around 800 USD is required to be assigned a vendor id if we want to implement Vendor Specific Table.
* The default(basic) parameter table has twenty three 32-bit words. Specifying the operations supported and the instructions for each operation.
* SPI/QSPI/Octal-SPI has a 3 or 4 byte address, supporting 3 byte address may require remapping MRAM to fit in this region.
* The document states that host needs to implement profile 1 and 2 but target is free to implement only 1. I recommend profile 2 as it supports octal and hyperbus and is more suitable for RAM application
* There are registers declaring the instruction value, this can be informative to the host(i.e. readonly) or host can be allowed to change the registers to implement a different instruction set.


## Modes mentioned in the doc
* 
* 1S-1S-1S -- SPI
* 1S-1S-4S -- Quad WB
* 1S-4S-4S -- Quad WB
* 4S-4S-4S -- Quad ??
* 8D-8D-8D -- Octal
* 1S-1S-8S -- Octal
* 1S-8S-8S -- Octal
* 8D-8D-8D -- HB1
* Ignoring 2S modes.

## 6.3.3.1

Function Specific Parameter table id assignments

| ID   | Function                                                |
| ---  | -------                                                 |
| FF00 | Basic SPI                                               |
| FF05 | xSPI Profile 1                                          |
| FF06 | xSPI Profile 2                                          |
| FF87 | CSR (Status, Control and Configuration Register map     |
| FF09 | CSR for xSPI Profile 2.0                                |
| FF0A | Command Sequences to change to Octal DDR (8D) mode      |
| FF0C | x4 Quad IO with DS                                      |
| FF8D | Command Sequences to change to Quad DDR (4S-4D-4D) mode |
| FF0F | Generic Register Access Method (GRAM)                   |

# 6.4.x
# Modes

* 1S-1S-4S
* 1S-4S-4S
* 1S-2S-2S
# 6.4.6
1s-1s-4s and 1s-4s-4s
Does `(1S-1S-4S) Fast Read Instruction` mean whatever is written here will be the opcode for fast read?
6.4.7 is same as 6.4.6 for 1S-2S-2S and 1s-1s-2s
6.4.8 4s-4s-4s and 2s-2s-2s
6.4.9 2s-2s-2s
6.4.10 4s-4s-4s
6.4.11 Erase type 1 and 2 instructions and size --ignore
6.4.12 Erase type 3 and 4 instructions and size --ignore
6.4.13 Erase type 4, 3, 2, 1 typical timing --ignore
6.4.14 chip erase/ byte program/page program timing --ignore
6.4.15 suspend resume erase program --ignore
6.4.16 suspend resume instruction --ignore
6.4.17 deep powerdown mode --implement
6.4.18 mode enable/exit --implement
6.4.19 enter/exit 4byte addressing, soft reset/rescue sequence, volatile nv wr en
6.4.20 1S-1S-8S similar to 6.4.7
6.4.21 8D stuff
6.4.22 8S stuff
6.4.23 operating freq 4s,4d,8s,8d modes
6.4.24 instructions supported --implement
6.4.25 2D, 1D stuff
6.4.26 4D stuff
6.5.x sector map --not implemented.
6.6.x Replay protected monotonic counters -- not implemented
6.7.x 4 byte Addressing (memories greater than 16MB)
Document says controller should support both profile but targets might support only one
6.8.x xspi profile 1.0 -- not implemented 
6.9.x xspi Profile 2.0 -- implemented

Check Everspin
Focus on PSRAM from other vendors.


