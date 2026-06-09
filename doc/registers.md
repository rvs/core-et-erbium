<!---
Markdown description for SystemRDL register map.

Don't override. Generated from: Erbium_CPU
  - top.rdl
-->

# Erbium_CPU address map

- Absolute Address: 0x0
- Base Offset: 0x0
- Size: 0x200312C

|  Offset |     Identifier     |        Name        |
|---------|--------------------|--------------------|
|0x2000000|  system_registers  |  System Registers  |
|0x2001000|   mram_registers   | MRAM Test Registers|
|0x2002000|peripheral_registers|peripheral registers|
|0x2003000| hyperbus_registers |      HyperRAM      |

## system_registers address map

- Absolute Address: 0x2000000
- Base Offset: 0x2000000
- Size: 0x8C

<p>Register Controlling System Behavior</p>

|Offset|      Identifier     |Name|
|------|---------------------|----|
| 0x00 |       Version       |  — |
| 0x08 |     SystemConfig    |  — |
| 0x10 |    WATCHDOG_COUNT   |  — |
| 0x18 |       Watchdog      |  — |
| 0x20 |     SysInterrupt    |  — |
| 0x28 |      SoftReset      |  — |
| 0x30 |      ResetCause     |  — |
| 0x38 |    PowerDomainReq   |  — |
| 0x40 |    PowerDomainAck   |  — |
| 0x48 |      PowerGood      |  — |
| 0x50 |       SpinLock      |  — |
| 0x58 |       ChipMode      |  — |
| 0x60 |       Mailbox0      |  — |
| 0x68 |       Mailbox1      |  — |
| 0x70 |       GPIO_OE       |  — |
| 0x78 |        GPIO_I       |  — |
| 0x80 |        GPIO_O       |  — |
| 0x88 |GPIO_Interrupt_Enable|  — |

### Version register

- Absolute Address: 0x2000000
- Base Offset: 0x0
- Size: 0x4

<p>Device identifier, used by software to identify the device family (chipid) variant, and bugfix version</p>

| Bits|Identifier|Access| Reset|Name|
|-----|----------|------|------|----|
| 7:0 |  respin  |   r  |  0x0 |  — |
| 15:8| variation|   r  |  0x0 |  — |
|31:16|  chipid  |   r  |0xEB68|  — |

### SystemConfig register

- Absolute Address: 0x2000008
- Base Offset: 0x8
- Size: 0x4

<p>System configuration fields. use to enable/disable various features</p>

|Bits|     Identifier     |Access|Reset|Name|
|----|--------------------|------|-----|----|
|  0 |sys_interrupt_enable|  rw  | 0x0 |  — |
|  1 | mram_startup_bypass|  rw  | 0x0 |  — |
|  2 |    wdog_disable    |  rw  | 0x1 |  — |
|  3 |     i2c_enable     |  rw  | 0x0 |  — |
|  4 |     spi_enable     |  rw  | 0x1 |  — |
|  5 |     qspi_enable    |  rw  | 0x0 |  — |
|  6 |     uart_enable    |  rw  | 0x0 |  — |

#### sys_interrupt_enable field

<p>reg interrupt:Writing to this bit generates an interrupt.</p>

#### mram_startup_bypass field

<p>connected to mram_startup_bypass of mram_wrapper</p>

#### wdog_disable field

<p>Watchdog Disable</p>

#### i2c_enable field

<p>I2C Enable</p>

#### spi_enable field

<p>SPI Enable</p>

#### qspi_enable field

<p>QSPI Enable</p>

#### uart_enable field

<p>UART Enable</p>

### WATCHDOG_COUNT register

- Absolute Address: 0x2000010
- Base Offset: 0x10
- Size: 0x4

<p>The watchdog detects 'hang' conditions and resets the system. This feature is disabled by default. Clear <code>cpu_config.wdog_disable</code> to enable this. Once enabled, S/W should write to <code>Watchdog.kick</code> to reset the <code>WATCHDOG_COUNT.count</code> field. If the count reaches 0, it triggers a system reset.</p>

|Bits|  Identifier  |Access| Reset|Name|
|----|--------------|------|------|----|
|31:0|watchdog_count|  rw  |0xFFFF|  — |

#### watchdog_count field

