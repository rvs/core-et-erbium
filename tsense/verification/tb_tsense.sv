`timescale 1ps/1ps

module tb_tsense;

  // Waveform annotation — display as ASCII in viewer
  reg [8*24-1:0] test_label;

  logic       sys_clk;
  logic       rst_n;
  logic       conv;
  logic [2:0] sen_sel;
  logic [7:0] clk_div;
  logic [3:0] data;
  logic       valid;

  tsense_wrap u_wrap (
    .sys_clk (sys_clk),
    .rst_n   (rst_n),
    .conv    (conv),
    .sen_sel (sen_sel),
    .clk_div (clk_div),
    .data    (data),
    .valid   (valid)
  );

`ifdef DUMP_VCD
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_tsense);
  end
`endif

endmodule
