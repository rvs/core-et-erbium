<!---
Markdown description for SystemRDL register map.

Don't override. Generated from: axi2mram_bridge_registers
  - systemrdl/top.rdl
-->

## axi2mram_bridge_registers address map

- Absolute Address: 0x0
- Base Offset: 0x0
- Size: 0x4A0

<p>Unified register map for the AXI-to-MRAM bridge. Contains bridge
configuration registers and per-bank MRAM controller test registers.</p>

|Offset| Identifier|                      Name                     |
|------|-----------|-----------------------------------------------|
| 0x000|bridge_regs|AXI-to-MRAM Bridge Control and Status Registers|
| 0x100|bank0_tregs|     MRAM Control and Status Test Registers    |
| 0x200|bank1_tregs|     MRAM Control and Status Test Registers    |
| 0x300|bank2_tregs|     MRAM Control and Status Test Registers    |
| 0x400|bank3_tregs|     MRAM Control and Status Test Registers    |

## bridge_regs register file

- Absolute Address: 0x0
- Base Offset: 0x0
- Size: 0x38

<p>Register space for configuration and status of the AXI-to-MRAM bridge.</p>

|Offset|       Identifier       |          Name         |
|------|------------------------|-----------------------|
| 0x00 |    arbiter_mode_reg    |      Arbiter Mode     |
| 0x08 |    bridge_status_reg   |     Bridge Status     |
| 0x10 |    slverr_status_reg   | AXI Slave Error Status|
| 0x18 |       control_reg      |    AXI2MRAM Control   |
| 0x20 |ecc_1bit_error_count_reg|ECC 1-bit Error Counter|
| 0x28 |ecc_2bit_error_count_reg|ECC 2-bit Error Counter|
| 0x30 |ecc_3bit_error_count_reg|ECC 3-bit Error Counter|

### arbiter_mode_reg register

- Absolute Address: 0x0
- Base Offset: 0x0
- Size: 0x8

<p>Controls the read/write arbitration policy when both channels
have simultaneous pending requests.</p>

|Bits| Identifier |Access|Reset|    Name    |
|----|------------|------|-----|------------|
| 1:0|arbiter_mode|  rw  | 0x2 |arbiter_mode|

#### arbiter_mode field

<p>Arbitration mode selection.
0 = Write Priority  (writes always win)
1 = Read Priority   (reads always win)
2 = Round Robin     (alternate after each conflict)
3 = Oldest First    (whichever request arrived first wins)</p>

### bridge_status_reg register

- Absolute Address: 0x8
- Base Offset: 0x8
- Size: 0x8

<p>Read-only status indicators for the AXI-to-MRAM bridge.</p>

|Bits|   Identifier   |Access|Reset|      Name      |
|----|----------------|------|-----|----------------|
|  0 |    axi_busy    |   r  | 0x0 |    axi_busy    |
| 7:4|cmd_queue_active|   r  | 0x0 |cmd_queue_active|
|11:8|   mram_ready   |   r  | 0x0 |   mram_ready   |

#### axi_busy field

<p>High when the bridge has outstanding AXI transactions.</p>

#### cmd_queue_active field

<p>Per-bank command queue active flags. Bit N = bank N has
pending write/RMW commands.</p>

#### mram_ready field

<p>Per-bank ready signals for bringing MRAM out of deep
sleep. When the bit is 1, that bank is ready for
operations.</p>

### slverr_status_reg register

- Absolute Address: 0x10
- Base Offset: 0x10
- Size: 0x8

<p>Sticky status bits capturing the reason(s) why the bridge
returned SLVERR on the AXI bus. Bits are set by hardware and
cleared automatically when software reads this register
(clear-on-read). Multiple causes may be set simultaneously.</p>

|Bits|     Identifier    | Access|Reset|        Name       |
|----|-------------------|-------|-----|-------------------|
|  0 |      oor_read     |r, rclr| 0x0 |      oor_read     |
|  1 |     oor_write     |r, rclr| 0x0 |     oor_write     |
|  2 |   mram_not_ready  |r, rclr| 0x0 |   mram_not_ready  |
|  3 |   mram_unpowered  |r, rclr| 0x0 |   mram_unpowered  |
|  4 |    maintenance    |r, rclr| 0x0 |    maintenance    |
|  5 |unrecoverable_error|r, rclr| 0x0 |unrecoverable_error|

#### oor_read field

<p>Set when a read transaction was rejected with SLVERR
because ARADDR falls outside the valid MRAM window
(ARADDR[31:24] != 0, i.e. ARADDR &gt;= 0x100_0000).</p>

#### oor_write field

<p>Set when a write transaction was rejected with SLVERR
because AWADDR falls outside the valid MRAM window
(AWADDR[31:24] != 0, i.e. AWADDR &gt;= 0x100_0000).</p>

#### mram_not_ready field

<p>Set when a transaction was rejected with SLVERR because
the targeted MRAM bank reports not-ready.</p>

#### mram_unpowered field

<p>Set when a transaction was rejected with SLVERR because
the targeted MRAM bank reports power-not-ok.</p>

#### maintenance field

<p>Set when a transaction was rejected with SLVERR because
the targeted MRAM bank is in maintenance mode.</p>

#### unrecoverable_error field

<p>Set when read data was returned with an unrecoverable ECC
condition (triple-bit error) and the bridge responded with
SLVERR.</p>

### control_reg register

- Absolute Address: 0x18
- Base Offset: 0x18
- Size: 0x8

<p>Software control bits for the AXI-to-MRAM bridge.</p>

|Bits|    Identifier    |Access|Reset|       Name       |
|----|------------------|------|-----|------------------|
| 3:0|disable_clock_gate|  rw  | 0x0 |disable_clock_gate|
|  4 |ecc_1bit_intr_mask|  rw  | 0x1 |ecc_1bit_intr_mask|
|  5 |ecc_2bit_intr_mask|  rw  | 0x0 |ecc_2bit_intr_mask|
|  6 |ecc_3bit_intr_mask|  rw  | 0x0 |ecc_3bit_intr_mask|

#### disable_clock_gate field

<p>Per-bank clock-gate disable control. Bit N disables the
clock gating structure driving MRAM bank N so that a
continuous clock is driven into the bank interface.</p>

#### ecc_1bit_intr_mask field

<p>Masks CPU interrupt generation for 1-bit ECC events in
the ET interrupt logic. 1 = masked/suppressed, 0 =
unmasked/enabled. Reset default is 1 (masked).</p>

#### ecc_2bit_intr_mask field

<p>Masks CPU interrupt generation for 2-bit ECC events in
the ET interrupt logic. 1 = masked/suppressed, 0 =
unmasked/enabled. Reset default is 0 (enabled).</p>

#### ecc_3bit_intr_mask field

<p>Masks CPU interrupt generation for 3-bit ECC events in
the ET interrupt logic. 1 = masked/suppressed, 0 =
unmasked/enabled. Reset default is 0 (enabled).</p>

### ecc_1bit_error_count_reg register

- Absolute Address: 0x20
- Base Offset: 0x20
- Size: 0x8

<p>Counts observed 1-bit ECC events across all banks/lanes.
The counter increments by the number of asserted lane bits per
cycle (0..8).</p>

|Bits|Identifier|Access|Reset| Name|
|----|----------|------|-----|-----|
|31:0|   count  |   r  | 0x0 |count|

#### count field

<p>Accumulated 1-bit ECC event count.</p>

### ecc_2bit_error_count_reg register

- Absolute Address: 0x28
- Base Offset: 0x28
- Size: 0x8

<p>Counts observed 2-bit ECC events across all banks/lanes.
The counter increments by the number of asserted lane bits per
cycle (0..8).</p>

|Bits|Identifier|Access|Reset| Name|
|----|----------|------|-----|-----|
|31:0|   count  |   r  | 0x0 |count|

#### count field

<p>Accumulated 2-bit ECC event count.</p>

### ecc_3bit_error_count_reg register

- Absolute Address: 0x30
- Base Offset: 0x30
- Size: 0x8

<p>Counts observed 3-bit ECC events across all banks/lanes.
The counter increments by the number of asserted lane bits per
cycle (0..8).</p>

|Bits|Identifier|Access|Reset| Name|
|----|----------|------|-----|-----|
|31:0|   count  |   r  | 0x0 |count|

#### count field

<p>Accumulated 3-bit ECC event count.</p>

## bank0_tregs register file

- Absolute Address: 0x100
- Base Offset: 0x100
- Size: 0xA0

<p>Register space that contains the test registers for test functionality and debug of the MRAM.</p>

|Offset|     Identifier     |Name|
|------|--------------------|----|
| 0x00 |    mram_control    |  — |
| 0x20 | mram_control_pulse |  — |
| 0x28 |    gbl_cfg_ovr_0   |  — |
| 0x30 |      gbl_cfg_0     |  — |
| 0x38 |    man_control_0   |  — |
| 0x40 |    man_control_1   |  — |
| 0x48 |    mram_status_0   |  — |
| 0x50 |    mram_status_1   |  — |
| 0x58 |mram_dout_even_lower|  — |
| 0x60 | mram_dout_odd_lower|  — |
| 0x68 |  mram_dout_uppers  |  — |
| 0x70 |    bist_status_0   |  — |
| 0x78 |    bist_control    |  — |
| 0x88 |   ecc_correction   |  — |
| 0x98 |    bist_status_1   |  — |

### mram_control register

- Absolute Address: 0x100
- Base Offset: 0x0
- Size: 0x20