<p>When the watchdog timer is enabled it counts down from this value</p>

### Watchdog register

- Absolute Address: 0x2000018
- Base Offset: 0x18
- Size: 0x4

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
|  7 |   kick   |  rw  | 0x0 |  — |

#### kick field

<p>Resets the watchdog timer, cpu needs to regularly write to this bit to aviod a watchdog timeout based reset of the device</p>

### SysInterrupt register

- Absolute Address: 0x2000020
- Base Offset: 0x20
- Size: 0x4

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
|  0 | interrupt|  rw  | 0x0 |  — |

#### interrupt field

<p>Write to this bit to generate an interrupt</p>

### SoftReset register

- Absolute Address: 0x2000028
- Base Offset: 0x28
- Size: 0x4

|Bits|  Identifier  |Access|Reset|Name|
|----|--------------|------|-----|----|
|  0 |  soft_reset  |  rw  | 0x0 |  — |
|  1 |cpu_warm_reset|  rw  | 0x0 |  — |
|  2 |  mram_rst_b  |  rw  | 0x1 |  — |

#### soft_reset field

<p>System Soft Reset, Active High</p>

#### cpu_warm_reset field

<p>CPU Warm Reset, Active High</p>

#### mram_rst_b field

<p>MRAM Resetn, Active Low</p>

### ResetCause register

- Absolute Address: 0x2000030
- Base Offset: 0x30
- Size: 0x4

<p>This register reports the cause of reset. There are multiple reset sources.
            * Power on Reset,
            * Brownout Reset, and
                * Various S/W reset requests. These clear on read bits capture the reset cause since the last read
<strong>Note</strong> if the por bit is set ignore the other cause registers, they will have random values until the first read.</p>

|Bits|    Identifier   |Access|Reset|Name|
|----|-----------------|------|-----|----|
|  0 |       por       |   r  | 0x1 |  — |
|  1 |watchdog_timedout|   r  |  —  |  — |
|  2 |   sysreset_req  |   r  |  —  |  — |
|  3 |     brownout    |   r  |  —  |  — |
|  4 |    softreset    |   r  |  —  |  — |
|  5 |     hresetn     |   r  |  —  |  — |

#### por field

<p>System POR was toggled</p>

#### watchdog_timedout field

<p>Watchdog was enabled and CPU failed to clear the watchdog timer</p>

#### sysreset_req field

<p>CPU detected an architecture level lockup and requested  a system reset</p>

#### brownout field

<p>The brownout detector triggered a reset</p>

#### softreset field

<p>The soft reset bit was written to</p>

#### hresetn field

<p>The cpu reset bit was written to</p>

### PowerDomainReq register

- Absolute Address: 0x2000038
- Base Offset: 0x38
- Size: 0x4

<p>Writing to PD fields initiates the shutdown of the corresponding power domain. A shutdown request is sent to the domain, This domain waits until all outstanding transactions are completed and then generates a corresponding ack signal. Once the ack signal is generated the power controller will turn off power to that domain.</p>

|Bits|    Identifier   |Access|Reset|Name|
|----|-----------------|------|-----|----|
|  0 |      cpu_pd     |  rw  | 0x0 |  — |
|  1 |     sram_pd     |   r  | 0x0 |  — |
|  2 |cpu_ram_powerdown|  rw  | 0x0 |  — |
|  3 |    chiplet_pd   |   r  | 0x0 |  — |
|  4 |     mram_pd     |  rw  | 0x0 |  — |
|  5 | system_poweroff |   w  | 0x0 |  — |
|  6 |     hyperbus    |   r  | 0x0 |  — |
|15:8|    minion_pd    |  rw  | 0x0 |  — |
| 16 |  mram_dsleep_en |  rw  | 0x1 |  — |
| 17 |   cpu_sleep_en  |  rw  | 0x0 |  — |

#### cpu_pd field

<p>Poweroff the ARM Domain</p>

#### sram_pd field

<p>Not used, in future connected to TCM poweroff bit</p>

#### cpu_ram_powerdown field

<p>Powerdown the CPU ram. this puts the ram in deepsleep mode</p>

#### chiplet_pd field

<p>Not used; chiplet power domain is controlled via the mode bits</p>

#### mram_pd field

