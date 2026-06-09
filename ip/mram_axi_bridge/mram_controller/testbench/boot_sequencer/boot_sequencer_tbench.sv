module boot_sequencer_tbench (
    input   logic             clk_i,
    input   logic             rst_bi,
    input   logic             pwr_ok_i,
    input   logic             nvsram_startup_bypass_i,
    input   logic             mram_busy_i,
    input   logic             reg_logic_sup_sleep_ovr_i,

    output  logic             mram_rst_bo,
    output  logic             pwr_up_sel_o,
    output  logic             reg_logic_sup_sleep_o,
    output  logic             axi_busy_o
  );
  boot_sequencer ibtseq (
    .clk_i(clk_i),
    .rst_bi(rst_bi),
    .pwr_ok_i(pwr_ok_i),
    .nvsram_startup_bypass_i(nvsram_startup_bypass_i),
    .mram_busy_i(mram_busy_i),
    .reg_logic_sup_sleep_ovr_i(reg_logic_sup_sleep_ovr_i),
    .mram_rst_bo(mram_rst_bo),
    .pwr_up_sel_o(pwr_up_sel_o),
    .reg_logic_sup_sleep_o(reg_logic_sup_sleep_o),
    .axi_busy_o(axi_busy_o)
  );

  `ifdef COCOTB_SIM
    initial begin
      $vcdpluson();
      //$dumpfile("dump.vcd");
      $dumpvars();
      //$dumpfile("dump.vcd");
      //$dumpvars(0, boot_sequencer_tbench);
    end
  `endif
endmodule : boot_sequencer_tbench