|  Bits |       Identifier      |Access|Reset|          Name         |
|-------|-----------------------|------|-----|-----------------------|
|  16:0 |        addr_in        |  rw  | 0x0 |        addr_in        |
| 24:17 |           ce          |  rw  | 0x0 |           ce          |
|   25  |           we          |  rw  | 0x0 |           we          |
|   26  |    rd_pulse_meas_en   |  rw  | 0x0 |    rd_pulse_meas_en   |
| 33:27 |        rca_ovr        |  rw  | 0x0 |        rca_ovr        |
|   34  |       rca_ovr_en      |  rw  | 0x0 |       rca_ovr_en      |
|   35  |     gbl_cfg_ovr_en    |  rw  | 0x0 |     gbl_cfg_ovr_en    |
|   36  |       rd_en_ovr       |  rw  | 0x0 |       rd_en_ovr       |
|   37  |       ref_prg_en      |  rw  | 0x0 |       ref_prg_en      |
|   38  |     dsleep_mram_en    |  rw  | 0x0 |     dsleep_mram_en    |
|   39  |reg_logic_sup_sleep_ovr|  rw  | 0x1 |reg_logic_sup_sleep_ovr|
|   40  |      prg_rd1_byp      |  rw  | 0x0 |      prg_rd1_byp      |
|   41  |       wr_en_ovr       |  rw  | 0x0 |       wr_en_ovr       |
|   42  |         dma_en        |  rw  | 0x0 |         dma_en        |
|   43  |  vblslx_gain_mode_ovr |  rw  | 0x0 |  vblslx_gain_mode_ovr |
| 47:44 | powerup_trim_load_ovr |  rw  | 0x0 | powerup_trim_load_ovr |
|   52  |      test_cal_en      |  rw  | 0x0 |      test_cal_en      |
| 55:53 |      anatest0_sel     |  rw  | 0x0 |      anatest0_sel     |
| 58:56 |      anatest1_sel     |  rw  | 0x0 |      anatest1_sel     |
|   59  |   eccrom_deep_sleep   |  rw  | 0x1 |   eccrom_deep_sleep   |
|   60  |      ref_ecc_sel      |  rw  | 0x0 |      ref_ecc_sel      |
|   61  |    disable_cpu_intr   |  rw  | 0x0 |    disable_cpu_intr   |
|   62  |      disable_ted      |  rw  | 0x0 |      disable_ted      |
|   63  |     ecc_bypass_en     |  rw  | 0x0 |     ecc_bypass_en     |
| 142:64|          bwe          |  rw  | 0x0 |          bwe          |
|  143  |      mram_clk_en      |  rw  | 0x1 |      mram_clk_en      |
|222:144|          din          |  rw  | 0x0 |          din          |
|  223  |    test_reg_ovr_en    |  rw  | 0x0 |    test_reg_ovr_en    |
|  224  |       otp_wr_en       |  rw  | 0x0 |       otp_wr_en       |
|  225  |      rst_cpu_intr     |  rw  | 0x0 |      rst_cpu_intr     |
|233:226|        dout_en        |  rw  | 0x0 |        dout_en        |
|236:234|         ecc_en        |  rw  | 0x0 |         ecc_en        |
|240:237|  even_man_stripe_sel  |  rw  | 0x0 |  even_man_stripe_sel  |
|  241  |     even_man_wr_0     |  rw  | 0x0 |     even_man_wr<0>    |
|  242  |     even_man_wr_1     |  rw  | 0x0 |     even_man_wr<1>    |
|  243  |     even_man_wr_2     |  rw  | 0x0 |     even_man_wr<2>    |
|  244  |     even_man_wr_3     |  rw  | 0x0 |     even_man_wr<3>    |
|248:245|   odd_man_stripe_sel  |  rw  | 0x0 |   odd_man_stripe_sel  |
|  249  |      odd_man_wr_0     |  rw  | 0x0 |     odd_man_wr<0>     |
|  250  |      odd_man_wr_1     |  rw  | 0x0 |     odd_man_wr<1>     |
|  251  |      odd_man_wr_2     |  rw  | 0x0 |     odd_man_wr<2>     |
|  252  |      odd_man_wr_3     |  rw  | 0x0 |     odd_man_wr<3>     |
|  253  |         sah_en        |  rw  | 0x1 |         sah_en        |
|  254  |       scc_otp_en      |  rw  | 0x0 |       scc_otp_en      |
|  255  |    maintenance_mode   |  rw  | 0x0 |    maintenance_mode   |

### mram_control_pulse register

- Absolute Address: 0x120
- Base Offset: 0x20
- Size: 0x8

|Bits|             Identifier             |Access|Reset|                 Name                |
|----|------------------------------------|------|-----|-------------------------------------|
|  0 |powerup_trim_load_ovr_single_pulse_0|  rw  | 0x0 |powerup_trim_load_ovr_single_pulse<0>|
|  1 |powerup_trim_load_ovr_single_pulse_1|  rw  | 0x0 |powerup_trim_load_ovr_single_pulse<1>|
|  2 |powerup_trim_load_ovr_single_pulse_2|  rw  | 0x0 |powerup_trim_load_ovr_single_pulse<2>|
|  3 |powerup_trim_load_ovr_single_pulse_3|  rw  | 0x0 |powerup_trim_load_ovr_single_pulse<3>|
|  4 |        mram_clk_single_pulse       |  rw  | 0x0 |        mram_clk_single_pulse        |

### gbl_cfg_ovr_0 register

- Absolute Address: 0x128
- Base Offset: 0x28
- Size: 0x8

| Bits|    Identifier   |Access|Reset|         Name         |
|-----|-----------------|------|-----|----------------------|
| 1:0 |  sa_equal_trim  |  rw  | 0x1 |  sa_equal_trim<1:0>  |
| 4:2 |vblslx_boost_trim|  rw  | 0x4 |vblslx_boost_trim<2:0>|
| 8:5 |  wr_en_msb_trim |  rw  | 0x9 |  wr_en_msb_trim<3:0> |
| 11:9|  wr_en_lsb_trim |  rw  | 0x6 |  wr_en_lsb_trim<2:0> |
|  12 | vblslx_gain_mode|  rw  | 0x0 |   vblslx_gain_mode   |
|16:13|   repulse_trim  |  rw  | 0x6 |   repulse_trim<3:0>  |
|  17 |    repulse_en   |  rw  | 0x1 |      repulse_en      |
|20:18|    rd_en_trim   |  rw  | 0x5 |    rd_en_trim<2:0>   |
|25:22| osc_wr_div_trim |  rw  | 0x3 | osc_wr_div_trim<3:0> |
|29:26|    vblsl_trim   |  rw  | 0x4 |    vblsl_trim<3:0>   |
|33:30|    tcsel_trim   |  rw  | 0x3 |    tcsel_trim<3:0>   |
|37:34|    vwlwr_trim   |  rw  | 0x7 |    vwlwr_trim<3:0>   |
|41:38|  vcr_gate_trim  |  rw  | 0xE |  vcr_gate_trim<3:0>  |

### gbl_cfg_0 register

- Absolute Address: 0x130
- Base Offset: 0x30
- Size: 0x8

| Bits|    Identifier   |Access|Reset|         Name         |
|-----|-----------------|------|-----|----------------------|
| 1:0 |  sa_equal_trim  |   r  |  —  |  sa_equal_trim<1:0>  |
| 4:2 |vblslx_boost_trim|   r  |  —  |vblslx_boost_trim<2:0>|
| 8:5 |  wr_en_msb_trim |   r  |  —  |  wr_en_msb_trim<3:0> |
| 11:9|  wr_en_lsb_trim |   r  |  —  |  wr_en_lsb_trim<2:0> |
|  12 | vblslx_gain_mode|   r  |  —  |   vblslx_gain_mode   |
|16:13|   repulse_trim  |   r  |  —  |   repulse_trim<3:0>  |
|  17 |    repulse_en   |   r  |  —  |      repulse_en      |
|20:18|    rd_en_trim   |   r  |  —  |    rd_en_trim<2:0>   |
|25:22| osc_wr_div_trim |   r  |  —  | osc_wr_div_trim<3:0> |
|29:26|    vblsl_trim   |   r  |  —  |    vblsl_trim<3:0>   |
|33:30|    tcsel_trim   |   r  |  —  |    tcsel_trim<3:0>   |
|37:34|    vwlwr_trim   |   r  |  —  |    vwlwr_trim<3:0>   |
|41:38|  vcr_gate_trim  |   r  |  —  |  vcr_gate_trim<3:0>  |

### man_control_0 register

- Absolute Address: 0x138
- Base Offset: 0x38
- Size: 0x8

| Bits|  Identifier |Access|Reset|       Name       |
|-----|-------------|------|-----|------------------|
| 3:0 |blk0_man_ccnt|   r  |  —  |blk0_man_ccnt<3:0>|
| 7:4 |blk0_man_cnfg|  rw  | 0x0 |blk0_man_cnfg<3:0>|
| 9:8 |blk0_man_fcnt|   r  |  —  |blk0_man_fcnt<1:0>|
|19:16|blk1_man_ccnt|   r  |  —  |blk1_man_ccnt<3:0>|
|23:20|blk1_man_cnfg|  rw  | 0x0 |blk1_man_cnfg<3:0>|
|25:24|blk1_man_fcnt|   r  |  —  |blk1_man_fcnt<1:0>|
|35:32|blk2_man_ccnt|   r  |  —  |blk2_man_ccnt<3:0>|
|39:36|blk2_man_cnfg|  rw  | 0x0 |blk2_man_cnfg<3:0>|
|41:40|blk2_man_fcnt|   r  |  —  |blk2_man_fcnt<1:0>|
|51:48|blk3_man_ccnt|   r  |  —  |blk3_man_ccnt<3:0>|
|55:52|blk3_man_cnfg|  rw  | 0x0 |blk3_man_cnfg<3:0>|
|57:56|blk3_man_fcnt|   r  |  —  |blk3_man_fcnt<1:0>|

### man_control_1 register

- Absolute Address: 0x140
- Base Offset: 0x40
- Size: 0x8

| Bits|  Identifier |Access|Reset|       Name       |
|-----|-------------|------|-----|------------------|
| 3:0 |blk4_man_ccnt|   r  |  —  |blk4_man_ccnt<3:0>|
| 7:4 |blk4_man_cnfg|  rw  | 0x0 |blk4_man_cnfg<3:0>|
| 9:8 |blk4_man_fcnt|   r  |  —  |blk4_man_fcnt<1:0>|
|19:16|blk5_man_ccnt|   r  |  —  |blk5_man_ccnt<3:0>|
|23:20|blk5_man_cnfg|  rw  | 0x0 |blk5_man_cnfg<3:0>|
|25:24|blk5_man_fcnt|   r  |  —  |blk5_man_fcnt<1:0>|
|35:32|blk6_man_ccnt|   r  |  —  |blk6_man_ccnt<3:0>|
|39:36|blk6_man_cnfg|  rw  | 0x0 |blk6_man_cnfg<3:0>|
|41:40|blk6_man_fcnt|   r  |  —  |blk6_man_fcnt<1:0>|
|51:48|blk7_man_ccnt|   r  |  —  |blk7_man_ccnt<3:0>|
|55:52|blk7_man_cnfg|  rw  | 0x0 |blk7_man_cnfg<3:0>|
|57:56|blk7_man_fcnt|   r  |  —  |blk7_man_fcnt<1:0>|