<p>Power down for MRAM digital logic</p>

#### system_poweroff field

<p>Power of the chip.only wakeup logic is powered on</p>

#### hyperbus field

<p>Not used; hyperbus power domain is controlled via the mode bits.</p>

#### minion_pd field

<p>Minion PowerDown Req</p>

#### mram_dsleep_en field

<p>connected to dsleep pin on mram_wrapper</p>

#### cpu_sleep_en field

<p>currently not used. In future this will be used for CPU sleep management.</p>

### PowerDomainAck register

- Absolute Address: 0x2000040
- Base Offset: 0x40
- Size: 0x4

<p>This mirrors the Ack signal generated in response to power down request.</p>

|Bits|   Identifier  |Access|Reset|Name|
|----|---------------|------|-----|----|
|  0 |   cpu_pd_ack  |   r  | 0x0 |  — |
|  1 |  sram_pd_ack  |   r  | 0x0 |  — |
|  3 | chiplet_pd_ack|   r  | 0x0 |  — |
|  4 |  mram_pd_ack  |   r  | 0x0 |  — |
|  5 | system_pd_ack |   r  | 0x0 |  — |
|  6 |hyperbus_pd_ack|   r  | 0x0 |  — |
|15:8| minion_pd_ack |  rw  | 0x0 |  — |

#### cpu_pd_ack field

<p>pd ack for cpu</p>

#### sram_pd_ack field

<p>Not used;pd ack for TCM</p>

#### chiplet_pd_ack field

<p>Not used;pd ack for chiplet</p>

#### mram_pd_ack field

<p>pd ack for mram</p>

#### system_pd_ack field

<p>pd ack for system</p>

#### hyperbus_pd_ack field

<p>Not used;pd ack for hyperbus</p>

#### minion_pd_ack field

<p>Minion PowerDown Req</p>

### PowerGood register

- Absolute Address: 0x2000048
- Base Offset: 0x48
- Size: 0x4

<p>When a power domain is switched on, it takes time for the voltage to stabalize, this time is process dependent. The default value is sufficiently large to account for all variations.</p>

|Bits|Identifier|Access| Reset |Name|
|----|----------|------|-------|----|
|20:0|  counter |  rw  |0xFFFFF|  — |

#### counter field

<p>Counter for powerGood</p>

### SpinLock register

- Absolute Address: 0x2000050
- Base Offset: 0x50
- Size: 0x4

<p>initially locked=0, A read on this register will set the lock bit.
<strong>Usage:</strong> 
1. Read this field. If you get a value of zero you got the lock. Else a different processing element acquired the lock. Poll at fixed intervals(dont spam) until you get the lock.
2. If you acquired the lock, Once you have finished interacting with the locked resource write 0 to this register to release the lock.</p>

|Bits|Identifier| Access |Reset|Name|
|----|----------|--------|-----|----|
|  0 |   lock   |rw, rset| 0x0 |  — |

### ChipMode register

- Absolute Address: 0x2000058
- Base Offset: 0x58
- Size: 0x4

|Bits|  Identifier |Access|Reset|Name|
|----|-------------|------|-----|----|
| 1:0|  chip_mode  |   r  |  —  |  — |
|  2 |  ifc_width  |   r  |  —  |  — |
| 4:3|   bootload  |  rw  | 0x0 |  — |
| 6:5|load_external|  rw  | 0x0 |  — |

#### chip_mode field

<p>The mode in which chip is working, hyperbus, axi,ahb,gci</p>

#### ifc_width field

<p>If chip is axi/ahb mode datawidth</p>

#### bootload field

<p>Jump to 00:no Jump, 01:TCM,10:MRAM</p>

#### load_external field

<p>Jump to 00:no load, 01:Load TCM via Chiplet,10:Load MRAM via Chiplet</p>

### Mailbox0 register

- Absolute Address: 0x2000060
- Base Offset: 0x60
- Size: 0x4

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
|31:0|   mbox0  |  rw  | 0x0 |  — |

#### mbox0 field

<p>Mailbox0</p>

### Mailbox1 register

- Absolute Address: 0x2000068
- Base Offset: 0x68
- Size: 0x4

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
|31:0|   mbox1  |  rw  | 0x0 |  — |

#### mbox1 field

