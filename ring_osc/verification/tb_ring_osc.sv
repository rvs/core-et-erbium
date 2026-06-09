`timescale 1ps/1ps

// Top-level cocotb testbench wrapper for ring_osc.
// cocotb drives and monitors all signals via VPI/DPI against this module.
module tb_ring_osc;

    logic        clk;
    logic [4:0]  trm;
    logic        divby2_sel;
    logic        en;
    logic        dbg_en;
    logic        dbg_anachip_en;
    logic        dbg_rohcip_en;
    logic        dbg_sah_en_b;

    ring_osc dut (
        .clk            (clk),
        .trm            (trm),
        .divby2_sel     (divby2_sel),
        .en             (en),
        .dbg_en         (dbg_en),
        .dbg_anachip_en (dbg_anachip_en),
        .dbg_rohcip_en  (dbg_rohcip_en),
        .dbg_sah_en_b   (dbg_sah_en_b)
    );

`ifdef DUMP_VCD
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_ring_osc);
    end
`endif

endmodule