### mram_status_0 register

- Absolute Address: 0x148
- Base Offset: 0x48
- Size: 0x8

| Bits|   Identifier   |Access|Reset|         Name         |
|-----|----------------|------|-----|----------------------|
| 15:0| bist_error_loop|   r  |  —  | bist_error_loop<15:0>|
|33:17|bist_error_count|   r  |  —  |bist_error_count<16:0>|
|40:34|    bist_rh0    |   r  |  —  |     bist_rh0<6:0>    |
|47:41|    bist_rh1    |   r  |  —  |     bist_rh1<6:0>    |
|54:48|    bist_rh2    |   r  |  —  |     bist_rh2<6:0>    |
|56:55|  cpu_intr_flag |   r  |  —  |     cpu_intr_flag    |
|58:57|  ecc_1bit_flag |   r  |  —  |  ecc_1bit_flag<1:0>  |
|60:59|  ecc_2bit_flag |   r  |  —  |  ecc_2bit_flag<1:0>  |
|62:61|  ecc_3bit_flag |   r  |  —  |  ecc_3bit_flag<1:0>  |

### mram_status_1 register

- Absolute Address: 0x150
- Base Offset: 0x50
- Size: 0x8

| Bits|      Identifier     |Access|Reset|            Name           |
|-----|---------------------|------|-----|---------------------------|
| 1:0 |         temp        |   r  |  —  |         temp<1:0>         |
| 4:3 |       ecc_1bit      |   r  |  —  |       ecc_1bit<1:0>       |
| 6:5 |       ecc_2bit      |   r  |  —  |       ecc_2bit<1:0>       |
| 8:7 |       ecc_3bit      |   r  |  —  |       ecc_3bit<1:0>       |
|  9  |        pwr_ok       |   r  |  —  |           pwr_ok          |
|  10 |    eccrom_pwr_ok    |   r  |  —  |       eccrom_pwr_ok       |
|29:11|intr_error_lane0_addr|   r  |  —  |intr_error_lane0_addr<18:0>|
|48:30|intr_error_lane1_addr|   r  |  —  |intr_error_lane1_addr<18:0>|
|57:50|         busy        |   r  |  —  |         busy<7:0>         |

### mram_dout_even_lower register

- Absolute Address: 0x158
- Base Offset: 0x58
- Size: 0x8

|Bits|Identifier|Access|Reset|   Name   |
|----|----------|------|-----|----------|
|63:0|   dout   |   r  |  —  |dout<63:0>|

### mram_dout_odd_lower register

- Absolute Address: 0x160
- Base Offset: 0x60
- Size: 0x8

|Bits|Identifier|Access|Reset|    Name    |
|----|----------|------|-----|------------|
|63:0|   dout   |   r  |  —  |dout<142:79>|

### mram_dout_uppers register

- Absolute Address: 0x168
- Base Offset: 0x68
- Size: 0x8

| Bits|  Identifier |Access|Reset|     Name    |
|-----|-------------|------|-----|-------------|
| 14:0|dout_even_msb|   r  |  —  | dout<78:64> |
|46:32| dout_odd_msb|   r  |  —  |dout<157:143>|

### bist_status_0 register

- Absolute Address: 0x170
- Base Offset: 0x70
- Size: 0x8

|Bits|   Identifier   |Access|Reset|         Name         |
|----|----------------|------|-----|----------------------|
|63:0|bist_error_value|   r  |  —  |bist_error_value<63:0>|

### bist_control register

- Absolute Address: 0x178
- Base Offset: 0x78
- Size: 0x10

| Bits|     Identifier     |Access|Reset|          Name         |
|-----|--------------------|------|-----|-----------------------|
|  0  |     bist_rte_en    |  rw  | 0x0 |      bist_rte_en      |
|  1  |    bist_data_inv   |  rw  | 0x0 |     bist_data_inv     |
| 4:2 |    bist_add_inc    |  rw  | 0x0 |   bist_add_inc<2:0>   |
|  5  | bist_stop_on_error |  rw  | 0x0 |   bist_stop_on_error  |
| 25:6|   bist_start_add   |  rw  | 0x0 |  bist_start_add<19:0> |
|45:26|    bist_stop_add   |  rw  | 0x0 |  bist_stop_add<19:0>  |
|50:46|      RH4margin     |  rw  | 0xA |     RH4margin<4:0>    |
|55:51|     rh2_offset     |  rw  | 0x0 |    rh2_offset<4:0>    |
|78:64|  bist_error_value  |   r  |  —  |bist_error_value<78:64>|
|94:79|   bist_loop_count  |  rw  | 0x0 | bist_loop_count<15:0> |
|  95 |     bist_start     |  rw  | 0x0 |       bist_start      |
|  96 |   bist_trim_mode   |  rw  | 0x0 |     bist_trim_mode    |
|  97 |bist_stop_on_repl_of|  rw  | 0x0 |  bist_stop_on_repl_of |
|  98 |     bist_rst_b     |  rw  | 0x1 |       bist_rst_b      |
|  99 |     bist_reset     |  rw  | 0x0 |       bist_reset      |
| 100 |     bist_rd_en     |  rw  | 0x0 |       bist_rd_en      |
| 101 |     bist_wr_en     |  rw  | 0x0 |       bist_wr_en      |

### ecc_correction register

- Absolute Address: 0x188
- Base Offset: 0x88
- Size: 0x10

| Bits|Identifier|Access|Reset|    Name   |
|-----|----------|------|-----|-----------|
|127:0|   dout   |   r  |  —  |dout<127:0>|

### bist_status_1 register

- Absolute Address: 0x198
- Base Offset: 0x98
- Size: 0x8

|Bits| Identifier |Access|Reset|       Name       |
|----|------------|------|-----|------------------|
|19:0|bist_err_add|   r  |  —  |bist_err_add<19:0>|
| 20 | bist_error |   r  |  —  |    bist_error    |
| 21 |  bist_busy |   r  |  —  |     bist_busy    |

## bank1_tregs register file

- Absolute Address: 0x200
- Base Offset: 0x200
- Size: 0xA0

<p>Register space that contains the test registers for test functionality and debug of the MRAM.</p>

|Offset|     Identifier     |Name|
|------|--------------------|----|
| 0x00 |    mram_control    |  — |
| 0x20 | mram_control_pulse |  — |
| 0x28 |    gbl_cfg_ovr_0   |  — |
| 0x30 |      gbl_cfg_0     |  — |
| 0x38 |    man_control_0   |  — |
| 0x40 |    man_control_1   |  — |
| 0x48 |    mram_status_0   |  — |
| 0x50 |    mram_status_1   |  — |
| 0x58 |mram_dout_even_lower|  — |
| 0x60 | mram_dout_odd_lower|  — |
| 0x68 |  mram_dout_uppers  |  — |
| 0x70 |    bist_status_0   |  — |
| 0x78 |    bist_control    |  — |
| 0x88 |   ecc_correction   |  — |
| 0x98 |    bist_status_1   |  — |

### mram_control register

- Absolute Address: 0x200
- Base Offset: 0x0
- Size: 0x20

|  Bits |       Identifier      |Access|Reset|          Name         |
|-------|-----------------------|------|-----|-----------------------|
|  16:0 |        addr_in        |  rw  | 0x0 |        addr_in        |
| 24:17 |           ce          |  rw  | 0x0 |           ce          |
|   25  |           we          |  rw  | 0x0 |           we          |
|   26  |    rd_pulse_meas_en   |  rw  | 0x0 |    rd_pulse_meas_en   |
| 33:27 |        rca_ovr        |  rw  | 0x0 |        rca_ovr        |
|   34  |       rca_ovr_en      |  rw  | 0x0 |       rca_ovr_en      |
|   35  |     gbl_cfg_ovr_en    |  rw  | 0x0 |     gbl_cfg_ovr_en    |
|   36  |       rd_en_ovr       |  rw  | 0x0 |       rd_en_ovr       |
|   37  |       ref_prg_en      |  rw  | 0x0 |       ref_prg_en      |
|   38  |     dsleep_mram_en    |  rw  | 0x0 |     dsleep_mram_en    |
|   39  |reg_logic_sup_sleep_ovr|  rw  | 0x1 |reg_logic_sup_sleep_ovr|
|   40  |      prg_rd1_byp      |  rw  | 0x0 |      prg_rd1_byp      |
|   41  |       wr_en_ovr       |  rw  | 0x0 |       wr_en_ovr       |
|   42  |         dma_en        |  rw  | 0x0 |         dma_en        |
|   43  |  vblslx_gain_mode_ovr |  rw  | 0x0 |  vblslx_gain_mode_ovr |
| 47:44 | powerup_trim_load_ovr |  rw  | 0x0 | powerup_trim_load_ovr |
|   52  |      test_cal_en      |  rw  | 0x0 |      test_cal_en      |
| 55:53 |      anatest0_sel     |  rw  | 0x0 |      anatest0_sel     |
| 58:56 |      anatest1_sel     |  rw  | 0x0 |      anatest1_sel     |
|   59  |   eccrom_deep_sleep   |  rw  | 0x1 |   eccrom_deep_sleep   |
|   60  |      ref_ecc_sel      |  rw  | 0x0 |      ref_ecc_sel      |
|   61  |    disable_cpu_intr   |  rw  | 0x0 |    disable_cpu_intr   |
|   62  |      disable_ted      |  rw  | 0x0 |      disable_ted      |
|   63  |     ecc_bypass_en     |  rw  | 0x0 |     ecc_bypass_en     |
| 142:64|          bwe          |  rw  | 0x0 |          bwe          |
|  143  |      mram_clk_en      |  rw  | 0x1 |      mram_clk_en      |
|222:144|          din          |  rw  | 0x0 |          din          |
|  223  |    test_reg_ovr_en    |  rw  | 0x0 |    test_reg_ovr_en    |
|  224  |       otp_wr_en       |  rw  | 0x0 |       otp_wr_en       |
|  225  |      rst_cpu_intr     |  rw  | 0x0 |      rst_cpu_intr     |
|233:226|        dout_en        |  rw  | 0x0 |        dout_en        |
|236:234|         ecc_en        |  rw  | 0x0 |         ecc_en        |
|240:237|  even_man_stripe_sel  |  rw  | 0x0 |  even_man_stripe_sel  |
|  241  |     even_man_wr_0     |  rw  | 0x0 |     even_man_wr<0>    |
|  242  |     even_man_wr_1     |  rw  | 0x0 |     even_man_wr<1>    |
|  243  |     even_man_wr_2     |  rw  | 0x0 |     even_man_wr<2>    |
|  244  |     even_man_wr_3     |  rw  | 0x0 |     even_man_wr<3>    |
|248:245|   odd_man_stripe_sel  |  rw  | 0x0 |   odd_man_stripe_sel  |
|  249  |      odd_man_wr_0     |  rw  | 0x0 |     odd_man_wr<0>     |
|  250  |      odd_man_wr_1     |  rw  | 0x0 |     odd_man_wr<1>     |
|  251  |      odd_man_wr_2     |  rw  | 0x0 |     odd_man_wr<2>     |
|  252  |      odd_man_wr_3     |  rw  | 0x0 |     odd_man_wr<3>     |
|  253  |         sah_en        |  rw  | 0x1 |         sah_en        |
|  254  |       scc_otp_en      |  rw  | 0x0 |       scc_otp_en      |
|  255  |    maintenance_mode   |  rw  | 0x0 |    maintenance_mode   |

