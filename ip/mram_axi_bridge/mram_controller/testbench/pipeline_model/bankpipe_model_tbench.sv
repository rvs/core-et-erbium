module bankpipe_model_tbench #(
        parameter  NUM_INSTANCES        =   8,
        parameter  ADDR_WIDTH           =  17,
        parameter  DATA_WIDTH           =  64
    )
    (
        input   logic                          mem_clk_en_i,
        input   logic                          rst_b_i,
        input   logic                          clk_i,
        input   logic  [(NUM_INSTANCES-1):0]   ce_i,
        input   logic                          we_i,
        input   logic  [(ADDR_WIDTH-1):0]      addr_i,
        input   logic  [(DATA_WIDTH-1):0]      din_i,
        input   logic  [(DATA_WIDTH-1):0]      bwe_i,
        input   logic  [(NUM_INSTANCES-1):0]   dout_en_i,
        output  logic  [((2*DATA_WIDTH)-1):0]  dout_o,
        output  logic  [(NUM_INSTANCES-1):0]   busy_o
    );

    logic  mem_clk_en;

    always @(negedge rst_b_i or negedge clk_i) begin
      if (!rst_b_i) begin
        mem_clk_en  =  1'b0;
      end else begin
        mem_clk_en  =  mem_clk_en_i;
      end
    end

    assign mem_clk  =  mem_clk_en ? clk_i  :  1'b0;

    erbium_et_bank #(
        .NUM_INSTANCES(NUM_INSTANCES),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
        )  i0  (
        .rst_b_i(rst_b_i),
        .clk_i(mem_clk),
        .ce_i(ce_i),
        .we_i(we_i),
        .addr_i(addr_i),
        .din_i(din_i),
        .bwe_i(bwe_i),
        .dout_en_i(dout_en_i),
        .dout_o(dout_o),
        .busy_o(busy_o)
    );
    
`ifdef COCOTB_SIM
  initial begin
    $vcdpluson();
    //$dumpfile("dump.vcd");
    $dumpvars();
  end
`endif

endmodule  :  bankpipe_model_tbench
