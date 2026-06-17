// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: Copyright (c) 2026 Ainekko, Co.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


module tb #(
) (
// Test Signals
    inout       ANATEST0,
    inout       ANATEST1,
    input wire  TestMode,
    output wire OSC_CLK_OUT,
    output wire ring_osc_clk,
    input wire brownout_b,

    // xSPI IO Signals
    input wire XSPI_CSN,
    input wire [7:0] XSPI_DQ_IN,
    output wire [7:0] XSPI_DQ_OUT,
    output wire XSPI_DQ_OEN,
    input wire XSPI_RWDS_IN,
    output wire XSPI_RWDS_OUT,
    output wire XSPI_RWDS_OEN,
    input wire [1:0]xspi_mode,
    // UART
    input wire UART_RX,
    output wire UART_TX,
    output wire UART_TX_ENA,
    //I2C
    output wire i2c_scl_o,
    output wire i2c_scl_t,
    output wire i2c_sda_o,
    output wire i2c_sda_t,
    input wire i2c_sda_i,
    input wire i2c_scl_i,
    // QSPI
    output wire qspi_csn,
    output wire qspi_sclk,
    output wire [3:0] qspi_dq_out,
    output wire [3:0] qspi_dq_out_ena,
    input wire [3:0] qspi_dq_in,
    // GPIO
    input wire [10:0] gpio_i,
    output wire [10:0] gpio_o,
    output wire [10:0] gpio_oe,

    // Analog signals
// JTAG
    input wire TMS,
    input wire TDI,
    input wire TRSTn,
    output wire TDO,
    output wire TDOEN,


        input wire probe_cmd_start,
        input wire probe_ext_start,
        input wire probe_address_start,
        input wire probe_latency_start,
        input wire probe_data_start,
        input wire probe_cmd_end,
        input wire probe_ext_end,
        input wire probe_address_end,
        input wire probe_latency_end,
        input wire probe_data_end,
        input wire flag,
	input wire xspi_clk_en,
	input wire [331:0] xspi_fsm
);
wire [10:0] gpio_in;
wire [10:0] gpio_out;
wire [10:0] gpio_out_ena;
assign gpio_oe=gpio_out_ena;
assign gpio_o=gpio_out;
assign gpio_in[0] = gpio_i[0];
assign OSC_CLK_OUT = gpio_out[0];

assign gpio_in[1] = et.erbium_digital.i2c_enable ? gpio_oe[1]?i2c_scl_o:i2c_scl_i:gpio_i[1];
assign i2c_scl_o =  gpio_out[1];

assign gpio_in[2] = et.erbium_digital.i2c_enable ? gpio_oe[2]? i2c_sda_o:i2c_sda_i:gpio_i[2];
assign i2c_sda_o = gpio_out[2];

assign gpio_in[3]= gpio_i[3];
assign qspi_csn=gpio_out[3];

assign gpio_in[4]= gpio_i[4];
assign qspi_clk=gpio_out[4];

assign gpio_in[6:5] = et.erbium_digital.spi_enable ? qspi_dq_in[1:0]:gpio_i[6:5];
assign qspi_dq_out[1:0] =  gpio_out[6:5];

assign gpio_in[8:7] = et.erbium_digital.qspi_enable ? qspi_dq_in[3:2]:gpio_i[8:7];
assign qspi_dq_out[3:2] =  gpio_out[8:7];

assign gpio_in[9] = gpio_i[9];
assign UART_TX =  gpio_out[9];

assign gpio_in[10] = et.erbium_digital.uart_enable ? UART_RX:gpio_i[10];
//assign qspi_dq_out[10] =  gpio_out[10];

reg XSPI_CLK;
`ifndef UPF
	assign et.prcm_et.xspi_power_good=1'b1;
	assign et.prcm_et.cpu_power_good=1'b1;
	assign et.prcm_et.chip_power_good=1'b1;
	assign et.prcm_et.mram_power_good=1'b1;
	assign et.prcm_et.periph_power_good=1'b1;
`endif
    wire [2:0] drive_strength;

erbium_digital_et_aon et( .*);

wire TCK=XSPI_CLK;
assign ring_osc_clk=et.ring_osc_clk;

`ifndef VERILATOR
  `ifdef WAVES
 initial begin
 	    $vcdplusdeltacycleon();
 	    $vcdpluson();
 	    $vcdplusmemon();
 end
`endif
`endif

`ifdef ET_SIMULATION
 `ifdef VCS
   import "DPI-C" context function void vcs_startOfSim();  // Constructs the Checker TB
   import "DPI-C" context function void vcs_endOfReset();  // Indicates end of reset to start executing code
   initial begin
      $display("SYSTEM: Start Simulation");
      vcs_startOfSim();
      @(negedge et.cpu_reset_cold);
      $display("SYSTEM: cpu_reset_cold done");
      vcs_endOfReset();
   end

   // Signal test done for cocotb in test_elf flow
   bit cpu_done;
   int cpu_num_errors;
   export "DPI-C" function cpu_done_DPI;
   function void cpu_done_DPI(input int errors);
      begin
         $display("Calling cpu done DPI");
         if (cpu_done === 0) begin
            $display("cpu_done_DPI setting cpu_done=1 and num errors=%d", errors);
            cpu_num_errors = errors;
            cpu_done = 1'b1; // Needs to be last to avoid triggering cocotb before data is available
         end
      end
   endfunction
 `endif
`endif

// initial begin
// 	XSPI_CLK =0;
// 	forever
// 	#35 XSPI_CLK = ~ XSPI_CLK;
// end

initial begin
	forever begin
		XSPI_CLK = 0;
		#5;
		while(xspi_clk_en)begin
			#5 XSPI_CLK = 1;
			#5 XSPI_CLK = 0;
		end
	end
end
endmodule