### mram_control_pulse register

- Absolute Address: 0x220
- Base Offset: 0x20
- Size: 0x8

|Bits|             Identifier             |Access|Reset|                 Name                |
|----|------------------------------------|------|-----|-------------------------------------|
|  0 |powerup_trim_load_ovr_single_pulse_0|  rw  | 0x0 |powerup_trim_load_ovr_single_pulse<0>|
|  1 |powerup_trim_load_ovr_single_pulse_1|  rw  | 0x0 |powerup_trim_load_ovr_single_pulse<1>|
|  2 |powerup_trim_load_ovr_single_pulse_2|  rw  | 0x0 |powerup_trim_load_ovr_single_pulse<2>|
|  3 |powerup_trim_load_ovr_single_pulse_3|  rw  | 0x0 |powerup_trim_load_ovr_single_pulse<3>|
|  4 |        mram_clk_single_pulse       |  rw  | 0x0 |        mram_clk_single_pulse        |

### gbl_cfg_ovr_0 register

- Absolute Address: 0x228
- Base Offset: 0x28
- Size: 0x8

| Bits|    Identifier   |Access|Reset|         Name         |
|-----|-----------------|------|-----|----------------------|
| 1:0 |  sa_equal_trim  |  rw  | 0x1 |  sa_equal_trim<1:0>  |
| 4:2 |vblslx_boost_trim|  rw  | 0x4 |vblslx_boost_trim<2:0>|
| 8:5 |  wr_en_msb_trim |  rw  | 0x9 |  wr_en_msb_trim<3:0> |
| 11:9|  wr_en_lsb_trim |  rw  | 0x6 |  wr_en_lsb_trim<2:0> |
|  12 | vblslx_gain_mode|  rw  | 0x0 |   vblslx_gain_mode   |
|16:13|   repulse_trim  |  rw  | 0x6 |   repulse_trim<3:0>  |
|  17 |    repulse_en   |  rw  | 0x1 |      repulse_en      |
|20:18|    rd_en_trim   |  rw  | 0x5 |    rd_en_trim<2:0>   |
|25:22| osc_wr_div_trim |  rw  | 0x3 | osc_wr_div_trim<3:0> |
|29:26|    vblsl_trim   |  rw  | 0x4 |    vblsl_trim<3:0>   |
|33:30|    tcsel_trim   |  rw  | 0x3 |    tcsel_trim<3:0>   |
|37:34|    vwlwr_trim   |  rw  | 0x7 |    vwlwr_trim<3:0>   |
|41:38|  vcr_gate_trim  |  rw  | 0xE |  vcr_gate_trim<3:0>  |

### gbl_cfg_0 register

- Absolute Address: 0x230
- Base Offset: 0x30
- Size: 0x8

| Bits|    Identifier   |Access|Reset|         Name         |
|-----|-----------------|------|-----|----------------------|
| 1:0 |  sa_equal_trim  |   r  |  —  |  sa_equal_trim<1:0>  |
| 4:2 |vblslx_boost_trim|   r  |  —  |vblslx_boost_trim<2:0>|
| 8:5 |  wr_en_msb_trim |   r  |  —  |  wr_en_msb_trim<3:0> |
| 11:9|  wr_en_lsb_trim |   r  |  —  |  wr_en_lsb_trim<2:0> |
|  12 | vblslx_gain_mode|   r  |  —  |   vblslx_gain_mode   |
|16:13|   repulse_trim  |   r  |  —  |   repulse_trim<3:0>  |
|  17 |    repulse_en   |   r  |  —  |      repulse_en      |
|20:18|    rd_en_trim   |   r  |  —  |    rd_en_trim<2:0>   |
|25:22| osc_wr_div_trim |   r  |  —  | osc_wr_div_trim<3:0> |
|29:26|    vblsl_trim   |   r  |  —  |    vblsl_trim<3:0>   |
|33:30|    tcsel_trim   |   r  |  —  |    tcsel_trim<3:0>   |
|37:34|    vwlwr_trim   |   r  |  —  |    vwlwr_trim<3:0>   |
|41:38|  vcr_gate_trim  |   r  |  —  |  vcr_gate_trim<3:0>  |

### man_control_0 register

- Absolute Address: 0x238
- Base Offset: 0x38
- Size: 0x8

| Bits|  Identifier |Access|Reset|       Name       |
|-----|-------------|------|-----|------------------|
| 3:0 |blk0_man_ccnt|   r  |  —  |blk0_man_ccnt<3:0>|
| 7:4 |blk0_man_cnfg|  rw  | 0x0 |blk0_man_cnfg<3:0>|
| 9:8 |blk0_man_fcnt|   r  |  —  |blk0_man_fcnt<1:0>|
|19:16|blk1_man_ccnt|   r  |  —  |blk1_man_ccnt<3:0>|
|23:20|blk1_man_cnfg|  rw  | 0x0 |blk1_man_cnfg<3:0>|
|25:24|blk1_man_fcnt|   r  |  —  |blk1_man_fcnt<1:0>|
|35:32|blk2_man_ccnt|   r  |  —  |blk2_man_ccnt<3:0>|
|39:36|blk2_man_cnfg|  rw  | 0x0 |blk2_man_cnfg<3:0>|
|41:40|blk2_man_fcnt|   r  |  —  |blk2_man_fcnt<1:0>|
|51:48|blk3_man_ccnt|   r  |  —  |blk3_man_ccnt<3:0>|
|55:52|blk3_man_cnfg|  rw  | 0x0 |blk3_man_cnfg<3:0>|
|57:56|blk3_man_fcnt|   r  |  —  |blk3_man_fcnt<1:0>|

### man_control_1 register

- Absolute Address: 0x240
- Base Offset: 0x40
- Size: 0x8

| Bits|  Identifier |Access|Reset|       Name       |
|-----|-------------|------|-----|------------------|
| 3:0 |blk4_man_ccnt|   r  |  —  |blk4_man_ccnt<3:0>|
| 7:4 |blk4_man_cnfg|  rw  | 0x0 |blk4_man_cnfg<3:0>|
| 9:8 |blk4_man_fcnt|   r  |  —  |blk4_man_fcnt<1:0>|
|19:16|blk5_man_ccnt|   r  |  —  |blk5_man_ccnt<3:0>|
|23:20|blk5_man_cnfg|  rw  | 0x0 |blk5_man_cnfg<3:0>|
|25:24|blk5_man_fcnt|   r  |  —  |blk5_man_fcnt<1:0>|
|35:32|blk6_man_ccnt|   r  |  —  |blk6_man_ccnt<3:0>|
|39:36|blk6_man_cnfg|  rw  | 0x0 |blk6_man_cnfg<3:0>|
|41:40|blk6_man_fcnt|   r  |  —  |blk6_man_fcnt<1:0>|
|51:48|blk7_man_ccnt|   r  |  —  |blk7_man_ccnt<3:0>|
|55:52|blk7_man_cnfg|  rw  | 0x0 |blk7_man_cnfg<3:0>|
|57:56|blk7_man_fcnt|   r  |  —  |blk7_man_fcnt<1:0>|

### mram_status_0 register

- Absolute Address: 0x248
- Base Offset: 0x48
- Size: 0x8

| Bits|   Identifier   |Access|Reset|         Name         |
|-----|----------------|------|-----|----------------------|
| 15:0| bist_error_loop|   r  |  —  | bist_error_loop<15:0>|
|33:17|bist_error_count|   r  |  —  |bist_error_count<16:0>|
|40:34|    bist_rh0    |   r  |  —  |     bist_rh0<6:0>    |
|47:41|    bist_rh1    |   r  |  —  |     bist_rh1<6:0>    |
|54:48|    bist_rh2    |   r  |  —  |     bist_rh2<6:0>    |
|56:55|  cpu_intr_flag |   r  |  —  |     cpu_intr_flag    |
|58:57|  ecc_1bit_flag |   r  |  —  |  ecc_1bit_flag<1:0>  |
|60:59|  ecc_2bit_flag |   r  |  —  |  ecc_2bit_flag<1:0>  |
|62:61|  ecc_3bit_flag |   r  |  —  |  ecc_3bit_flag<1:0>  |

### mram_status_1 register

- Absolute Address: 0x250
- Base Offset: 0x50
- Size: 0x8

| Bits|      Identifier     |Access|Reset|            Name           |
|-----|---------------------|------|-----|---------------------------|
| 1:0 |         temp        |   r  |  —  |         temp<1:0>         |
| 4:3 |       ecc_1bit      |   r  |  —  |       ecc_1bit<1:0>       |
| 6:5 |       ecc_2bit      |   r  |  —  |       ecc_2bit<1:0>       |
| 8:7 |       ecc_3bit      |   r  |  —  |       ecc_3bit<1:0>       |
|  9  |        pwr_ok       |   r  |  —  |           pwr_ok          |
|  10 |    eccrom_pwr_ok    |   r  |  —  |       eccrom_pwr_ok       |
|29:11|intr_error_lane0_addr|   r  |  —  |intr_error_lane0_addr<18:0>|
|48:30|intr_error_lane1_addr|   r  |  —  |intr_error_lane1_addr<18:0>|
|57:50|         busy        |   r  |  —  |         busy<7:0>         |

