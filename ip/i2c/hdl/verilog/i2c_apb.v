/*
 Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2026-02-04
 Description: A brief description of the file's purpose.
*/
module i2c_apb(
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

wire i2c_sda_t, i2c_scl_t;
assign i2c_scl_oe = ~i2c_scl_t;
assign i2c_sda_oe = ~i2c_sda_t;


 I2C_Reg_pkg::I2C_Reg__in_t hwif_in;
 I2C_Reg_pkg::I2C_Reg__out_t hwif_out;

I2C_Reg i2c_reg (
.clk(clk),
.arst_n(arst_n),

.s_apb_psel(s_apb_psel),
.s_apb_penable(s_apb_penable),
.s_apb_pwrite(s_apb_pwrite),
.s_apb_pprot(s_apb_pprot),
.s_apb_paddr(s_apb_paddr),
.s_apb_pwdata(s_apb_pwdata),
.s_apb_pstrb(s_apb_pstrb),
.s_apb_pready(s_apb_pready),
.s_apb_prdata(s_apb_prdata),
.s_apb_pslverr(s_apb_pslverr),
.hwif_in(hwif_in),
.hwif_out(hwif_out)
);

    wire [12:0] cmd_ff_din = {hwif_out.Commands.address.value,
    hwif_out.Commands.start.value,
    hwif_out.Commands.read.value,
    hwif_out.Commands.write.value,
    hwif_out.Commands.write_multiple.value,
    hwif_out.Commands.stop.value};
    wire [7:0] cmd_ff_dout_address;
    wire cmd_ff_dout_start;
    wire cmd_ff_dout_read;
    wire cmd_ff_dout_write;
    wire cmd_ff_dout_write_multiple;
    wire cmd_ff_dout_stop;
FIFO2#(.width(13)) cmd_fifo(
.CLK(clk),
.RST(arst_n),
.D_IN(cmd_ff_din),
.ENQ(hwif_out.Commands.enq.value),
.FULL_N(hwif_in.Status.cmd_ff_n_full.next),
.D_OUT( {
    cmd_ff_dout_address,
    cmd_ff_dout_start,
    cmd_ff_dout_read,
    cmd_ff_dout_write,
    cmd_ff_dout_write_multiple,
    cmd_ff_dout_stop }
),
.DEQ(cmd_ff_deq && cmd_ff_empty_n),
.EMPTY_N(cmd_ff_empty_n),
.CLR(1'b0)
);

reg tx_fifo_enq, rx_fifo_deq;
always @(posedge clk)begin
tx_fifo_enq <= hwif_out.Wdata.wdata.swmod;
rx_fifo_deq <= hwif_out.Rdata.rdata.swacc;
end

wire tx_last;
wire [7:0] tx_data;
FIFO2#(.width(9)) Tx_fifo(
.CLK(clk),
.RST(arst_n),
.D_IN({hwif_out.Wdata.wlast.value,hwif_out.Wdata.wdata.value}),
.ENQ(tx_fifo_enq),
.FULL_N(hwif_in.Status.tx_ff_n_full.next),
.D_OUT( { tx_last,tx_data }),
.DEQ(tx_ff_deq && tx_ff_empty_n),
.EMPTY_N(tx_ff_empty_n),
.CLR(1'b0)
);

wire rx_last;
wire [7:0] rx_data;
wire rx_ff_empty;
assign hwif_in.Status.rx_ff_n_full.next = rx_ff_empty;

FIFO2#(.width(9)) Rx_fifo(
.CLK(clk),
.RST(arst_n),
.D_IN({rx_last,rx_data}),
.ENQ(rx_enq),
.FULL_N(rx_full_n),
.D_OUT({hwif_in.Rdata.rlast.next,hwif_in.Rdata.rdata.next}),
.DEQ(rx_fifo_deq && rx_ff_empty),
.EMPTY_N(rx_ff_empty),
.CLR(1'b0)
);
assign hwif_in.Status.rx_overflow.next= rx_enq && !rx_full_n;
i2c_master i2c_master (
    .clk(clk),
    .rst(!arst_n),
    /*
     * Host interface
     */
    .s_axis_cmd_address(hwif_out.Commands.address.value),
    .s_axis_cmd_start(hwif_out.Commands.start.value),
    .s_axis_cmd_read(hwif_out.Commands.read.value),
    .s_axis_cmd_write(hwif_out.Commands.write.value),
    .s_axis_cmd_write_multiple(hwif_out.Commands.write_multiple.value),
    .s_axis_cmd_stop(hwif_out.Commands.stop.value),
    .s_axis_cmd_valid(cmd_ff_empty_n),
    .s_axis_cmd_ready(cmd_ff_deq),

    .s_axis_data_tdata(tx_data),
    .s_axis_data_tvalid(tx_ff_empty_n),
    .s_axis_data_tready(tx_ff_deq),
    .s_axis_data_tlast(tx_last),

    .m_axis_data_tdata(rx_data),
    .m_axis_data_tvalid(rx_enq),
    .m_axis_data_tready(rx_full_n),
    .m_axis_data_tlast(rx_last),

    /*
     * I2C interface
     */
    .scl_i(i2c_scl_i),
    .scl_o(i2c_scl_o),
    .scl_t(i2c_scl_t),
    .sda_i(i2c_sda_i),
    .sda_o(i2c_sda_o),
    .sda_t(i2c_sda_t),

    /*
     * Status
     */
   .busy(hwif_in.Status.busy.next),
   .bus_control(hwif_in.Status.bus_control.next),
   .bus_active(hwif_in.Status.bus_active.next),
   .missed_ack(hwif_in.Status.missed_ack.hwset),

    /*
     * Configuration
     */
    .prescale(hwif_out.Cfg.prescale.value),
    .stop_on_idle(hwif_out.Cfg.stop_on_idle.value)  
);
endmodule