<p>Mailbox1</p>

### GPIO_OE register

- Absolute Address: 0x2000070
- Base Offset: 0x70
- Size: 0x4

<p>Gpio Output enable.
Write 1 to this bit to set the GPIO register in output mode.</p>

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
|10:0|  gpio_oe |  rw  | 0x0 |  — |

#### gpio_oe field

<p>Gpio output enable</p>

### GPIO_I register

- Absolute Address: 0x2000078
- Base Offset: 0x78
- Size: 0x4

<p>Gpio Input
For each bit in input mode this register captures the input value.</p>

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
|10:0|  gpio_i  |   r  | 0x0 |  — |

#### gpio_i field

<p>Gpio input</p>

### GPIO_O register

- Absolute Address: 0x2000080
- Base Offset: 0x80
- Size: 0x4

<p>Gpio Output
For each bit in output mode the content of the corresponding bit in this register is reflected on the GPIO Pin</p>

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
|10:0|  gpio_o  |   r  | 0x0 |  — |

#### gpio_o field

<p>Gpio input</p>

### GPIO_Interrupt_Enable register

- Absolute Address: 0x2000088
- Base Offset: 0x88
- Size: 0x4

<p>Gpio Interrupt Enable
For each bit in input mode if the input signal toggles and the content of the corresponding bit in this register is 1, then a GPIO interrupt is raised.</p>

|Bits|    Identifier   |Access|Reset|Name|
|----|-----------------|------|-----|----|
|10:0|gpio_interrupt_en|   r  | 0x0 |  — |

#### gpio_interrupt_en field

<p>Gpio input</p>

## mram_registers address map

- Absolute Address: 0x2001000
- Base Offset: 0x2001000
- Size: 0x60

<p>Register space that is contains the test registers for test functionality and debug of the MRAM.</p>

|Offset|Identifier|             Name             |
|------|----------|------------------------------|
| 0x00 | TESTREG0 |Debug Signals + Address/WE/CE.|
| 0x08 | TESTREG1 |           BWE[63:0]          |
| 0x10 | TESTREG2 |           BWE[63:0]          |
| 0x18 | TESTREG3 |               —              |
| 0x20 | TESTREG4 |               —              |
| 0x28 | TESTREG5 |          gbl_cfg_ovr         |
| 0x30 | TESTREG6 |               —              |
| 0x38 | TESTREG7 |               —              |
| 0x40 | TESTREG8 |               —              |
| 0x48 | TESTREG9 |               —              |
| 0x50 | TESTREG10|               —              |
| 0x58 | TESTREG11|               —              |

### TESTREG0 register

- Absolute Address: 0x2001000
- Base Offset: 0x0
- Size: 0x8

| Bits|       Identifier      |Access|Reset|Name|
|-----|-----------------------|------|-----|----|
| 17:0|        addr_in        |  rw  | 0x0 |  — |
|21:18|       stripe_sel      |  rw  | 0x0 |  — |
|  22 |           we          |  rw  | 0x0 |  — |
|  23 |    rd_pulse_meas_en   |  rw  | 0x0 |  — |
|30:24|        rca_ovr        |  rw  | 0x0 |  — |
|  31 |       rca_ovr_en      |  rw  | 0x0 |  — |
|  32 |     gbl_cfg_ovr_en    |  rw  | 0x1 |  — |
|  33 |       rd_en_ovr       |  rw  | 0x0 |  — |
|  34 |       ref_prg_en      |  rw  | 0x0 |  — |
|  35 |     dsleep_mram_en    |  rw  | 0x0 |  — |
|  36 |reg_logic_sup_sleep_ovr|  rw  | 0x0 |  — |
|  37 |      prg_rd1_byp      |  rw  | 0x0 |  — |
|  38 |       wr_en_ovr       |  rw  | 0x0 |  — |
|  39 |         dma_en        |  rw  | 0x0 |  — |
|  40 |  vblslx_gain_mode_ovr |  rw  | 0x0 |  — |
|44:41|     nvsram_en_ovr     |  rw  | 0x0 |  — |
|48:45|     sa_cal_clk_ovr    |  rw  | 0x0 |  — |
|52:49|     sa_cal_en_ovr     |  rw  | 0x0 |  — |
|  53 |      bist_err_rst     |  rw  | 0x0 |  — |
|  54 |       bist_rd_en      |  rw  | 0x0 |  — |
|  55 |       bist_wr_en      |  rw  | 0x0 |  — |
|58:56|      anatest0_sel     |  rw  | 0x0 |  — |
|61:59|      anatest1_sel     |  rw  | 0x0 |  — |
|63:62|     cal_clk_speed     |  rw  | 0x1 |  — |