### mram_dout_even_lower register

- Absolute Address: 0x258
- Base Offset: 0x58
- Size: 0x8

|Bits|Identifier|Access|Reset|   Name   |
|----|----------|------|-----|----------|
|63:0|   dout   |   r  |  —  |dout<63:0>|

### mram_dout_odd_lower register

- Absolute Address: 0x260
- Base Offset: 0x60
- Size: 0x8

|Bits|Identifier|Access|Reset|    Name    |
|----|----------|------|-----|------------|
|63:0|   dout   |   r  |  —  |dout<142:79>|

### mram_dout_uppers register

- Absolute Address: 0x268
- Base Offset: 0x68
- Size: 0x8

| Bits|  Identifier |Access|Reset|     Name    |
|-----|-------------|------|-----|-------------|
| 14:0|dout_even_msb|   r  |  —  | dout<78:64> |
|46:32| dout_odd_msb|   r  |  —  |dout<157:143>|

### bist_status_0 register

- Absolute Address: 0x270
- Base Offset: 0x70
- Size: 0x8

|Bits|   Identifier   |Access|Reset|         Name         |
|----|----------------|------|-----|----------------------|
|63:0|bist_error_value|   r  |  —  |bist_error_value<63:0>|

### bist_control register

- Absolute Address: 0x278
- Base Offset: 0x78
- Size: 0x10

| Bits|     Identifier     |Access|Reset|          Name         |
|-----|--------------------|------|-----|-----------------------|
|  0  |     bist_rte_en    |  rw  | 0x0 |      bist_rte_en      |
|  1  |    bist_data_inv   |  rw  | 0x0 |     bist_data_inv     |
| 4:2 |    bist_add_inc    |  rw  | 0x0 |   bist_add_inc<2:0>   |
|  5  | bist_stop_on_error |  rw  | 0x0 |   bist_stop_on_error  |
| 25:6|   bist_start_add   |  rw  | 0x0 |  bist_start_add<19:0> |
|45:26|    bist_stop_add   |  rw  | 0x0 |  bist_stop_add<19:0>  |
|50:46|      RH4margin     |  rw  | 0xA |     RH4margin<4:0>    |
|55:51|     rh2_offset     |  rw  | 0x0 |    rh2_offset<4:0>    |
|78:64|  bist_error_value  |   r  |  —  |bist_error_value<78:64>|
|94:79|   bist_loop_count  |  rw  | 0x0 | bist_loop_count<15:0> |
|  95 |     bist_start     |  rw  | 0x0 |       bist_start      |
|  96 |   bist_trim_mode   |  rw  | 0x0 |     bist_trim_mode    |
|  97 |bist_stop_on_repl_of|  rw  | 0x0 |  bist_stop_on_repl_of |
|  98 |     bist_rst_b     |  rw  | 0x1 |       bist_rst_b      |
|  99 |     bist_reset     |  rw  | 0x0 |       bist_reset      |
| 100 |     bist_rd_en     |  rw  | 0x0 |       bist_rd_en      |
| 101 |     bist_wr_en     |  rw  | 0x0 |       bist_wr_en      |

### ecc_correction register

- Absolute Address: 0x288
- Base Offset: 0x88
- Size: 0x10

| Bits|Identifier|Access|Reset|    Name   |
|-----|----------|------|-----|-----------|
|127:0|   dout   |   r  |  —  |dout<127:0>|

### bist_status_1 register

- Absolute Address: 0x298
- Base Offset: 0x98
- Size: 0x8

|Bits| Identifier |Access|Reset|       Name       |
|----|------------|------|-----|------------------|
|19:0|bist_err_add|   r  |  —  |bist_err_add<19:0>|
| 20 | bist_error |   r  |  —  |    bist_error    |
| 21 |  bist_busy |   r  |  —  |     bist_busy    |

## bank2_tregs register file

- Absolute Address: 0x300
- Base Offset: 0x300
- Size: 0xA0

<p>Register space that contains the test registers for test functionality and debug of the MRAM.</p>

|Offset|     Identifier     |Name|
|------|--------------------|----|
| 0x00 |    mram_control    |  — |
| 0x20 | mram_control_pulse |  — |
| 0x28 |    gbl_cfg_ovr_0   |  — |
| 0x30 |      gbl_cfg_0     |  — |
| 0x38 |    man_control_0   |  — |
| 0x40 |    man_control_1   |  — |
| 0x48 |    mram_status_0   |  — |
| 0x50 |    mram_status_1   |  — |
| 0x58 |mram_dout_even_lower|  — |
| 0x60 | mram_dout_odd_lower|  — |
| 0x68 |  mram_dout_uppers  |  — |
| 0x70 |    bist_status_0   |  — |
| 0x78 |    bist_control    |  — |
| 0x88 |   ecc_correction   |  — |
| 0x98 |    bist_status_1   |  — |

### mram_control register

- Absolute Address: 0x300
- Base Offset: 0x0
- Size: 0x20

|  Bits |       Identifier      |Access|Reset|          Name         |
|-------|-----------------------|------|-----|-----------------------|
|  16:0 |        addr_in        |  rw  | 0x0 |        addr_in        |
| 24:17 |           ce          |  rw  | 0x0 |           ce          |
|   25  |           we          |  rw  | 0x0 |           we          |
|   26  |    rd_pulse_meas_en   |  rw  | 0x0 |    rd_pulse_meas_en   |
| 33:27 |        rca_ovr        |  rw  | 0x0 |        rca_ovr        |
|   34  |       rca_ovr_en      |  rw  | 0x0 |       rca_ovr_en      |
|   35  |     gbl_cfg_ovr_en    |  rw  | 0x0 |     gbl_cfg_ovr_en    |
|   36  |       rd_en_ovr       |  rw  | 0x0 |       rd_en_ovr       |
|   37  |       ref_prg_en      |  rw  | 0x0 |       ref_prg_en      |
|   38  |     dsleep_mram_en    |  rw  | 0x0 |     dsleep_mram_en    |
|   39  |reg_logic_sup_sleep_ovr|  rw  | 0x1 |reg_logic_sup_sleep_ovr|
|   40  |      prg_rd1_byp      |  rw  | 0x0 |      prg_rd1_byp      |
|   41  |       wr_en_ovr       |  rw  | 0x0 |       wr_en_ovr       |
|   42  |         dma_en        |  rw  | 0x0 |         dma_en        |
|   43  |  vblslx_gain_mode_ovr |  rw  | 0x0 |  vblslx_gain_mode_ovr |
| 47:44 | powerup_trim_load_ovr |  rw  | 0x0 | powerup_trim_load_ovr |
|   52  |      test_cal_en      |  rw  | 0x0 |      test_cal_en      |
| 55:53 |      anatest0_sel     |  rw  | 0x0 |      anatest0_sel     |
| 58:56 |      anatest1_sel     |  rw  | 0x0 |      anatest1_sel     |
|   59  |   eccrom_deep_sleep   |  rw  | 0x1 |   eccrom_deep_sleep   |
|   60  |      ref_ecc_sel      |  rw  | 0x0 |      ref_ecc_sel      |
|   61  |    disable_cpu_intr   |  rw  | 0x0 |    disable_cpu_intr   |
|   62  |      disable_ted      |  rw  | 0x0 |      disable_ted      |
|   63  |     ecc_bypass_en     |  rw  | 0x0 |     ecc_bypass_en     |
| 142:64|          bwe          |  rw  | 0x0 |          bwe          |
|  143  |      mram_clk_en      |  rw  | 0x1 |      mram_clk_en      |
|222:144|          din          |  rw  | 0x0 |          din          |
|  223  |    test_reg_ovr_en    |  rw  | 0x0 |    test_reg_ovr_en    |
|  224  |       otp_wr_en       |  rw  | 0x0 |       otp_wr_en       |
|  225  |      rst_cpu_intr     |  rw  | 0x0 |      rst_cpu_intr     |
|233:226|        dout_en        |  rw  | 0x0 |        dout_en        |
|236:234|         ecc_en        |  rw  | 0x0 |         ecc_en        |
|240:237|  even_man_stripe_sel  |  rw  | 0x0 |  even_man_stripe_sel  |
|  241  |     even_man_wr_0     |  rw  | 0x0 |     even_man_wr<0>    |
|  242  |     even_man_wr_1     |  rw  | 0x0 |     even_man_wr<1>    |
|  243  |     even_man_wr_2     |  rw  | 0x0 |     even_man_wr<2>    |
|  244  |     even_man_wr_3     |  rw  | 0x0 |     even_man_wr<3>    |
|248:245|   odd_man_stripe_sel  |  rw  | 0x0 |   odd_man_stripe_sel  |
|  249  |      odd_man_wr_0     |  rw  | 0x0 |     odd_man_wr<0>     |
|  250  |      odd_man_wr_1     |  rw  | 0x0 |     odd_man_wr<1>     |
|  251  |      odd_man_wr_2     |  rw  | 0x0 |     odd_man_wr<2>     |
|  252  |      odd_man_wr_3     |  rw  | 0x0 |     odd_man_wr<3>     |
|  253  |         sah_en        |  rw  | 0x1 |         sah_en        |
|  254  |       scc_otp_en      |  rw  | 0x0 |       scc_otp_en      |
|  255  |    maintenance_mode   |  rw  | 0x0 |    maintenance_mode   |

### mram_control_pulse register

- Absolute Address: 0x320
- Base Offset: 0x20
- Size: 0x8

|Bits|             Identifier             |Access|Reset|                 Name                |
|----|------------------------------------|------|-----|-------------------------------------|
|  0 |powerup_trim_load_ovr_single_pulse_0|  rw  | 0x0 |powerup_trim_load_ovr_single_pulse<0>|
|  1 |powerup_trim_load_ovr_single_pulse_1|  rw  | 0x0 |powerup_trim_load_ovr_single_pulse<1>|
|  2 |powerup_trim_load_ovr_single_pulse_2|  rw  | 0x0 |powerup_trim_load_ovr_single_pulse<2>|
|  3 |powerup_trim_load_ovr_single_pulse_3|  rw  | 0x0 |powerup_trim_load_ovr_single_pulse<3>|
|  4 |        mram_clk_single_pulse       |  rw  | 0x0 |        mram_clk_single_pulse        |

