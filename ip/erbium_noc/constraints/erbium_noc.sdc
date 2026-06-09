# SPDX-License-Identifier: Apache-2.0
# SDC for the erbium_noc NoC — 4 asynchronous clock domains.
# Four mutually-asynchronous clock domains (CPU / SYSTEM / XSPI / PERIPH).

create_clock -name CPU_ACLK    -period 1.000 [get_ports CPU_CLK]    ;# 1000 MHz
create_clock -name SYSTEM_ACLK -period 4.000 [get_ports SYSTEM_CLK] ;#  250 MHz
create_clock -name XSPI_ACLK   -period 5.000 [get_ports XSPI_CLK]   ;#  200 MHz
create_clock -name PERIPH_ACLK -period 8.000 [get_ports PERIPH_CLK] ;#  125 MHz

set_clock_groups -asynchronous \
  -group {CPU_ACLK} -group {SYSTEM_ACLK} -group {XSPI_ACLK} -group {PERIPH_ACLK}

# Per-domain I/O budget = 60% of period (matches the original instance's SDC).
set_input_delay  -clock CPU_ACLK    [expr 1.000*0.6] [all_inputs]
set_output_delay -clock CPU_ACLK    [expr 1.000*0.6] [all_outputs]
