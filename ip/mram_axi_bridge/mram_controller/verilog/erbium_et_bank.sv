`ifndef ET_BANK_NUM_INSTANCES
  `define ET_BANK_NUM_INSTANCES 8
`endif

`ifndef ET_BANK_ADDR_WIDTH
  `define ET_BANK_ADDR_WIDTH 17
`endif

`ifndef ET_BANK_DATA_WIDTH
  `define ET_BANK_DATA_WIDTH 64
`endif


//module erbium_et_bank #(
module bank_et #(
        parameter NUM_INSTANCES        =  `ET_BANK_NUM_INSTANCES,
        parameter ADDR_WIDTH           =  `ET_BANK_ADDR_WIDTH,
        parameter DATA_WIDTH           =  `ET_BANK_DATA_WIDTH
    )
    (
        input   logic                          rst_b,
        input   logic  [3:0]                   clk,
        input   logic  [(NUM_INSTANCES-1):0]   ce,
        input   logic                          we,
        input   logic  [(ADDR_WIDTH-1):0]      addr_in,
        input   logic  [(DATA_WIDTH-1):0]      din,
        input   logic  [(DATA_WIDTH-1):0]      bwe,
        input   logic  [(NUM_INSTANCES-1):0]   dout_en,

        output  logic  [1:0]                   blk7_man_fcnt,
        inout   tri    [3:0]                   blk7_man_cnfg,
        output  logic  [3:0]                   blk7_man_ccnt,
        output  logic  [1:0]                   blk6_man_fcnt,
        inout   tri    [3:0]                   blk6_man_cnfg,
        output  logic  [3:0]                   blk6_man_ccnt,
        output  logic  [1:0]                   blk5_man_fcnt,
        inout   tri    [3:0]                   blk5_man_cnfg,
        output  logic  [3:0]                   blk5_man_ccnt,
        output  logic  [1:0]                   blk4_man_fcnt,
        inout   tri    [3:0]                   blk4_man_cnfg,
        output  logic  [3:0]                   blk4_man_ccnt,
        output  logic  [1:0]                   blk3_man_fcnt,
        inout   tri    [3:0]                   blk3_man_cnfg,
        output  logic  [3:0]                   blk3_man_ccnt,
        output  logic  [1:0]                   blk2_man_fcnt,
        inout   tri    [3:0]                   blk2_man_cnfg,
        output  logic  [3:0]                   blk2_man_ccnt,
        output  logic  [1:0]                   blk1_man_fcnt,
        inout   tri    [3:0]                   blk1_man_cnfg,
        output  logic  [3:0]                   blk1_man_ccnt,
        output  logic  [1:0]                   blk0_man_fcnt,
        inout   tri    [3:0]                   blk0_man_cnfg,
        output  logic  [3:0]                   blk0_man_ccnt,

        output  logic  [((2*DATA_WIDTH)-1):0]  dout,
        output  logic  [(NUM_INSTANCES-1):0]   busy,

        // Bank-level signals (match netlisted bank_et ports)
        inout                                  ANATEST0,
        inout                                  ANATEST1,
        input   logic  [2:0]                   anatest0_sel,
        input   logic  [2:0]                   anatest1_sel,
        input   logic                          dma_en,
        input   logic                          dsleep,
        input   logic  [3:0]                   even_man_stripe_sel,
        input   logic  [3:0]                   even_man_wr,
        inout          [42:0]                  gbl_cfg,
        input   logic                          gbl_cfg_ovr_en,
        input   logic  [3:0]                   odd_man_stripe_sel,
        input   logic  [3:0]                   odd_man_wr,
        input   logic                          otp_wr_en,
        input   logic                          prg_rd1_byp,
        output  logic                          pwr_ok,
        input   logic  [6:0]                   rca_ovr,
        input   logic                          rca_ovr_en,
        input   logic                          rd_en_ovr,
        input   logic                          rd_pulse_meas_en,
        input   logic                          ref_prg_en,
        input   logic                          reg_logic_sup_sleep,
        input   logic                          sah_en,
        input   logic                          scc_otp_en,
        output  logic  [1:0]                   temp,
        input   logic                          vblslx_gain_mode_ovr,
        input   logic                          test_cal_en,
        input   logic                          pwr_up_sel,
        input   logic  [3:0]                   powerup_trim_load_ovr,
        input   logic                          wr_en_ovr,
        inout   vdd,
        inout   vdd18,
        inout   vss
    );

    logic  [(DATA_WIDTH-1):0]        dout_upper_q;
    logic  [(DATA_WIDTH-1):0]        dout_lower_q;
    logic  [(DATA_WIDTH-1):0]        instance_dout    [(NUM_INSTANCES-1):0];
    logic  [(DATA_WIDTH-1):0]        dout_accumulate  [(NUM_INSTANCES+1):0];
    logic                            clr_b;
    logic  [7:0]                     inst_clk;
    logic  [(NUM_INSTANCES-1):0]     inst_busy;
    logic                            config_continue = 0;
    logic  [42:0]                    gbl_cfg_model_regs;

    assign inst_clk = {
        clk[3], clk[1],
        clk[3], clk[1],
        clk[2], clk[0],
        clk[2], clk[0]
    };
    // Bank-model ownership of gbl_cfg:
    // - gbl_cfg_ovr_en == 0: bank drives its internal register image
    // - gbl_cfg_ovr_en == 1: bank releases bus so controller side can drive
    assign gbl_cfg = (gbl_cfg_ovr_en === 1'b0) ? gbl_cfg_model_regs : {43{1'bz}};

    initial begin : init_gbl_cfg_model_regs
        // Randomize the modeled bank-owned gbl_cfg register values so tests can
        // observe and verify non-constant readback behavior.
        gbl_cfg_model_regs = {$urandom, $urandom};
    end

    assign temp = 2'b01;
    assign busy = {
        inst_busy[7] | config_continue,
        inst_busy[6] | config_continue,
        inst_busy[5] | config_continue,
        inst_busy[4] | config_continue,
        inst_busy[3] | config_continue,
        inst_busy[2] | config_continue,
        inst_busy[1] | config_continue,
        inst_busy[0] | config_continue
    };
    genvar inst_number;

    assign dout_accumulate[(NUM_INSTANCES+1)]  =  {DATA_WIDTH{1'b0}};
    assign dout_accumulate[(NUM_INSTANCES)]    =  dout_upper_q;

    generate
        for (inst_number = 0; inst_number < NUM_INSTANCES; inst_number = inst_number + 1) begin : mram_inst

            erbium_et_instance #(
                    .ADDR_WIDTH(ADDR_WIDTH),
                    .DATA_WIDTH(DATA_WIDTH)
            )  mram_inst (
                    .rst_b_i(rst_b),
                    .clk_i(inst_clk[inst_number]),
                    .ce_i(ce[inst_number]),
                    .we_i(we),
                    .addr_i(addr_in),
                    .din_i(din),
                    .bwe_i(bwe),
                    .dout_en_i(dout_en[inst_number]),
                    .ref_prg_en(ref_prg_en),
                    .dout_o(instance_dout[inst_number]),
                    .busy_o(inst_busy[inst_number])
            );

            assign dout_accumulate[inst_number]  =  instance_dout[inst_number] | dout_accumulate[(inst_number + 2)];

        end :mram_inst
    endgenerate

    // Power okay should be low until the MRAM bank switches fully power it on.
    always @(dsleep) begin
        if (dsleep === 1)
            pwr_ok <= 0;
        if (dsleep === 0) begin
            pwr_ok <= 0;
            #30ns;
            pwr_ok <= 1;
        end
    end

    always @(pwr_ok, posedge pwr_up_sel) begin
        if (pwr_ok == 1) begin
            config_continue <= 0;
            if (pwr_up_sel == 1) begin
                config_continue <= 1;
                #20ns;
                config_continue <= 0;
            end
        end
    end
    assign clr_b  =  rst_b & ~clk;

    always @(negedge clk or negedge clr_b) begin
        if(!clr_b) begin
            dout_upper_q  <=  0;
        end else begin
            dout_upper_q  <=  dout_accumulate[1];
        end
    end

    always @(negedge clk or negedge rst_b) begin
        if(!rst_b) begin
            dout_lower_q       <=  0;
        end else begin
            dout_lower_q       <=  dout_accumulate[0];
        end
    end

    always @(posedge clk or negedge rst_b) begin
        if (!rst_b) begin
            dout        <= 0;
        end else begin
            dout        <=  {dout_accumulate[0], dout_lower_q};
        end
    end

endmodule : bank_et