### gbl_cfg_ovr_0 register

- Absolute Address: 0x328
- Base Offset: 0x28
- Size: 0x8

| Bits|    Identifier   |Access|Reset|         Name         |
|-----|-----------------|------|-----|----------------------|
| 1:0 |  sa_equal_trim  |  rw  | 0x1 |  sa_equal_trim<1:0>  |
| 4:2 |vblslx_boost_trim|  rw  | 0x4 |vblslx_boost_trim<2:0>|
| 8:5 |  wr_en_msb_trim |  rw  | 0x9 |  wr_en_msb_trim<3:0> |
| 11:9|  wr_en_lsb_trim |  rw  | 0x6 |  wr_en_lsb_trim<2:0> |
|  12 | vblslx_gain_mode|  rw  | 0x0 |   vblslx_gain_mode   |
|16:13|   repulse_trim  |  rw  | 0x6 |   repulse_trim<3:0>  |
|  17 |    repulse_en   |  rw  | 0x1 |      repulse_en      |
|20:18|    rd_en_trim   |  rw  | 0x5 |    rd_en_trim<2:0>   |
|25:22| osc_wr_div_trim |  rw  | 0x3 | osc_wr_div_trim<3:0> |
|29:26|    vblsl_trim   |  rw  | 0x4 |    vblsl_trim<3:0>   |
|33:30|    tcsel_trim   |  rw  | 0x3 |    tcsel_trim<3:0>   |
|37:34|    vwlwr_trim   |  rw  | 0x7 |    vwlwr_trim<3:0>   |
|41:38|  vcr_gate_trim  |  rw  | 0xE |  vcr_gate_trim<3:0>  |

### gbl_cfg_0 register

- Absolute Address: 0x330
- Base Offset: 0x30
- Size: 0x8

| Bits|    Identifier   |Access|Reset|         Name         |
|-----|-----------------|------|-----|----------------------|
| 1:0 |  sa_equal_trim  |   r  |  —  |  sa_equal_trim<1:0>  |
| 4:2 |vblslx_boost_trim|   r  |  —  |vblslx_boost_trim<2:0>|
| 8:5 |  wr_en_msb_trim |   r  |  —  |  wr_en_msb_trim<3:0> |
| 11:9|  wr_en_lsb_trim |   r  |  —  |  wr_en_lsb_trim<2:0> |
|  12 | vblslx_gain_mode|   r  |  —  |   vblslx_gain_mode   |
|16:13|   repulse_trim  |   r  |  —  |   repulse_trim<3:0>  |
|  17 |    repulse_en   |   r  |  —  |      repulse_en      |
|20:18|    rd_en_trim   |   r  |  —  |    rd_en_trim<2:0>   |
|25:22| osc_wr_div_trim |   r  |  —  | osc_wr_div_trim<3:0> |
|29:26|    vblsl_trim   |   r  |  —  |    vblsl_trim<3:0>   |
|33:30|    tcsel_trim   |   r  |  —  |    tcsel_trim<3:0>   |
|37:34|    vwlwr_trim   |   r  |  —  |    vwlwr_trim<3:0>   |
|41:38|  vcr_gate_trim  |   r  |  —  |  vcr_gate_trim<3:0>  |

### man_control_0 register

- Absolute Address: 0x338
- Base Offset: 0x38
- Size: 0x8

| Bits|  Identifier |Access|Reset|       Name       |
|-----|-------------|------|-----|------------------|
| 3:0 |blk0_man_ccnt|   r  |  —  |blk0_man_ccnt<3:0>|
| 7:4 |blk0_man_cnfg|  rw  | 0x0 |blk0_man_cnfg<3:0>|
| 9:8 |blk0_man_fcnt|   r  |  —  |blk0_man_fcnt<1:0>|
|19:16|blk1_man_ccnt|   r  |  —  |blk1_man_ccnt<3:0>|
|23:20|blk1_man_cnfg|  rw  | 0x0 |blk1_man_cnfg<3:0>|
|25:24|blk1_man_fcnt|   r  |  —  |blk1_man_fcnt<1:0>|
|35:32|blk2_man_ccnt|   r  |  —  |blk2_man_ccnt<3:0>|
|39:36|blk2_man_cnfg|  rw  | 0x0 |blk2_man_cnfg<3:0>|
|41:40|blk2_man_fcnt|   r  |  —  |blk2_man_fcnt<1:0>|
|51:48|blk3_man_ccnt|   r  |  —  |blk3_man_ccnt<3:0>|
|55:52|blk3_man_cnfg|  rw  | 0x0 |blk3_man_cnfg<3:0>|
|57:56|blk3_man_fcnt|   r  |  —  |blk3_man_fcnt<1:0>|

### man_control_1 register

- Absolute Address: 0x340
- Base Offset: 0x40
- Size: 0x8

| Bits|  Identifier |Access|Reset|       Name       |
|-----|-------------|------|-----|------------------|
| 3:0 |blk4_man_ccnt|   r  |  —  |blk4_man_ccnt<3:0>|
| 7:4 |blk4_man_cnfg|  rw  | 0x0 |blk4_man_cnfg<3:0>|
| 9:8 |blk4_man_fcnt|   r  |  —  |blk4_man_fcnt<1:0>|
|19:16|blk5_man_ccnt|   r  |  —  |blk5_man_ccnt<3:0>|
|23:20|blk5_man_cnfg|  rw  | 0x0 |blk5_man_cnfg<3:0>|
|25:24|blk5_man_fcnt|   r  |  —  |blk5_man_fcnt<1:0>|
|35:32|blk6_man_ccnt|   r  |  —  |blk6_man_ccnt<3:0>|
|39:36|blk6_man_cnfg|  rw  | 0x0 |blk6_man_cnfg<3:0>|
|41:40|blk6_man_fcnt|   r  |  —  |blk6_man_fcnt<1:0>|
|51:48|blk7_man_ccnt|   r  |  —  |blk7_man_ccnt<3:0>|
|55:52|blk7_man_cnfg|  rw  | 0x0 |blk7_man_cnfg<3:0>|
|57:56|blk7_man_fcnt|   r  |  —  |blk7_man_fcnt<1:0>|

### mram_status_0 register

- Absolute Address: 0x348
- Base Offset: 0x48
- Size: 0x8

| Bits|   Identifier   |Access|Reset|         Name         |
|-----|----------------|------|-----|----------------------|
| 15:0| bist_error_loop|   r  |  —  | bist_error_loop<15:0>|
|33:17|bist_error_count|   r  |  —  |bist_error_count<16:0>|
|40:34|    bist_rh0    |   r  |  —  |     bist_rh0<6:0>    |
|47:41|    bist_rh1    |   r  |  —  |     bist_rh1<6:0>    |
|54:48|    bist_rh2    |   r  |  —  |     bist_rh2<6:0>    |
|56:55|  cpu_intr_flag |   r  |  —  |     cpu_intr_flag    |
|58:57|  ecc_1bit_flag |   r  |  —  |  ecc_1bit_flag<1:0>  |
|60:59|  ecc_2bit_flag |   r  |  —  |  ecc_2bit_flag<1:0>  |
|62:61|  ecc_3bit_flag |   r  |  —  |  ecc_3bit_flag<1:0>  |

### mram_status_1 register

- Absolute Address: 0x350
- Base Offset: 0x50
- Size: 0x8

| Bits|      Identifier     |Access|Reset|            Name           |
|-----|---------------------|------|-----|---------------------------|
| 1:0 |         temp        |   r  |  —  |         temp<1:0>         |
| 4:3 |       ecc_1bit      |   r  |  —  |       ecc_1bit<1:0>       |
| 6:5 |       ecc_2bit      |   r  |  —  |       ecc_2bit<1:0>       |
| 8:7 |       ecc_3bit      |   r  |  —  |       ecc_3bit<1:0>       |
|  9  |        pwr_ok       |   r  |  —  |           pwr_ok          |
|  10 |    eccrom_pwr_ok    |   r  |  —  |       eccrom_pwr_ok       |
|29:11|intr_error_lane0_addr|   r  |  —  |intr_error_lane0_addr<18:0>|
|48:30|intr_error_lane1_addr|   r  |  —  |intr_error_lane1_addr<18:0>|
|57:50|         busy        |   r  |  —  |         busy<7:0>         |

### mram_dout_even_lower register

- Absolute Address: 0x358
- Base Offset: 0x58
- Size: 0x8

|Bits|Identifier|Access|Reset|   Name   |
|----|----------|------|-----|----------|
|63:0|   dout   |   r  |  —  |dout<63:0>|

### mram_dout_odd_lower register

- Absolute Address: 0x360
- Base Offset: 0x60
- Size: 0x8

|Bits|Identifier|Access|Reset|    Name    |
|----|----------|------|-----|------------|
|63:0|   dout   |   r  |  —  |dout<142:79>|

### mram_dout_uppers register

- Absolute Address: 0x368
- Base Offset: 0x68
- Size: 0x8

| Bits|  Identifier |Access|Reset|     Name    |
|-----|-------------|------|-----|-------------|
| 14:0|dout_even_msb|   r  |  —  | dout<78:64> |
|46:32| dout_odd_msb|   r  |  —  |dout<157:143>|

### bist_status_0 register

- Absolute Address: 0x370
- Base Offset: 0x70
- Size: 0x8

|Bits|   Identifier   |Access|Reset|         Name         |
|----|----------------|------|-----|----------------------|
|63:0|bist_error_value|   r  |  —  |bist_error_value<63:0>|

### bist_control register

- Absolute Address: 0x378
- Base Offset: 0x78
- Size: 0x10

