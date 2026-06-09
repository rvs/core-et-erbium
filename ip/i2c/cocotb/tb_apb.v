module tb_apb(
    input  wire        clk,
    input  wire        arst_n,


    /*
     * Host interface
     */
    input wire s_apb_psel,
    input wire s_apb_penable,
    input wire s_apb_pwrite,
    input wire [2:0] s_apb_pprot,
    input wire [5:0] s_apb_paddr,
    input wire [31:0] s_apb_pwdata,
    input wire [3:0] s_apb_pstrb,
    output logic s_apb_pready,
    output logic [31:0] s_apb_prdata,
    output logic s_apb_pslverr,
    /*
     * I2C interface
     */
    input  wire        i2c_scl_i,
    output wire        i2c_scl_o,
    output wire        i2c_scl_oe,
    input  wire        i2c_sda_i,
    output wire        i2c_sda_o,
    output wire        i2c_sda_oe
);
wire i2c_scl_i_int = i2c_scl_oe? 1'b0 : i2c_scl_i;
wire i2c_sda_i_int = i2c_sda_oe? 1'b0 : i2c_sda_i;
pullup(i2c_scl_i_int);
pullup(i2c_sda_i_int);
i2c_apb dut(
  .i2c_scl_i(i2c_scl_i_int),
  .i2c_sda_i(i2c_sda_i_int),
  .*);
 initial begin
 	    $vcdplusdeltacycleon();
 	    $vcdpluson();
 	    $vcdplusmemon();
 end
endmodule
