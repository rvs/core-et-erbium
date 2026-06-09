module ring_osc(
    output logic        clk,
    input  logic [4:0]  trm,
    input  logic        divby2_sel,
    input  logic        en,

    // Debug signals.
    input  logic        dbg_en,
    input  logic        dbg_anachip_en,
    input  logic        dbg_rohcip_en,
    input  logic        dbg_sah_en_b

);
    logic h1_mnvdd09_g; // This is an analog signal.
    logic anachip_en, anachip_en_b;
    logic rohcip_en, rohcip_en_b;
    logic sah_en_b;

    assign anachip_en       = dbg_en == 0? en : dbg_anachip_en;
    assign rohcip_en        = dbg_en == 0? en : dbg_rohcip_en;
    assign sah_en_b         = dbg_en == 0? 1'b0 : dbg_sah_en_b;

    assign anachip_en_b     = ~anachip_en;
    assign rohcip_en_b      = ~rohcip_en;

    anachip u_anachip (
        .en             (anachip_en),
        .en_b           (anachip_en_b),
        .h1_mnvdd09_g   (h1_mnvdd09_g),
        .sah_en_b       (sah_en_b),
        .vdd            (),
        .vdd18          (),
        .vss            ()
    );
    rochip u_rochip (
        .clk            (clk),
        .divby2_sel     (divby2_sel),
        .en             (rohcip_en),
        .en_b           (rohcip_en_b),
        .h1_mnvdd09_g   (h1_mnvdd09_g),
        .trm            (trm),
        .vdd            (),
        .vdd18          (),
        .vss            ()
    );

endmodule