| Bits|     Identifier     |Access|Reset|          Name         |
|-----|--------------------|------|-----|-----------------------|
|  0  |     bist_rte_en    |  rw  | 0x0 |      bist_rte_en      |
|  1  |    bist_data_inv   |  rw  | 0x0 |     bist_data_inv     |
| 4:2 |    bist_add_inc    |  rw  | 0x0 |   bist_add_inc<2:0>   |
|  5  | bist_stop_on_error |  rw  | 0x0 |   bist_stop_on_error  |
| 25:6|   bist_start_add   |  rw  | 0x0 |  bist_start_add<19:0> |
|45:26|    bist_stop_add   |  rw  | 0x0 |  bist_stop_add<19:0>  |
|50:46|      RH4margin     |  rw  | 0xA |     RH4margin<4:0>    |
|55:51|     rh2_offset     |  rw  | 0x0 |    rh2_offset<4:0>    |
|78:64|  bist_error_value  |   r  |  —  |bist_error_value<78:64>|
|94:79|   bist_loop_count  |  rw  | 0x0 | bist_loop_count<15:0> |
|  95 |     bist_start     |  rw  | 0x0 |       bist_start      |
|  96 |   bist_trim_mode   |  rw  | 0x0 |     bist_trim_mode    |
|  97 |bist_stop_on_repl_of|  rw  | 0x0 |  bist_stop_on_repl_of |
|  98 |     bist_rst_b     |  rw  | 0x1 |       bist_rst_b      |
|  99 |     bist_reset     |  rw  | 0x0 |       bist_reset      |
| 100 |     bist_rd_en     |  rw  | 0x0 |       bist_rd_en      |
| 101 |     bist_wr_en     |  rw  | 0x0 |       bist_wr_en      |

### ecc_correction register

- Absolute Address: 0x388
- Base Offset: 0x88
- Size: 0x10

| Bits|Identifier|Access|Reset|    Name   |
|-----|----------|------|-----|-----------|
|127:0|   dout   |   r  |  —  |dout<127:0>|

### bist_status_1 register

- Absolute Address: 0x398
- Base Offset: 0x98
- Size: 0x8

|Bits| Identifier |Access|Reset|       Name       |
|----|------------|------|-----|------------------|
|19:0|bist_err_add|   r  |  —  |bist_err_add<19:0>|
| 20 | bist_error |   r  |  —  |    bist_error    |
| 21 |  bist_busy |   r  |  —  |     bist_busy    |

## bank3_tregs register file

- Absolute Address: 0x400
- Base Offset: 0x400
- Size: 0xA0

<p>Register space that contains the test registers for test functionality and debug of the MRAM.</p>

|Offset|     Identifier     |Name|
|------|--------------------|----|
| 0x00 |    mram_control    |  — |
| 0x20 | mram_control_pulse |  — |
| 0x28 |    gbl_cfg_ovr_0   |  — |
| 0x30 |      gbl_cfg_0     |  — |
| 0x38 |    man_control_0   |  — |
| 0x40 |    man_control_1   |  — |
| 0x48 |    mram_status_0   |  — |
| 0x50 |    mram_status_1   |  — |
| 0x58 |mram_dout_even_lower|  — |
| 0x60 | mram_dout_odd_lower|  — |
| 0x68 |  mram_dout_uppers  |  — |
| 0x70 |    bist_status_0   |  — |
| 0x78 |    bist_control    |  — |
| 0x88 |   ecc_correction   |  — |
| 0x98 |    bist_status_1   |  — |

### mram_control register

- Absolute Address: 0x400
- Base Offset: 0x0
- Size: 0x20

|  Bits |       Identifier      |Access|Reset|          Name         |
|-------|-----------------------|------|-----|-----------------------|
|  16:0 |        addr_in        |  rw  | 0x0 |        addr_in        |
| 24:17 |           ce          |  rw  | 0x0 |           ce          |
|   25  |           we          |  rw  | 0x0 |           we          |
|   26  |    rd_pulse_meas_en   |  rw  | 0x0 |    rd_pulse_meas_en   |
| 33:27 |        rca_ovr        |  rw  | 0x0 |        rca_ovr        |
|   34  |       rca_ovr_en      |  rw  | 0x0 |       rca_ovr_en      |
|   35  |     gbl_cfg_ovr_en    |  rw  | 0x0 |     gbl_cfg_ovr_en    |
|   36  |       rd_en_ovr       |  rw  | 0x0 |       rd_en_ovr       |
|   37  |       ref_prg_en      |  rw  | 0x0 |       ref_prg_en      |
|   38  |     dsleep_mram_en    |  rw  | 0x0 |     dsleep_mram_en    |
|   39  |reg_logic_sup_sleep_ovr|  rw  | 0x1 |reg_logic_sup_sleep_ovr|
|   40  |      prg_rd1_byp      |  rw  | 0x0 |      prg_rd1_byp      |
|   41  |       wr_en_ovr       |  rw  | 0x0 |       wr_en_ovr       |
|   42  |         dma_en        |  rw  | 0x0 |         dma_en        |
|   43  |  vblslx_gain_mode_ovr |  rw  | 0x0 |  vblslx_gain_mode_ovr |
| 47:44 | powerup_trim_load_ovr |  rw  | 0x0 | powerup_trim_load_ovr |
|   52  |      test_cal_en      |  rw  | 0x0 |      test_cal_en      |
| 55:53 |      anatest0_sel     |  rw  | 0x0 |      anatest0_sel     |
| 58:56 |      anatest1_sel     |  rw  | 0x0 |      anatest1_sel     |
|   59  |   eccrom_deep_sleep   |  rw  | 0x1 |   eccrom_deep_sleep   |
|   60  |      ref_ecc_sel      |  rw  | 0x0 |      ref_ecc_sel      |
|   61  |    disable_cpu_intr   |  rw  | 0x0 |    disable_cpu_intr   |
|   62  |      disable_ted      |  rw  | 0x0 |      disable_ted      |
|   63  |     ecc_bypass_en     |  rw  | 0x0 |     ecc_bypass_en     |
| 142:64|          bwe          |  rw  | 0x0 |          bwe          |
|  143  |      mram_clk_en      |  rw  | 0x1 |      mram_clk_en      |
|222:144|          din          |  rw  | 0x0 |          din          |
|  223  |    test_reg_ovr_en    |  rw  | 0x0 |    test_reg_ovr_en    |
|  224  |       otp_wr_en       |  rw  | 0x0 |       otp_wr_en       |
|  225  |      rst_cpu_intr     |  rw  | 0x0 |      rst_cpu_intr     |
|233:226|        dout_en        |  rw  | 0x0 |        dout_en        |
|236:234|         ecc_en        |  rw  | 0x0 |         ecc_en        |
|240:237|  even_man_stripe_sel  |  rw  | 0x0 |  even_man_stripe_sel  |
|  241  |     even_man_wr_0     |  rw  | 0x0 |     even_man_wr<0>    |
|  242  |     even_man_wr_1     |  rw  | 0x0 |     even_man_wr<1>    |
|  243  |     even_man_wr_2     |  rw  | 0x0 |     even_man_wr<2>    |
|  244  |     even_man_wr_3     |  rw  | 0x0 |     even_man_wr<3>    |
|248:245|   odd_man_stripe_sel  |  rw  | 0x0 |   odd_man_stripe_sel  |
|  249  |      odd_man_wr_0     |  rw  | 0x0 |     odd_man_wr<0>     |
|  250  |      odd_man_wr_1     |  rw  | 0x0 |     odd_man_wr<1>     |
|  251  |      odd_man_wr_2     |  rw  | 0x0 |     odd_man_wr<2>     |
|  252  |      odd_man_wr_3     |  rw  | 0x0 |     odd_man_wr<3>     |
|  253  |         sah_en        |  rw  | 0x1 |         sah_en        |
|  254  |       scc_otp_en      |  rw  | 0x0 |       scc_otp_en      |
|  255  |    maintenance_mode   |  rw  | 0x0 |    maintenance_mode   |

### mram_control_pulse register

- Absolute Address: 0x420
- Base Offset: 0x20
- Size: 0x8

|Bits|             Identifier             |Access|Reset|                 Name                |
|----|------------------------------------|------|-----|-------------------------------------|
|  0 |powerup_trim_load_ovr_single_pulse_0|  rw  | 0x0 |powerup_trim_load_ovr_single_pulse<0>|
|  1 |powerup_trim_load_ovr_single_pulse_1|  rw  | 0x0 |powerup_trim_load_ovr_single_pulse<1>|
|  2 |powerup_trim_load_ovr_single_pulse_2|  rw  | 0x0 |powerup_trim_load_ovr_single_pulse<2>|
|  3 |powerup_trim_load_ovr_single_pulse_3|  rw  | 0x0 |powerup_trim_load_ovr_single_pulse<3>|
|  4 |        mram_clk_single_pulse       |  rw  | 0x0 |        mram_clk_single_pulse        |

### gbl_cfg_ovr_0 register

- Absolute Address: 0x428
- Base Offset: 0x28
- Size: 0x8

| Bits|    Identifier   |Access|Reset|         Name         |
|-----|-----------------|------|-----|----------------------|
| 1:0 |  sa_equal_trim  |  rw  | 0x1 |  sa_equal_trim<1:0>  |
| 4:2 |vblslx_boost_trim|  rw  | 0x4 |vblslx_boost_trim<2:0>|
| 8:5 |  wr_en_msb_trim |  rw  | 0x9 |  wr_en_msb_trim<3:0> |
| 11:9|  wr_en_lsb_trim |  rw  | 0x6 |  wr_en_lsb_trim<2:0> |
|  12 | vblslx_gain_mode|  rw  | 0x0 |   vblslx_gain_mode   |
|16:13|   repulse_trim  |  rw  | 0x6 |   repulse_trim<3:0>  |
|  17 |    repulse_en   |  rw  | 0x1 |      repulse_en      |
|20:18|    rd_en_trim   |  rw  | 0x5 |    rd_en_trim<2:0>   |
|25:22| osc_wr_div_trim |  rw  | 0x3 | osc_wr_div_trim<3:0> |
|29:26|    vblsl_trim   |  rw  | 0x4 |    vblsl_trim<3:0>   |
|33:30|    tcsel_trim   |  rw  | 0x3 |    tcsel_trim<3:0>   |
|37:34|    vwlwr_trim   |  rw  | 0x7 |    vwlwr_trim<3:0>   |
|41:38|  vcr_gate_trim  |  rw  | 0xE |  vcr_gate_trim<3:0>  |

### gbl_cfg_0 register

- Absolute Address: 0x430
- Base Offset: 0x30
- Size: 0x8