### TESTREG1 register

- Absolute Address: 0x2001008
- Base Offset: 0x8
- Size: 0x8

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
|63:0|    bwe   |  rw  | 0x0 |  — |

### TESTREG2 register

- Absolute Address: 0x2001010
- Base Offset: 0x10
- Size: 0x8

| Bits|   Identifier  |Access|Reset|   Name   |
|-----|---------------|------|-----|----------|
| 14:0|      bwe      |  rw  | 0x0 |bwe[78:64]|
|  15 |  mram_clk_en  |  rw  | 0x1 |     —    |
|30:16|      din      |  rw  | 0x0 |din[78:64]|
|  31 |test_reg_ovr_en|  rw  | 0x0 |     —    |
|  32 |  ref_trim_en  |  rw  | 0x0 |     —    |
|  33 |   otp_wr_en   |  rw  | 0x0 |     —    |
|  34 |  rst_cpu_intr |  rw  | 0x0 |     —    |
|37:35|    RH_sigma   |  rw  | 0x1 |     —    |
|42:38|   RH_margin   |  rw  | 0xA |     —    |
|  43 |  stop_on_err  |  rw  | 0x0 |     —    |
|63:44|   start_add   |  rw  | 0x0 |     —    |

### TESTREG3 register

- Absolute Address: 0x2001018
- Base Offset: 0x18
- Size: 0x8

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
|63:0|    din   |  rw  | 0x0 |  — |

### TESTREG4 register

- Absolute Address: 0x2001020
- Base Offset: 0x20
- Size: 0x8

| Bits|      Identifier     |Access|Reset|Name|
|-----|---------------------|------|-----|----|
|  0  |         dinv        |  rw  | 0x0 |  — |
|  1  |   disable_cpu_intr  |  rw  | 0x0 |  — |
|  2  |     disable_ted     |  rw  | 0x0 |  — |
|  3  |    ecc_bypass_en    |  rw  | 0x0 |  — |
| 6:4 |        ecc_en       |  rw  | 0x0 |  — |
| 10:7| even_man_stripe_sel |  rw  | 0x0 |  — |
|14:11|     even_man_wr     |  rw  | 0x0 |  — |
|17:15|       inc_addr      |  rw  | 0x0 |  — |
|21:18|  odd_man_stripe_sel |  rw  | 0x0 |  — |
|25:22|      odd_man_wr     |  rw  | 0x0 |  — |
|  26 |        sah_en       |  rw  | 0x1 |  — |
|  27 |      scc_otp_en     |  rw  | 0x0 |  — |
|31:28|     ste_ovr_sel     |  rw  | 0x0 |  — |
|51:32|       stop_add      |  rw  | 0x0 |  — |
|54:52| replacement_add_sel |  rw  | 0x0 |  — |
|  55 |mram_clk_single_pulse|  rw  | 0x0 |  — |

### TESTREG5 register

- Absolute Address: 0x2001028
- Base Offset: 0x28
- Size: 0x8

| Bits|    Identifier   |Access|Reset|Name|
|-----|-----------------|------|-----|----|
| 1:0 |  sa_equal_trim  |  rw  | 0x1 |  — |
| 4:2 |vblslx_boost_trim|  rw  | 0x4 |  — |
| 8:5 |  wr_en_msb_trim |  rw  | 0x9 |  — |
| 11:9|  wr_en_lsb_trim |  rw  | 0x6 |  — |
|  12 | vblslx_gain_mode|  rw  | 0x0 |  — |
|16:13|   repulse_trim  |  rw  | 0x6 |  — |
|  17 |    repulse_en   |  rw  | 0x1 |  — |
|20:18|    rd_en_trim   |  rw  | 0x5 |  — |
|24:21| osc_wr_div_trim |  rw  | 0x1 |  — |
|28:25|    vblsl_trim   |  rw  | 0xA |  — |
|32:29|    tcsel_trim   |  rw  | 0x9 |  — |
|36:33|    vwlwr_trim   |  rw  | 0x3 |  — |
|40:37|  vcr_gate_trim  |  rw  | 0x7 |  — |

