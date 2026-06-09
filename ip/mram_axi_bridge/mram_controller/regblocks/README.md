<!---
Markdown description for SystemRDL register map.

Don't override. Generated from: controller_regs
  - systemrdl/erbium_test_registers.rdl
  - systemrdl/top.rdl
-->

## controller_regs address map

- Absolute Address: 0x0
- Base Offset: 0x0
- Size: 0xA0

|Offset|Identifier|                 Name                 |
|------|----------|--------------------------------------|
|  0x0 | test_regs|MRAM Control and Status Test Registers|

## test_regs register file

- Absolute Address: 0x0
- Base Offset: 0x0
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

- Absolute Address: 0x0
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

- Absolute Address: 0x20
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

- Absolute Address: 0x28
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

- Absolute Address: 0x30
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

- Absolute Address: 0x38
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

- Absolute Address: 0x40
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

- Absolute Address: 0x48
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

- Absolute Address: 0x50
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

- Absolute Address: 0x58
- Base Offset: 0x58
- Size: 0x8

|Bits|Identifier|Access|Reset|   Name   |
|----|----------|------|-----|----------|
|63:0|   dout   |   r  |  —  |dout<63:0>|

### mram_dout_odd_lower register

- Absolute Address: 0x60
- Base Offset: 0x60
- Size: 0x8

|Bits|Identifier|Access|Reset|    Name    |
|----|----------|------|-----|------------|
|63:0|   dout   |   r  |  —  |dout<142:79>|

### mram_dout_uppers register

- Absolute Address: 0x68
- Base Offset: 0x68
- Size: 0x8

| Bits|  Identifier |Access|Reset|     Name    |
|-----|-------------|------|-----|-------------|
| 14:0|dout_even_msb|   r  |  —  | dout<78:64> |
|46:32| dout_odd_msb|   r  |  —  |dout<157:143>|

### bist_status_0 register

- Absolute Address: 0x70
- Base Offset: 0x70
- Size: 0x8

|Bits|   Identifier   |Access|Reset|         Name         |
|----|----------------|------|-----|----------------------|
|63:0|bist_error_value|   r  |  —  |bist_error_value<63:0>|

### bist_control register

- Absolute Address: 0x78
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

- Absolute Address: 0x88
- Base Offset: 0x88
- Size: 0x10

| Bits|Identifier|Access|Reset|    Name   |
|-----|----------|------|-----|-----------|
|127:0|   dout   |   r  |  —  |dout<127:0>|

### bist_status_1 register

- Absolute Address: 0x98
- Base Offset: 0x98
- Size: 0x8

|Bits| Identifier |Access|Reset|       Name       |
|----|------------|------|-----|------------------|
|19:0|bist_err_add|   r  |  —  |bist_err_add<19:0>|
| 20 | bist_error |   r  |  —  |    bist_error    |
| 21 |  bist_busy |   r  |  —  |     bist_busy    |