| Bits|    Identifier   |Access|Reset|         Name         |
|-----|-----------------|------|-----|----------------------|
| 1:0 |  sa_equal_trim  |   r  |  —  |  sa_equal_trim<1:0>  |
| 4:2 |vblslx_boost_trim|   r  |  —  |vblslx_boost_trim<2:0>|
| 8:5 |  wr_en_msb_trim |   r  |  —  |  wr_en_msb_trim<3:0> |
| 11:9|  wr_en_lsb_trim |   r  |  —  |  wr_en_lsb_trim<2:0> |
|  12 | vblslx_gain_mode|   r  |  —  |   vblslx_gain_mode   |
|16:13|   repulse_trim  |   r  |  —  |   repulse_trim<3:0>  |
|  17 |    repulse_en   |   r  |  —  |      repulse_en      |
|20:18|    rd_en_trim   |   r  |  —  |    rd_en_trim<2:0>   |
|25:22| osc_wr_div_trim |   r  |  —  | osc_wr_div_trim<3:0> |
|29:26|    vblsl_trim   |   r  |  —  |    vblsl_trim<3:0>   |
|33:30|    tcsel_trim   |   r  |  —  |    tcsel_trim<3:0>   |
|37:34|    vwlwr_trim   |   r  |  —  |    vwlwr_trim<3:0>   |
|41:38|  vcr_gate_trim  |   r  |  —  |  vcr_gate_trim<3:0>  |

### man_control_0 register

- Absolute Address: 0x438
- Base Offset: 0x38
- Size: 0x8

| Bits|  Identifier |Access|Reset|       Name       |
|-----|-------------|------|-----|------------------|
| 3:0 |blk0_man_ccnt|   r  |  —  |blk0_man_ccnt<3:0>|
| 7:4 |blk0_man_cnfg|  rw  | 0x0 |blk0_man_cnfg<3:0>|
| 9:8 |blk0_man_fcnt|   r  |  —  |blk0_man_fcnt<1:0>|
|19:16|blk1_man_ccnt|   r  |  —  |blk1_man_ccnt<3:0>|
|23:20|blk1_man_cnfg|  rw  | 0x0 |blk1_man_cnfg<3:0>|
|25:24|blk1_man_fcnt|   r  |  —  |blk1_man_fcnt<1:0>|
|35:32|blk2_man_ccnt|   r  |  —  |blk2_man_ccnt<3:0>|
|39:36|blk2_man_cnfg|  rw  | 0x0 |blk2_man_cnfg<3:0>|
|41:40|blk2_man_fcnt|   r  |  —  |blk2_man_fcnt<1:0>|
|51:48|blk3_man_ccnt|   r  |  —  |blk3_man_ccnt<3:0>|
|55:52|blk3_man_cnfg|  rw  | 0x0 |blk3_man_cnfg<3:0>|
|57:56|blk3_man_fcnt|   r  |  —  |blk3_man_fcnt<1:0>|

### man_control_1 register

- Absolute Address: 0x440
- Base Offset: 0x40
- Size: 0x8

| Bits|  Identifier |Access|Reset|       Name       |
|-----|-------------|------|-----|------------------|
| 3:0 |blk4_man_ccnt|   r  |  —  |blk4_man_ccnt<3:0>|
| 7:4 |blk4_man_cnfg|  rw  | 0x0 |blk4_man_cnfg<3:0>|
| 9:8 |blk4_man_fcnt|   r  |  —  |blk4_man_fcnt<1:0>|
|19:16|blk5_man_ccnt|   r  |  —  |blk5_man_ccnt<3:0>|
|23:20|blk5_man_cnfg|  rw  | 0x0 |blk5_man_cnfg<3:0>|
|25:24|blk5_man_fcnt|   r  |  —  |blk5_man_fcnt<1:0>|
|35:32|blk6_man_ccnt|   r  |  —  |blk6_man_ccnt<3:0>|
|39:36|blk6_man_cnfg|  rw  | 0x0 |blk6_man_cnfg<3:0>|
|41:40|blk6_man_fcnt|   r  |  —  |blk6_man_fcnt<1:0>|
|51:48|blk7_man_ccnt|   r  |  —  |blk7_man_ccnt<3:0>|
|55:52|blk7_man_cnfg|  rw  | 0x0 |blk7_man_cnfg<3:0>|
|57:56|blk7_man_fcnt|   r  |  —  |blk7_man_fcnt<1:0>|

### mram_status_0 register

- Absolute Address: 0x448
- Base Offset: 0x48
- Size: 0x8

| Bits|   Identifier   |Access|Reset|         Name         |
|-----|----------------|------|-----|----------------------|
| 15:0| bist_error_loop|   r  |  —  | bist_error_loop<15:0>|
|33:17|bist_error_count|   r  |  —  |bist_error_count<16:0>|
|40:34|    bist_rh0    |   r  |  —  |     bist_rh0<6:0>    |
|47:41|    bist_rh1    |   r  |  —  |     bist_rh1<6:0>    |
|54:48|    bist_rh2    |   r  |  —  |     bist_rh2<6:0>    |
|56:55|  cpu_intr_flag |   r  |  —  |     cpu_intr_flag    |
|58:57|  ecc_1bit_flag |   r  |  —  |  ecc_1bit_flag<1:0>  |
|60:59|  ecc_2bit_flag |   r  |  —  |  ecc_2bit_flag<1:0>  |
|62:61|  ecc_3bit_flag |   r  |  —  |  ecc_3bit_flag<1:0>  |

### mram_status_1 register

- Absolute Address: 0x450
- Base Offset: 0x50
- Size: 0x8

| Bits|      Identifier     |Access|Reset|            Name           |
|-----|---------------------|------|-----|---------------------------|
| 1:0 |         temp        |   r  |  —  |         temp<1:0>         |
| 4:3 |       ecc_1bit      |   r  |  —  |       ecc_1bit<1:0>       |
| 6:5 |       ecc_2bit      |   r  |  —  |       ecc_2bit<1:0>       |
| 8:7 |       ecc_3bit      |   r  |  —  |       ecc_3bit<1:0>       |
|  9  |        pwr_ok       |   r  |  —  |           pwr_ok          |
|  10 |    eccrom_pwr_ok    |   r  |  —  |       eccrom_pwr_ok       |
|29:11|intr_error_lane0_addr|   r  |  —  |intr_error_lane0_addr<18:0>|
|48:30|intr_error_lane1_addr|   r  |  —  |intr_error_lane1_addr<18:0>|
|57:50|         busy        |   r  |  —  |         busy<7:0>         |

### mram_dout_even_lower register

- Absolute Address: 0x458
- Base Offset: 0x58
- Size: 0x8

|Bits|Identifier|Access|Reset|   Name   |
|----|----------|------|-----|----------|
|63:0|   dout   |   r  |  —  |dout<63:0>|

### mram_dout_odd_lower register

- Absolute Address: 0x460
- Base Offset: 0x60
- Size: 0x8

|Bits|Identifier|Access|Reset|    Name    |
|----|----------|------|-----|------------|
|63:0|   dout   |   r  |  —  |dout<142:79>|

### mram_dout_uppers register

- Absolute Address: 0x468
- Base Offset: 0x68
- Size: 0x8

| Bits|  Identifier |Access|Reset|     Name    |
|-----|-------------|------|-----|-------------|
| 14:0|dout_even_msb|   r  |  —  | dout<78:64> |
|46:32| dout_odd_msb|   r  |  —  |dout<157:143>|

### bist_status_0 register

- Absolute Address: 0x470
- Base Offset: 0x70
- Size: 0x8

|Bits|   Identifier   |Access|Reset|         Name         |
|----|----------------|------|-----|----------------------|
|63:0|bist_error_value|   r  |  —  |bist_error_value<63:0>|

### bist_control register

- Absolute Address: 0x478
- Base Offset: 0x78
- Size: 0x10

| Bits|     Identifier     |Access|Reset|          Name         |
|-----|--------------------|------|-----|-----------------------|
|  0  |     bist_rte_en    |  rw  | 0x0 |      bist_rte_en      |
|  1  |    bist_data_inv   |  rw  | 0x0 |     bist_data_inv     |
| 4:2 |    bist_add_inc    |  rw  | 0x0 |   bist_add_inc<2:0>   |
|  5  | bist_stop_on_error |  rw  | 0x0 |   bist_stop_on_error  |
| 25:6|   bist_start_add   |  rw  | 0x0 |  bist_start_add<19:0> |
|45:26|    bist_stop_add   |  rw  | 0x0 |  bist_stop_add<19:0>  |
|50:46|      RH4margin     |  rw  | 0xA |     RH4margin<4:0>    |
|55:51|     rh2_offset     |  rw  | 0x0 |    rh2_offset<4:0>    |
|78:64|  bist_error_value  |   r  |  —  |bist_error_value<78:64>|
|94:79|   bist_loop_count  |  rw  | 0x0 | bist_loop_count<15:0> |
|  95 |     bist_start     |  rw  | 0x0 |       bist_start      |
|  96 |   bist_trim_mode   |  rw  | 0x0 |     bist_trim_mode    |
|  97 |bist_stop_on_repl_of|  rw  | 0x0 |  bist_stop_on_repl_of |
|  98 |     bist_rst_b     |  rw  | 0x1 |       bist_rst_b      |
|  99 |     bist_reset     |  rw  | 0x0 |       bist_reset      |
| 100 |     bist_rd_en     |  rw  | 0x0 |       bist_rd_en      |
| 101 |     bist_wr_en     |  rw  | 0x0 |       bist_wr_en      |

### ecc_correction register

- Absolute Address: 0x488
- Base Offset: 0x88
- Size: 0x10

| Bits|Identifier|Access|Reset|    Name   |
|-----|----------|------|-----|-----------|
|127:0|   dout   |   r  |  —  |dout<127:0>|

### bist_status_1 register

- Absolute Address: 0x498
- Base Offset: 0x98
- Size: 0x8

|Bits| Identifier |Access|Reset|       Name       |
|----|------------|------|-----|------------------|
|19:0|bist_err_add|   r  |  —  |bist_err_add<19:0>|
| 20 | bist_error |   r  |  —  |    bist_error    |
| 21 |  bist_busy |   r  |  —  |     bist_busy    |
