module bist_mux #(
    parameter ADD_WIDTH = 20,
    parameter DATA_WIDTH = 79,
    parameter STRB_WIDTH = (DATA_WIDTH/8)
) (
    //input [1:0]                     sel,
    input                           bist_en_i,
    input                           test_reg_ovr_en_i,

    // BIST signals
    input [3:0]                     bist_stripe_sel_i,
    input                           bist_we_i,
    input [DATA_WIDTH-1:0]          bist_bwe_i,
    input [DATA_WIDTH-1:0]          bist_din_i,
    input                           bist_ref_prg_en_i,
    input                           bist_rca_ovr_en_i,
    input [ADD_WIDTH-3:0]           bist_add_i,
    input [6:0]                     bist_rca_ovr_i,
    input                           bist_done_i,
    input                           bist_clk_en_i,
    // Test register signals
    //input                           reg_ce_b,
    input [3:0]                     reg_stripe_sel_i,
    input                           reg_we_i,
    input [DATA_WIDTH-1:0]          reg_bwe_i,
    input [DATA_WIDTH-1:0]          reg_din_i,
    input                           reg_ref_prg_en_i,
    input                           reg_rca_ovr_en_i,
    input [ADD_WIDTH-3:0]           reg_add_i,
    input [6:0]                     reg_rca_ovr_i,
    input                           reg_done_i,
    input                           reg_clk_en_i,

    output reg                      bist_rca_ovr_en_o,
    output reg [6:0]                bist_rca_ovr_o,
    output reg [3:0]                bist_stripe_sel_o,
    output reg                      bist_we_o,
    output reg                      bist_ref_prg_en_o,
    output reg [DATA_WIDTH-1:0]     bist_bwe_o,
    output reg [DATA_WIDTH-1:0]     bist_din_o,
    output reg [ADD_WIDTH-3:0]      bist_add_o,
    output reg                      bist_clk_en_o,


    output reg                      bist_done_o,
    output logic                    cmx_bist_sel

);
    logic  [1:0]  sel;

    always_comb begin
        sel           =  {bist_en_i, test_reg_ovr_en_i};
        cmx_bist_sel  =  | sel;
        unique casez (sel)
            2'b10 : begin // BIST
                bist_rca_ovr_en_o = bist_rca_ovr_en_i;
                bist_rca_ovr_o    = bist_rca_ovr_i;
                bist_stripe_sel_o = bist_stripe_sel_i;
                bist_we_o         = bist_we_i;
                bist_bwe_o        = bist_bwe_i;
                bist_ref_prg_en_o = bist_ref_prg_en_i | reg_ref_prg_en_i;
                bist_din_o        = bist_din_i;
                bist_add_o        = bist_add_i;
                bist_clk_en_o     = bist_clk_en_i;
            end
            2'b01 : begin //registers
                bist_rca_ovr_en_o   = reg_rca_ovr_en_i;
                bist_rca_ovr_o      = reg_rca_ovr_i;
                bist_stripe_sel_o   = reg_stripe_sel_i;
                bist_we_o           = reg_we_i;
                bist_ref_prg_en_o   = reg_ref_prg_en_i;
                bist_bwe_o          = reg_bwe_i;
                bist_din_o          = reg_din_i;
                bist_add_o          = reg_add_i;
                bist_clk_en_o       = reg_clk_en_i;
            end
            default : begin //registers
                bist_rca_ovr_en_o   = reg_rca_ovr_en_i;
                bist_rca_ovr_o      = reg_rca_ovr_i;
                bist_stripe_sel_o   = reg_stripe_sel_i;
                bist_we_o           = reg_we_i;
                bist_ref_prg_en_o   = reg_ref_prg_en_i;
                bist_bwe_o          = reg_bwe_i;
                bist_din_o          = reg_din_i;
                bist_add_o          = reg_add_i;
                bist_clk_en_o       = reg_clk_en_i;
            end
        endcase

        bist_done_o = bist_done_i;
    end

endmodule