### TESTREG6 register

- Absolute Address: 0x2001030
- Base Offset: 0x30
- Size: 0x8

| Bits|  Identifier |Access|Reset|Name|
|-----|-------------|------|-----|----|
| 3:0 |blk0_man_ccnt|  rw  | 0x0 |  — |
| 7:4 |blk0_man_cnfg|  rw  | 0x0 |  — |
| 9:8 |blk0_man_fcnt|  rw  | 0x0 |  — |
|19:16|blk1_man_ccnt|  rw  | 0x0 |  — |
|23:20|blk1_man_cnfg|  rw  | 0x0 |  — |
|25:24|blk1_man_fcnt|  rw  | 0x0 |  — |
|35:32|blk2_man_ccnt|  rw  | 0x0 |  — |
|39:36|blk2_man_cnfg|  rw  | 0x0 |  — |
|41:40|blk2_man_fcnt|  rw  | 0x0 |  — |
|51:48|blk3_man_ccnt|  rw  | 0x0 |  — |
|55:52|blk3_man_cnfg|  rw  | 0x0 |  — |
|57:56|blk3_man_fcnt|  rw  | 0x0 |  — |

### TESTREG7 register

- Absolute Address: 0x2001038
- Base Offset: 0x38
- Size: 0x8

| Bits|  Identifier |Access|Reset|Name|
|-----|-------------|------|-----|----|
| 3:0 |blk4_man_ccnt|  rw  | 0x0 |  — |
| 7:4 |blk4_man_cnfg|  rw  | 0x0 |  — |
| 9:8 |blk4_man_fcnt|  rw  | 0x0 |  — |
|19:16|blk5_man_ccnt|  rw  | 0x0 |  — |
|23:20|blk5_man_cnfg|  rw  | 0x0 |  — |
|25:24|blk5_man_fcnt|  rw  | 0x0 |  — |
|35:32|blk6_man_ccnt|  rw  | 0x0 |  — |
|39:36|blk6_man_cnfg|  rw  | 0x0 |  — |
|41:40|blk6_man_fcnt|  rw  | 0x0 |  — |
|51:48|blk7_man_ccnt|  rw  | 0x0 |  — |
|55:52|blk7_man_cnfg|  rw  | 0x0 |  — |
|57:56|blk7_man_fcnt|  rw  | 0x0 |  — |

### TESTREG8 register

- Absolute Address: 0x2001040
- Base Offset: 0x40
- Size: 0x8

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
|63:0|   dout   |   r  |  —  |  — |

### TESTREG9 register

- Absolute Address: 0x2001048
- Base Offset: 0x48
- Size: 0x8

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
|14:0|   dout   |   r  |  —  |  — |

### TESTREG10 register

- Absolute Address: 0x2001050
- Base Offset: 0x50
- Size: 0x8

| Bits|   Identifier  |Access|Reset|Name|
|-----|---------------|------|-----|----|
| 1:0 |      temp     |   r  |  —  |  — |
| 6:2 | rep_add_cnt_o |   r  |  —  |  — |
|  7  |     pwr_ok    |   r  |  —  |  — |
| 11:8|nvsram_boot_err|   r  |  —  |  — |
|31:12| intr_error_add|   r  |  —  |  — |
|  32 | cpu_intr_flag |   r  |  —  |  — |
|  33 |      busy     |   r  |  —  |  — |
|38:34|   bist_state  |   r  |  —  |  — |
|58:39|  bist_err_add |   r  |  —  |  — |
|  59 |    bist_err   |   r  |  —  |  — |
|  60 |   bist_done   |   r  |  —  |  — |
|  61 |    ecc_1bit   |   r  |  —  |  — |
|  62 |    ecc_2bit   |   r  |  —  |  — |
|  63 |    ecc_3bit   |   r  |  —  |  — |

### TESTREG11 register

- Absolute Address: 0x2001058
- Base Offset: 0x58
- Size: 0x8

