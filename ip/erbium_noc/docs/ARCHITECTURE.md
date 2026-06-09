# Architecture

`erbium_noc` is a non-coherent AXI4/APB4 network-on-chip: 2 initiators, 9 targets,
4 asynchronous clock domains.

## Block diagram

```
 S_CPU (512b, CPU 1GHz)          S_XSPI (64b, XSPI 200MHz)
    | AXI4                          | AXI4
 [remap_cpu]                     [cdc XSPI->CPU] -> [upsize 64->512] -> [remap_xspi]
    |                                |
    +------------ 512b crossbar (routes by target id) ----------+
       |        |        |        |        |        |       |     |        |
   excl-mon  excl-mon                                             (decode err -> DECERR)
   M_MRAM   M_SRAM*  M_CPU_REG M_MRAM_REG M_SYS_REG* M_SPI*  M_UART* M_XSPI*  M_I2C(APB4)*  GPV@cfg
   (512b)   (64b)    (64b)     (64b)      (64b)      (64b)   (64b)   (64b)    (32b)
   * = leg in a non-CPU clock domain, bridged with an async CDC; 64b/32b legs
       reach the 512b fabric through a width converter.
```

## Initiators

| Port | Data | Addr | ID (R/W) | Clock domain |
|---|---|---|---|---|
| `AXI_SLAVE_S_CPU`  | 512b | 32b | 8 / 8 | CPU |
| `AXI_SLAVE_S_XSPI` | 64b  | 32b | 1 / 1 | XSPI |

`S_CPU` issues AXI exclusive accesses (ARLOCK/AWLOCK) to MRAM/SRAM.

## Targets

| Port | Protocol | Data | Clock domain |
|---|---|---|---|
| `AXI_MASTER_M_MRAM`       | AXI4 | 512b | CPU |
| `AXI_MASTER_M_CPU_REG`    | AXI4 | 64b  | CPU |
| `AXI_MASTER_M_MRAM_REG`   | AXI4 | 64b  | CPU |
| `AXI_MASTER_M_SYSTEM_REG` | AXI4 | 64b  | SYSTEM |
| `AXI_MASTER_M_SRAM`       | AXI4 | 64b  | SYSTEM |
| `AXI_MASTER_M_SPI_REG`    | AXI4 | 64b  | PERIPH |
| `AXI_MASTER_M_UART_REG`   | AXI4 | 64b  | PERIPH |
| `AXI_MASTER_M_XSPI`       | AXI4 | 64b  | XSPI |
| `APB_MASTER_M_I2C_REG`    | APB4 | 32b  | PERIPH |

The master-port AXI ID width is 9 bits.

## Clocks

| Clock | Period | Frequency |
|---|---|---|
| `CPU_CLK`    | 1.000 ns | 1000 MHz |
| `SYSTEM_CLK` | 4.000 ns |  250 MHz |
| `XSPI_CLK`   | 5.000 ns |  200 MHz |
| `PERIPH_CLK` | 8.000 ns |  125 MHz |

All four are mutually asynchronous; each has its own active-low reset
(`<DOM>_RESETn`) synchronized into its domain. The crossbar and width converters
run in the CPU domain; any interface in another domain crosses through an async
CDC.

## Address map (per initiator)

Each initiator has its own region table; both are decoded into one canonical
internal map. The configuration / discovery block is common at
`0xFE00_0000`.

### `S_CPU`

| Range | Size | Target |
|---|---|---|
| `0x0200_0000 – 0x0200_0FFF` | 4 KB | M_SYSTEM_REG |
| `0x0200_1000 – 0x0200_1FFF` | 4 KB | M_MRAM_REG |
| `0x0200_2000 – 0x0200_2FFF` | 4 KB | M_I2C_REG (APB4) |
| `0x0200_3000 – 0x0200_3FFF` | 4 KB | M_SPI_REG |
| `0x0200_4000 – 0x0200_4FFF` | 4 KB | M_UART_REG |
| `0x0200_8000 – 0x0200_CFFF` | 20 KB | M_SRAM |
| `0x0200_F000 – 0x0200_FFFF` | 4 KB | M_XSPI |
| `0x4000_0000 – 0x7FFF_FFFF` | 1 GB | M_MRAM |
| `0x8000_0000 – 0xBFFF_FFFF` | 1 GB | M_CPU_REG |
| `0xFE00_0000 – 0xFE01_5FFF` | ~88 KB | Discovery |

### `S_XSPI`

| Range | Size | Target |
|---|---|---|
| `0x0000_0000 – 0x3FFF_FFFF` | 1 GB | M_MRAM |
| `0x4000_0000 – 0x4000_0FFF` | 4 KB | M_SYSTEM_REG |
| `0x4000_1000 – 0x4000_1FFF` | 4 KB | M_MRAM_REG |
| `0x4000_2000 – 0x4000_2FFF` | 4 KB | M_I2C_REG (APB4) |
| `0x4000_3000 – 0x4000_3FFF` | 4 KB | M_SPI_REG |
| `0x4000_4000 – 0x4000_4FFF` | 4 KB | M_UART_REG |
| `0x4000_8000 – 0x4000_CFFF` | 20 KB | M_SRAM |
| `0x8000_0000 – 0xBFFF_FFFF` | 1 GB | M_CPU_REG |
| `0xFE00_0000 – 0xFE01_5FFF` | ~88 KB | Discovery |

The map is static. Unmapped addresses return DECERR.

## Sideband

Per-domain low-power **Q-Channel** (`<DOM>_QACTIVE/QREQn/QACCEPTn/QDENY`) and a
single-domain **P-Channel** (`PD_0_*`); debug-authentication
(`<DOM>_SPIDEN/NIDEN/DBGEN/SPNIDEN`), PMU snapshot, per-port `*_AWAKEUP`,
`DFT*DISABLE`, and `ECOREVNUM` are exposed at the boundary.

## Verification

The testbench (`tb/`, run via `flow/run.sh`) exercises 4 asynchronous clocks and
checks: per-target routing, both per-initiator address maps, decode error on
unmapped, the discovery read, the full load-linked/store-conditional exclusive
sequence (EXOKAY on success, OKAY + squashed store on failure), clock-domain
crossings, a multi-beat burst, and the Q/P-Channel handshakes — 17 checks, all
passing under Verilator.
