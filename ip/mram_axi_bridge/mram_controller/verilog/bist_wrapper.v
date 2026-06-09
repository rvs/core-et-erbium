module bist_wrapper #(
    parameter ADD_WIDTH = 20,
    parameter DATA_WIDTH = 79,
    parameter STRB_WIDTH = (DATA_WIDTH/8)
)(
    input                           clk,
    input                           rst_b,
    input                           busy,
    input                           bist_rte_en,
    input                           bist_wr_en,
    input                           bist_rd_en,
    input                           bist_reset,
    input                           bist_start,
    input        [2:0]              ecc_en,
    input                           ecc_1bit,
    input                           ecc_2bit,
    input                           ecc_3bit,
    input        [78:0]             mram_dout,
    input        [78:0]             rom_data,
    input        [4:0]              RH_margin,
    input        [ADD_WIDTH-1:0]    start_add,
    input        [ADD_WIDTH-1:0]    stop_add,
    input        [2:0]              bist_add_inc,
    input                           stop_on_err,
    input        [15:0]             loop_cnt,
    input                           trim_mode,
    input                           stop_on_repl_of,

    //input                         reg_ce_b,
    input                           reg_ovr_en,
    input        [3:0]              reg_stripe_sel,
    input                           reg_we,
    input                           reg_ref_prg_en,
    input                           reg_rca_ovr_en,
    input                           reg_clk_en,
    input        [6:0]              reg_rca_ovr,
    input        [DATA_WIDTH-1:0]   reg_bwe,
    //input        [ADD_WIDTH-1:0]  reg_add,
    input        [ADD_WIDTH-3:0]    reg_add,
    input        [DATA_WIDTH-1:0]   reg_din,
    input                           data_inv,

    //output  reg                   bist_ce_b,
    output  reg  [3:0]              bist_stripe_sel,
    output  reg                     bist_we,
    output  reg  [78:0]             bist_bwe,
    output  reg                     bist_ref_prg_en,
    output  reg                     bist_rca_ovr_en,
    output  reg  [6:0]              bist_rca_ovr,
    output  reg  [78:0]             bist_din,
    output  reg  [ADD_WIDTH-3:0]    bist_add,
    output  logic                   cmx_bist_sel,
    output  reg  [7:0]              rom_add,
    output  reg                     bist_busy,
    output  reg                     bist_err,
    output  reg  [ADD_WIDTH-1:0]    bist_err_add,
    output  reg  [16-1:0]           bist_error_loop,       
    output  reg  [7-1:0]            bist_rh0,              
    output  reg  [7-1:0]            bist_rh1,              
    output  reg  [7-1:0]            bist_rh2,              
    output  reg  [17-1:0]           bist_error_count,      
    output  reg  [79-1:0]           bist_error_value,      
    //output  reg  [19:0]             replacement_add [23:0],
    output  reg                     clk_en,
    output  reg                     rom_ce
);

    wire                          mkBist_we;
    wire         [DATA_WIDTH-1:0] mkBist_din;
    wire                          rte_ref_prg_en;
    wire                          rte_rca_ovr_en;
    //wire         [ADD_WIDTH-1:0]  rte_add;
    wire         [ADD_WIDTH-3:0]  mkBist_add;
    wire                          rte_done;
    //wire                          rte_ce_b;
    wire         [3:0]            mkBist_stripe_sel;
    wire         [6:0]            mkBist_rca_ovr;
    wire                          mkBist_clk_en;
    wire                          mkBist_ref_prg_en;
    //wire                          wr_ce_b;
    wire         [3:0]            wr_stripe_sel;
    wire                          wr_we;
    wire         [DATA_WIDTH-1:0] wr_bwe;
    wire         [DATA_WIDTH-1:0] wr_din;
    wire                          wr_ref_prg_en;
    wire                          wr_rca_ovr_en;
    //wire         [ADD_WIDTH-1:0]  wr_add;
    wire         [ADD_WIDTH-3:0]  wr_add;
    wire         [6:0]            wr_rca_ovr;
    wire                          wr_done;
    //wire         [ADD_WIDTH-1:0]  rd_add;
    wire         [ADD_WIDTH-3:0]  rd_add;
    wire         [DATA_WIDTH-1:0] rd_din;
    wire         [DATA_WIDTH-1:0] rd_bwe;
    wire         [6:0]            rd_rca_ovr;
    wire         [3:0]            rd_stripe_sel;



    assign rd_bwe = 78'h0;
    bist_mux bist_mux_u(
        .bist_en_i(bist_rd_en | bist_rte_en | bist_wr_en),
        .test_reg_ovr_en_i(reg_ovr_en),

        .bist_stripe_sel_i(mkBist_stripe_sel),
        .bist_we_i(mkBist_we),
        .bist_bwe_i(reg_bwe),
        .bist_din_i(mkBist_din),
        .bist_ref_prg_en_i(mkBist_ref_prg_en),
        .bist_rca_ovr_en_i(reg_rca_ovr_en),
        .bist_add_i(mkBist_add),
        .bist_rca_ovr_i(reg_rca_ovr),
        .bist_done_i(mkBist_status_regs.busy),
        .bist_clk_en_i(mkBist_clk_en),


        .reg_stripe_sel_i(reg_stripe_sel),
        .reg_we_i(reg_we),
        .reg_bwe_i(reg_bwe),
        .reg_din_i(reg_din),
        .reg_ref_prg_en_i(reg_ref_prg_en),
        .reg_rca_ovr_en_i(reg_rca_ovr_en),
        .reg_add_i(reg_add),
        .reg_rca_ovr_i(reg_rca_ovr),
        .reg_done_i(1'b0),
        .reg_clk_en_i(reg_clk_en),

        .bist_rca_ovr_en_o(bist_rca_ovr_en),
        .bist_rca_ovr_o(bist_rca_ovr),
        .bist_stripe_sel_o(bist_stripe_sel),
        .bist_we_o(bist_we),
        .bist_ref_prg_en_o(bist_ref_prg_en),
        .bist_bwe_o(bist_bwe),
        .bist_din_o(bist_din),
        .bist_add_o(bist_add),
        .bist_done_o(bist_busy),
        .bist_clk_en_o(clk_en),

        .cmx_bist_sel(cmx_bist_sel)
    );

    typedef struct packed {
        logic start;
        logic bist_wr_en;
        logic bist_rd_en;
        logic bist_rte_en;
        logic bist_reset;
        logic [20-1:0] start_addr;
        logic [20-1:0] stop_addr;
        logic [3-1:0]  addr_inc;
        logic [16-1:0] loop_cnt; // TODO Max loop value

        logic stop_on_error;
        logic data_inv;
        logic trim_mode;
        logic [4:0] rh4_margin;
        logic stop_on_repl_of;
        ///
        logic [78:0] din;
        logic [78:0] bwe;
    } Bist_Cfg_Regs;

    typedef struct packed {
        logic               busy;
        logic               bist_error;
        logic [20-1:0]      error_address;
        logic [16-1:0]      error_loop;
        logic [7-1:0]       rh0;
        logic [7-1:0]       rh1;
        logic [7-1:0]       rh2;
        logic [16-1:0]      error_count;
        logic [79-1:0]      error_value;
    } Bist_Status_Regs;

    Bist_Cfg_Regs       mkBist_cfg_regs;
    Bist_Status_Regs    mkBist_status_regs;

    assign mkBist_cfg_regs.start = bist_start;
    assign mkBist_cfg_regs.bist_wr_en = bist_wr_en;
    assign mkBist_cfg_regs.bist_rd_en = bist_rd_en;
    assign mkBist_cfg_regs.bist_rte_en = bist_rte_en;
    assign mkBist_cfg_regs.start_addr = start_add;
    assign mkBist_cfg_regs.stop_addr = stop_add;
    assign mkBist_cfg_regs.addr_inc = bist_add_inc;
    assign mkBist_cfg_regs.loop_cnt = loop_cnt;
    assign mkBist_cfg_regs.stop_on_error = stop_on_err;
    assign mkBist_cfg_regs.data_inv = data_inv;
    assign mkBist_cfg_regs.trim_mode = trim_mode;
    assign mkBist_cfg_regs.rh4_margin = RH_margin;
    assign mkBist_cfg_regs.stop_on_repl_of = stop_on_repl_of;
    assign mkBist_cfg_regs.din = reg_din;
    assign mkBist_cfg_regs.bwe = reg_bwe;
    assign mkBist_cfg_regs.bist_reset = bist_reset;

    always @* bist_err_add          = mkBist_status_regs.error_address;
    always @* bist_err              = mkBist_status_regs.bist_error;
    always @* bist_error_loop       = mkBist_status_regs.error_loop;
    always @* bist_rh0              = mkBist_status_regs.rh0;
    always @* bist_rh1              = mkBist_status_regs.rh1;
    always @* bist_rh2              = mkBist_status_regs.rh2;
    always @* bist_error_count      = mkBist_status_regs.error_count;
    always @* bist_error_value      = mkBist_status_regs.error_value;

    mkBist bist_u(
        .CLK(clk),
        .clk_en(mkBist_clk_en),
        .RST_B(rst_b),
        .rdata_i(mram_dout),
        .busy_i(busy),
        .stripe_sel(mkBist_stripe_sel),
        .address(mkBist_add),
        .wdata(mkBist_din),
        .wen(mkBist_we),
        .ref_prg_en(mkBist_ref_prg_en),
        .rom_addr(rom_add),
        .rom_ce(rom_ce),
        .rom_dout_i(rom_data),
        .cfg_regs(mkBist_cfg_regs),
        .status(mkBist_status_regs)

    );

endmodule : bist_wrapper