| Bits|   Identifier   |Access|Reset|         Name        |
|-----|----------------|------|-----|---------------------|
| 19:0|replacement_add0|   r  |  —  | replacement_add[3N] |
|39:20|replacement_add1|   r  |  —  |replacement_add[3N+1]|
|59:40|replacement_add2|   r  |  —  |replacement_add[3N+2]|

## peripheral_registers address map

- Absolute Address: 0x2002000
- Base Offset: 0x2002000
- Size: 0x4

<p>Peripheral Configuration</p>

|Offset|Identifier|Name|
|------|----------|----|
|  0x0 |    p1    |  — |

### p1 register

- Absolute Address: 0x2002000
- Base Offset: 0x0
- Size: 0x4

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
|31:0| reserved |  rw  | 0x0 |  — |

#### reserved field

<p>reserved</p>

## hyperbus_registers address map

- Absolute Address: 0x2003000
- Base Offset: 0x2003000
- Size: 0x12C

<p>Register description of HyperRAM  refer Register space of Cypress_hyperbus_specification.pdf</p>

|Offset|   Identifier  |Name|
|------|---------------|----|
| 0x000|      ID0      | id0|
| 0x004|      ID1      | ID1|
| 0x008|      CFG      |  — |
| 0x040|      TP0      |  — |
| 0x048|  TP0_BWE_Low  |  — |
| 0x050|  TP0_BWE_High |  — |
| 0x058|  TP0_DIN_Low  |  — |
| 0x060|  TP0_DIN_High |  — |
| 0x068|   TP0_STATUS  |  — |
| 0x070| TP0_REGOUT_LOW|  — |
| 0x078|TP0_REGOUT_HIGH|  — |
| 0x080|   CPU_CONFIG  |  — |
| 0x090|      TP1      |  — |
| 0x098|  TP1_BWE_Low  |  — |
| 0x100|  TP1_BWE_High |  — |
| 0x108|  TP1_DIN_Low  |  — |
| 0x110|  TP1_DIN_High |  — |
| 0x118|   TP1_STATUS  |  — |
| 0x120| TP1_REGOUT_LOW|  — |
| 0x128|TP1_REGOUT_HIGH|  — |

### ID0 register

- Absolute Address: 0x2003000
- Base Offset: 0x0
- Size: 0x4

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
| 3:0|  mgf_id  |  rw  | 0x2 |  — |
|15:4|  devid0  |  rw  | 0x0 |  — |

#### mgf_id field

<p>Manufacturer: TODO check how to obtain this number</p>

#### devid0 field

<p>DEVID0 TODO Use as suitable</p>

### ID1 register

- Absolute Address: 0x2003004
- Base Offset: 0x4
- Size: 0x4

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
| 3:0| dev_type |  rw  | 0x0 |  — |
|15:4|  devid1  |  rw  | 0x0 |  — |

#### dev_type field

<p>Device Type set to hyperram</p>

#### devid1 field

<p>TODO Use as appropriate</p>

### CFG register

- Absolute Address: 0x2003008
- Base Offset: 0x8
- Size: 0x4

| Bits|    Identifier   |Access|Reset|Name|
|-----|-----------------|------|-----|----|
| 1:0 |   BurstLength   |  rw  | 0x2 |  — |
|  2  |HybridBurstEnable|   r  | 0x0 |  — |
|  3  |   FixedLatency  |   r  | 0x1 |  — |
| 7:4 |  InitialLatency |  rw  | 0x6 |  — |
| 11:8|     Reserved    |   r  | 0x1 |  — |
|14:12|  DriveStrength  |   r  | 0x0 |  — |
|  15 |  DeepPowerDown  |  rw  | 0x1 |  — |
|  16 |   BurstEnable   |  rw  | 0x0 |  — |

#### BurstEnable field

<p>Enable bust access. Applicable only to memory access. Register access are one at a time</p>

### TP0 register

- Absolute Address: 0x2003040
- Base Offset: 0x40
- Size: 0x4

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
| 3:0|  tp_add  |  rw  | 0x0 |  — |
|  4 |   tp_ce  |  rw  | 0x0 |  — |
|  5 |   tp_we  |  rw  | 0x0 |  — |

### TP0_BWE_Low register

