module et_ctrl_mux (
    input  logic         sel,
    input  logic [16:0]  bist_add,
    input  logic [7:0]   bist_dout_en,
    input  logic [7:0]   bist_ce,
    input  logic         bist_we,
    input  logic [78:0]  bist_din,
    input  logic [78:0]  bist_bwe,
    input  logic [16:0]  axi_add,
    input  logic [7:0]   axi_ce,
    input  logic [7:0]   axi_dout_en,
    input  logic         axi_we,
    input  logic [78:0]  axi_din,
    input  logic [78:0]  axi_bwe,
    output logic [16:0]  mram_add,
    output logic [7:0]   mram_ce,
    output logic [7:0]   mram_dout_en,
    output logic         mram_we,
    output logic [78:0]  mram_bwe,
    output logic [78:0]  mram_din
);
    always_comb begin
        unique casez (sel)
            1'b0 : begin //axi signals
                mram_add = axi_add;
                mram_ce  = axi_ce;
                mram_dout_en = axi_dout_en;
                mram_we  = axi_we;
                mram_bwe = axi_bwe;
                mram_din = axi_din;
            end 
            1'b1 : begin //bist signals
                mram_add = bist_add;
                mram_ce  = bist_ce;
                mram_dout_en = bist_dout_en;
                mram_we  = bist_we;
                mram_bwe = bist_bwe;
                mram_din = bist_din;
            end
            default : begin //axi signals
                mram_add = axi_add;
                mram_ce  = axi_ce;
                mram_dout_en = axi_dout_en;
                mram_we  = axi_we;
                mram_bwe = axi_bwe;
                mram_din = axi_din;
            end
        endcase
    end
endmodule