- Absolute Address: 0x2003048
- Base Offset: 0x48
- Size: 0x4

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
|31:0|tp_bwe_low|  rw  | 0x0 |  — |

### TP0_BWE_High register

- Absolute Address: 0x2003050
- Base Offset: 0x50
- Size: 0x4

|Bits| Identifier|Access|Reset|Name|
|----|-----------|------|-----|----|
|31:0|tp_bwe_high|  rw  | 0x0 |  — |

### TP0_DIN_Low register

- Absolute Address: 0x2003058
- Base Offset: 0x58
- Size: 0x4

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
|31:0|tp_din_low|  rw  | 0x0 |  — |

### TP0_DIN_High register

- Absolute Address: 0x2003060
- Base Offset: 0x60
- Size: 0x4

|Bits| Identifier|Access|Reset|Name|
|----|-----------|------|-----|----|
|31:0|tp_din_high|  rw  | 0x0 |  — |

### TP0_STATUS register

- Absolute Address: 0x2003068
- Base Offset: 0x68
- Size: 0x4

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
|  0 |  tp_busy |   r  | 0x0 |  — |
|  1 | tp_valid |   r  | 0x0 |  — |

### TP0_REGOUT_LOW register

- Absolute Address: 0x2003070
- Base Offset: 0x70
- Size: 0x4

|Bits|  Identifier |Access|Reset|Name|
|----|-------------|------|-----|----|
|31:0|tp_regout_low|   r  | 0x0 |  — |

### TP0_REGOUT_HIGH register

- Absolute Address: 0x2003078
- Base Offset: 0x78
- Size: 0x4

|Bits|  Identifier  |Access|Reset|Name|
|----|--------------|------|-----|----|
|31:0|tp_regout_high|   r  | 0x0 |  — |

### CPU_CONFIG register

- Absolute Address: 0x2003080
- Base Offset: 0x80
- Size: 0x4

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
|  0 | cpu_wait |  rw  | 0x1 |  — |

#### cpu_wait field

<p>Put the CPU in wait state at reset when in hyperbus mode.</p>

### TP1 register

- Absolute Address: 0x2003090
- Base Offset: 0x90
- Size: 0x4

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
| 3:0|  tp_add  |  rw  | 0x0 |  — |
|  4 |   tp_ce  |  rw  | 0x0 |  — |
|  5 |   tp_we  |  rw  | 0x0 |  — |

### TP1_BWE_Low register

- Absolute Address: 0x2003098
- Base Offset: 0x98
- Size: 0x4

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
|31:0|tp_bwe_low|  rw  | 0x0 |  — |

### TP1_BWE_High register

- Absolute Address: 0x2003100
- Base Offset: 0x100
- Size: 0x4

|Bits| Identifier|Access|Reset|Name|
|----|-----------|------|-----|----|
|31:0|tp_bwe_high|  rw  | 0x0 |  — |

### TP1_DIN_Low register

- Absolute Address: 0x2003108
- Base Offset: 0x108
- Size: 0x4

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
|31:0|tp_din_low|  rw  | 0x0 |  — |

### TP1_DIN_High register

- Absolute Address: 0x2003110
- Base Offset: 0x110
- Size: 0x4

|Bits| Identifier|Access|Reset|Name|
|----|-----------|------|-----|----|
|31:0|tp_din_high|  rw  | 0x0 |  — |

### TP1_STATUS register

- Absolute Address: 0x2003118
- Base Offset: 0x118
- Size: 0x4

|Bits|Identifier|Access|Reset|Name|
|----|----------|------|-----|----|
|  0 |  tp_busy |   r  | 0x0 |  — |
|  1 | tp_valid |   r  | 0x0 |  — |

### TP1_REGOUT_LOW register

- Absolute Address: 0x2003120
- Base Offset: 0x120
- Size: 0x4

|Bits|  Identifier |Access|Reset|Name|
|----|-------------|------|-----|----|
|31:0|tp_regout_low|   r  | 0x0 |  — |

### TP1_REGOUT_HIGH register

- Absolute Address: 0x2003128
- Base Offset: 0x128
- Size: 0x4

|Bits|  Identifier  |Access|Reset|Name|
|----|--------------|------|-----|----|
|31:0|tp_regout_high|   r  | 0x0 |  — |
