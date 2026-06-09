// Created by: Charles Farmer
module test_reg #(
        parameter   [63:0]     BIT_MASK            = {64{1'b1}},
        parameter   [63:0]     READ_ONLY_MASK      = {64{1'b0}},
        parameter   [63:0]     RST_VALUE           = {64{1'b0}},
        parameter   [63:0]     TOGGLE_MASK         = {64{1'b0}},
        parameter   [63:0]     TOGGLE_VALUE        = {64{1'b0}}
    )
    (
        input                     clk,
        input                     rst_b,
        //
        //  APB port ...
        //
        input                     pread_sel,
        input                     pwrite_sel,
        input          [63:0]     pwrite_data,
        input          [63:0]     pbwe,
        input          [63:0]     ppass_thru,
        output  logic  [63:0]     pread_data,
        //
        //  Test port ...
        //
        input                     tread_sel,
        input                     twrite_sel,
        input          [63:0]     twrite_data,
        input          [63:0]     tbwe,
        input          [63:0]     tpass_thru,
        output  logic  [63:0]     tread_data,
        //
        //  Control/configuration output ...
        //
        output  logic  [63:0]     reg_out,
        //
        //  Read only data ...
        //
        input          [63:0]     read_only_in,
        //
        //  Status ...
        //
        input          [63:0]     toggle_ctrl,
        input                     stall_i,
        output                    stall_o
    );
    logic  [63:0]     int_value;
    logic  [63:0]     int_value_d;
    logic  [63:0]     read_value;
    logic  [63:0]     apb_bwe;
    logic             collision;
    //
    //  Deliver register values to associated control/configuration outputs ...
    //
    assign  reg_out     =  int_value & BIT_MASK;
    //
    //  Determine register read value ...
    //
    assign  read_value  =  (int_value & BIT_MASK & ~READ_ONLY_MASK) | (read_only_in & READ_ONLY_MASK);
    //
    //  Read from APB port ...
    //
    assign  pread_data  =  pread_sel  ?  read_value  :  ppass_thru;
    //
    //  Read from test port ...
    //
    assign  tread_data  =  tread_sel  ?  read_value  :  tpass_thru;
    //
    //  Cannot write from both ports simultaneously ...
    //
    assign  collision   =  pwrite_sel & twrite_sel;
    assign  stall_o     =  collision  |  stall_i;
    //
    //  Write logic ...
    //
    always_comb begin
        //int_value_d   =  {64{1'b0}};
        for (integer i = 0; i < 64; i++) begin
            if (twrite_sel) begin
                int_value_d[i]  =    tbwe[i]  ?  twrite_data[i] & BIT_MASK[i]  :  int_value[i] & BIT_MASK[i];
            end else if (pwrite_sel) begin
                int_value_d[i]  =    pbwe[i]  ?  pwrite_data[i] & BIT_MASK[i]  :  int_value[i] & BIT_MASK[i];
            end else begin
                int_value_d[i]  =    (TOGGLE_MASK[i] & toggle_ctrl[i]) ? TOGGLE_VALUE[i] & BIT_MASK[i] : int_value[i] & BIT_MASK[i];
            end
        end
    end

    always_ff @(posedge clk or negedge rst_b) begin
        if(~rst_b) begin
            //
            //  Set initial state of registers at reset ...
            //
            int_value <= RST_VALUE & BIT_MASK;
        end else begin
            int_value <= int_value_d;
        end
    end
endmodule

module  test_regs  (
        //
        // APB Port signals ...
        //
        input                           PCLK,
        input                           PRESETn,
        input                           PSEL,
        input                           PWRITE,
        input                           PENABLE,
        input               [4:0]       PADDR,
        input               [31:0]      PWDATA,
        input               [3:0]       PSTRB,
        output  logic       [31:0]      PRDATA,
        output  logic                   PREADY,
        //
        // Test Port Signals ...
        //
        input               [3:0]       tp_add,
        input                           tp_ce,
        input                           tp_we,
        input               [63:0]      tp_bwe,
        input               [63:0]      tp_din,
        output  logic                   tp_busy,
        output  logic                   tp_valid,
        output  logic       [63:0]      tp_reg_out,
        //
        //  Control, configuration and override signals ...
        //
        output  logic       [4:0]       treg_RH4margin,
        //output  logic       [2:0]       treg_RH_sigma,
        output  logic       [17:0]      treg_addr_in,
        output  logic       [2:0]       treg_anatest0_sel,
        output  logic       [2:0]       treg_anatest1_sel,
        output  logic                   treg_eccrom_deep_sleep,
        output  logic                   treg_ref_ecc_sel,
        input                           treg_bist_busy,
        input                           treg_bist_error,
        input               [19:0]      treg_bist_err_add,
        output  logic                   treg_bist_reset,
        output  logic                   treg_bist_rd_en,
        output  logic                   treg_bist_wr_en,
        input               [3:0]       treg_blk0_man_ccnt,
        inout               [3:0]       treg_blk0_man_cnfg,
        input               [1:0]       treg_blk0_man_fcnt,
        input               [3:0]       treg_blk1_man_ccnt,
        inout               [3:0]       treg_blk1_man_cnfg,
        input               [1:0]       treg_blk1_man_fcnt,
        input               [3:0]       treg_blk2_man_ccnt,
        inout               [3:0]       treg_blk2_man_cnfg,
        input               [1:0]       treg_blk2_man_fcnt,
        input               [3:0]       treg_blk3_man_ccnt,
        inout               [3:0]       treg_blk3_man_cnfg,
        input               [1:0]       treg_blk3_man_fcnt,
        input               [3:0]       treg_blk4_man_ccnt,
        inout               [3:0]       treg_blk4_man_cnfg,
        input               [1:0]       treg_blk4_man_fcnt,
        input               [3:0]       treg_blk5_man_ccnt,
        inout               [3:0]       treg_blk5_man_cnfg,
        input               [1:0]       treg_blk5_man_fcnt,
        input               [3:0]       treg_blk6_man_ccnt,
        inout               [3:0]       treg_blk6_man_cnfg,
        input               [1:0]       treg_blk6_man_fcnt,
        input               [3:0]       treg_blk7_man_ccnt,
        inout               [3:0]       treg_blk7_man_cnfg,
        input               [1:0]       treg_blk7_man_fcnt,
        input                           treg_busy,
        output  logic       [78:0]      treg_bwe,
        // Removed for Boron ...
        // output  logic       [1:0]       treg_cal_clk_speed,
        // Added for Boron ...
        output  logic                   treg_test_cal_en,
        output  logic                   treg_mram_clk_en,
        input                           treg_cpu_intr_flag,
        output  logic       [78:0]      treg_din,
        output  logic                   treg_bist_data_inv,
        output  logic                   treg_disable_cpu_intr,
        output  logic                   treg_disable_ted,
        output  logic                   treg_dma_en,
        input               [78:0]      treg_dout,
        output  logic                   treg_dsleep_mram_en,
        input                           treg_ecc_1bit,
        input                           treg_ecc_2bit,
        input                           treg_ecc_3bit,
        output  logic                   treg_ecc_bypass_en,
        output  logic       [2:0]       treg_ecc_en,
        output  logic       [3:0]       treg_even_man_stripe_sel,
        output  logic       [3:0]       treg_even_man_wr,
        input               [42:0]      treg_gbl_cfg,
        output  logic       [42:0]      treg_gbl_cfg_ovr,
        output  logic                   treg_gbl_cfg_ovr_en,
        output  logic       [2:0]       treg_bist_add_inc,
        input               [19:0]      treg_intr_error_add,
        // Removed for Boron ...
        // input               [3:0]       treg_nvsram_boot_err,
        // Renamed for Boron ...
        // output  logic       [3:0]       treg_nvsram_en_ovr,
        output  logic       [3:0]       treg_powerup_trim_load_ovr,
        output  logic       [3:0]       treg_odd_man_stripe_sel,
        output  logic       [3:0]       treg_odd_man_wr,
        output  logic                   treg_otp_wr_en,
        output  logic                   treg_prg_rd1_byp,
        input                           treg_pwr_ok,
        input   logic                   treg_eccrom_pwr_ok,
        output  logic       [6:0]       treg_rca_ovr,
        output  logic                   treg_rca_ovr_en,
        output  logic                   treg_rd_en_ovr,
        output  logic                   treg_rd_pulse_meas_en,
        output  logic                   treg_ref_prg_en,
        output  logic                   treg_bist_rte_en,
        output  logic                   treg_reg_logic_sup_sleep_ovr,
        //input               [4:0]       treg_rep_add_cnt_o,
        //input               [20*24-1:0] treg_replacement_add,
        output  logic                   treg_rst_cpu_intr,
        // Removed for Boron ...
        // output  logic       [3:0]       treg_sa_cal_clk_ovr,
        // output  logic       [3:0]       treg_sa_cal_en_ovr,
        output  logic                   treg_sah_en,
        output  logic                   treg_scc_otp_en,
        output  logic       [19:0]      treg_bist_start_add,
        output  logic                   treg_bist_start,
        output  logic       [15:0]      treg_bist_loop_count,
        output  logic                   treg_bist_trim_mode,
        output  logic                   treg_bist_stop_on_repl_of,
        // Removed for Boron
        // output  logic       [3:0]       treg_ste_ovr_sel,
        output  logic       [19:0]      treg_bist_stop_add,
        output  logic                   treg_bist_stop_on_error,
        output  logic       [3:0]       treg_stripe_sel,
        input               [1:0]       treg_temp,
        input               [15:0]      treg_bist_error_loop,
        input               [6:0]       treg_bist_rh0,
        input               [6:0]       treg_bist_rh1,
        input               [6:0]       treg_bist_rh2,
        input               [16:0]      treg_bist_error_count,
        input               [78:0]      treg_bist_error_value,
        output  logic                   treg_test_reg_ovr_en,
        output  logic                   treg_vblslx_gain_mode_ovr,
        output  logic                   treg_we,
        output  logic                   treg_wr_en_ovr
    );
    //
    //  Updated for Boron ...
    //
    parameter [(13*64-1):0]    RST_VALUE      =  {
                                                      64'h0000000000000000,  // 12
                                                      64'h0000000000000000,  // 11
                                                      64'h0000000000000000,  // 10
                                                      64'h0000000000000000,  //  9
                                                      64'h0000000000000000,  //  8
                                                      64'h0000000000000000,  //  7
                                                      64'h0000000000000000,  //  6
                                                      64'h000001CE6876CD31,  //  5
                                                      64'h0000000004000000,  //  4
                                                      64'h0000000000000000,  //  3
                                                      64'h0000028000008000,  //  2
                                                      64'h0000000000000000,  //  1
                                                      64'h4000201000000000   //  0
    };
    parameter [(13*64-1):0]    READ_ONLY_MASK =  {
                                                      64'h0000000000007FFF,  // 12
                                                      64'hFFFFFFFFFFFFFFFF,  // 11
                                                      64'hFFFFFF83FFFFF7FF,  // 10
                                                      64'h1FFFFFFFFFFFFFFF,  //  9
                                                      64'hFFFFFFFFFFFFFFFF,  //  8
                                                      64'h03FF03FF03FF03FF,  //  7
                                                      64'h03FF03FF03FF03FF,  //  6
                                                      64'h000007FFFFFFFFFF,  //  5
                                                      64'h0000000000000000,  //  4
                                                      64'h0000000000000000,  //  3
                                                      64'h0000000000000000,  //  2
                                                      64'h0000000000000000,  //  1
                                                      64'h0000000000000000   //  0
    };
    parameter [(13*64-1):0]    BIT_MASK       =  {
                                                      64'h00000003FFFF8000,  // 12
                                                      64'h0000000000000000,  // 11
                                                      64'h0000000000000000,  // 10
                                                      64'h0000000000000000,  //  9
                                                      64'h0000000000000000,  //  8
                                                      64'h00F000F000F000F0,  //  7
                                                      64'h00F000F000F000F0,  //  6
                                                      64'h000007FFFFFFFFFF,  //  5
                                                      64'h008FFFFF0FFFFFFF,  //  4
                                                      64'hFFFFFFFFFFFFFFFF,  //  3
                                                      64'hFFFFFFC7FFFFFFFF,  //  2
                                                      64'hFFFFFFFFFFFFFFFF,  //  1
                                                      64'hFFE23FFFFFFFFFFF   //  0
    };
    parameter [(13*64-1):0]    TOGGLE_MASK    =  {
                                                      64'h0000000000000000,  // 12
                                                      64'h0000000000000000,  // 11
                                                      64'h0000000000000000,  // 10
                                                      64'h0000000000000000,  // 9
                                                      64'h0000000000000000,  // 8
                                                      64'h0000000000000000,  // 7
                                                      64'h0000000000000000,  // 6
                                                      64'h0000000000000000,  // 5
                                                      64'h0000000000000000,  // 4
                                                      64'h0000000000000000,  // 3
                                                      64'h0000000000008000,  // 2
                                                      64'h0000000000000000,  // 1
                                                      64'h00001E0000000000   // 0
    };
    parameter [(13*64-1):0]    TOGGLE_VALUE    =  {
                                                      64'h0000000000000000,  // 12
                                                      64'h0000000000000000,  // 11
                                                      64'h0000000000000000,  // 10
                                                      64'h0000000000000000,  // 9
                                                      64'h0000000000000000,  // 8
                                                      64'h0000000000000000,  // 7
                                                      64'h0000000000000000,  // 6
                                                      64'h0000000000000000,  // 5
                                                      64'h0000000000000000,  // 4
                                                      64'h0000000000000000,  // 3
                                                      64'h0000000000000000,  // 2
                                                      64'h0000000000000000,  // 1
                                                      64'h0000000000000000   // 0
    };

    //
    // Define
    //
    logic        [3:0]     reg_blk0_man_ccnt;
    logic        [3:0]     reg_blk0_man_cnfg;
    logic        [1:0]     reg_blk0_man_fcnt;
    logic        [3:0]     reg_blk1_man_ccnt;
    logic        [3:0]     reg_blk1_man_cnfg;
    logic        [1:0]     reg_blk1_man_fcnt;
    logic        [3:0]     reg_blk2_man_ccnt;
    logic        [3:0]     reg_blk2_man_cnfg;
    logic        [1:0]     reg_blk2_man_fcnt;
    logic        [3:0]     reg_blk3_man_ccnt;
    logic        [3:0]     reg_blk3_man_cnfg;
    logic        [1:0]     reg_blk3_man_fcnt;
    logic        [3:0]     reg_blk4_man_ccnt;
    logic        [3:0]     reg_blk4_man_cnfg;
    logic        [1:0]     reg_blk4_man_fcnt;
    logic        [3:0]     reg_blk5_man_ccnt;
    logic        [3:0]     reg_blk5_man_cnfg;
    logic        [1:0]     reg_blk5_man_fcnt;
    logic        [3:0]     reg_blk6_man_ccnt;
    logic        [3:0]     reg_blk6_man_cnfg;
    logic        [1:0]     reg_blk6_man_fcnt;
    logic        [3:0]     reg_blk7_man_ccnt;
    logic        [3:0]     reg_blk7_man_cnfg;
    logic        [1:0]     reg_blk7_man_fcnt;
    //
    logic        [63:0]    reg_out       [12:0];
    //
    //
    //
    logic        [12:0]    pread_sel     ;
    logic        [12:0]    pwrite_sel    ;
    logic        [63:0]    ppass_thru    [12:0];
    logic        [63:0]    pread_data    [12:0];
    logic        [63:0]    pread_data_o;
    logic        [63:0]    pbwe;
    logic                  tread_sel     [12:0];
    logic                  twrite_sel    [12:0];
    logic        [63:0]    tpass_thru    [12:0];
    logic        [63:0]    tread_data    [12:0];
    logic        [63:0]    read_only_in  [12:0];
    logic        [63:0]    toggle_ctrl   [12:0];
    logic        [63:0]    treg_out_d;
    logic                  tvalid_d;
    //
    //  Replacement address selection ...
    //
    //logic        [3:0]     treg_replacement_add_sel;
    //logic        [63:0]    reg_replacement_add;
    logic                  treg_mram_clk_single_pulse;
    logic                  mram_clk_en_d;
    //logic                  mram_clk_en_q;
    logic                  treg_trim_load_ovr_single_pulse;
    //
    //  APB State Logic ...
    //
    logic        [1:0]     apb_state;
    logic        [1:0]     apb_next;
    logic                  pwrite_lcl;
    logic                  pread_lcl;
    logic                  psetup_lcl;
    logic                  stall_i       [12:0];
    logic                  stall_o       [12:0];
    logic                  stall;
    logic        [1:0]     test_next;
    logic                  twrite_lcl;
    logic                  tread_lcl;
    logic                  tsetup_lcl;
    logic        [1:0]     test_state;
    logic        [63:0]    tread_data_o;
    const logic  [1:0]     BUS_ST_SETUP   =   2'b00;
    const logic  [1:0]     BUS_ST_WRITE   =   2'b01;
    const logic  [1:0]     BUS_ST_READ    =   2'b10;


    always_comb begin
        apb_next     =   BUS_ST_SETUP;
        PRDATA       =   32'h00000000;
        pwrite_lcl   =   1'b0;
        pread_lcl    =   1'b0;
        psetup_lcl   =   1'b0;
        PREADY       =   1'b0;
        case (apb_state)
            BUS_ST_SETUP   :   begin
                                   psetup_lcl         =   1'b1;
                                   if (PSEL && !PENABLE) begin
                                       if (PWRITE) begin
                                           apb_next   =   BUS_ST_WRITE;
                                       end else begin
                                           apb_next   =   BUS_ST_READ;
                                       end
                                   end
                               end
            BUS_ST_WRITE   :   if (PSEL & PENABLE & PWRITE) begin
                                   pwrite_lcl         =   1'b1;
                                   if (stall) begin
                                       PREADY         =   1'b0;
                                       apb_next       =   BUS_ST_WRITE;
                                   end else begin
                                       PREADY         =   1'b1;
                                       apb_next       =   BUS_ST_SETUP;
                                   end
                               end
            BUS_ST_READ    :   if (PSEL & PENABLE & ~PWRITE) begin
                                   pread_lcl          =   1'b1;
                                   PRDATA             =   PADDR[0] ? pread_data_o[63:32] : pread_data_o[31:0];
                                   if (stall) begin
                                       PREADY         =   1'b0;
                                       apb_next       =   BUS_ST_READ;
                                   end else begin
                                       PREADY         =   1'b1;
                                       apb_next       =   BUS_ST_SETUP;
                                   end
                               end else begin
                                   PREADY             =   1'b0;
                                   apb_next           =   BUS_ST_SETUP;
                               end
            default        :   apb_next               =   BUS_ST_SETUP;
        endcase
    end

    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (~PRESETn)  begin
            apb_state    <=  BUS_ST_SETUP;
        end else begin
            apb_state    <=  apb_next;
        end
    end

    assign pbwe             =   {
                                   {8{ pwrite_lcl & PADDR[0]  & PSTRB[3]}},
                                   {8{ pwrite_lcl & PADDR[0]  & PSTRB[2]}},
                                   {8{ pwrite_lcl & PADDR[0]  & PSTRB[1]}},
                                   {8{ pwrite_lcl & PADDR[0]  & PSTRB[0]}},
                                   {8{ pwrite_lcl & ~PADDR[0] & PSTRB[3]}},
                                   {8{ pwrite_lcl & ~PADDR[0] & PSTRB[2]}},
                                   {8{ pwrite_lcl & ~PADDR[0] & PSTRB[1]}},
                                   {8{ pwrite_lcl & ~PADDR[0] & PSTRB[0]}}
                                };

    assign stall_i[0]       =   1'b0;
    assign stall_i[1]       =   stall_o[0];
    assign stall_i[2]       =   stall_o[1];
    assign stall_i[3]       =   stall_o[2];
    assign stall_i[4]       =   stall_o[3];
    assign stall_i[5]       =   stall_o[4];
    assign stall_i[6]       =   stall_o[5];
    assign stall_i[7]       =   stall_o[6];
    assign stall_i[8]       =   stall_o[7];
    assign stall_i[9]       =   stall_o[8];
    assign stall_i[10]      =   stall_o[9];
    assign stall_i[11]      =   stall_o[10];
    assign stall_i[12]      =   stall_o[11];
    assign stall            =   stall_o[12];

    assign ppass_thru[0]    =   64'h0000000000000000;
    assign ppass_thru[1]    =   pread_data[0];
    assign ppass_thru[2]    =   pread_data[1];
    assign ppass_thru[3]    =   pread_data[2];
    assign ppass_thru[4]    =   pread_data[3];
    assign ppass_thru[5]    =   pread_data[4];
    assign ppass_thru[6]    =   pread_data[5];
    assign ppass_thru[7]    =   pread_data[6];
    assign ppass_thru[8]    =   pread_data[7];
    assign ppass_thru[9]    =   pread_data[8];
    assign ppass_thru[10]   =   pread_data[9];
    assign ppass_thru[11]   =   pread_data[10];
    assign ppass_thru[12]   =   pread_data[11];
    assign pread_data_o     =   pread_data[12];

    assign pread_sel[0]      =   pread_lcl & (PADDR[4:1] == 4'h0);
    assign pread_sel[1]      =   pread_lcl & (PADDR[4:1] == 4'h1);
    assign pread_sel[2]      =   pread_lcl & (PADDR[4:1] == 4'h2);
    assign pread_sel[3]      =   pread_lcl & (PADDR[4:1] == 4'h3);
    assign pread_sel[4]      =   pread_lcl & (PADDR[4:1] == 4'h4);
    assign pread_sel[5]      =   pread_lcl & (PADDR[4:1] == 4'h5);
    assign pread_sel[6]      =   pread_lcl & (PADDR[4:1] == 4'h6);
    assign pread_sel[7]      =   pread_lcl & (PADDR[4:1] == 4'h7);
    assign pread_sel[8]      =   pread_lcl & (PADDR[4:1] == 4'h8);
    assign pread_sel[9]      =   pread_lcl & (PADDR[4:1] == 4'h9);
    assign pread_sel[10]     =   pread_lcl & (PADDR[4:1] == 4'ha);
    assign pread_sel[11]     =   pread_lcl & (PADDR[4:1] == 4'hb);
    assign pread_sel[12]     =   pread_lcl & (PADDR[4:1] == 4'hc);

    assign pwrite_sel[0]      =   pwrite_lcl & (PADDR[4:1] == 4'h0);
    assign pwrite_sel[1]      =   pwrite_lcl & (PADDR[4:1] == 4'h1);
    assign pwrite_sel[2]      =   pwrite_lcl & (PADDR[4:1] == 4'h2);
    assign pwrite_sel[3]      =   pwrite_lcl & (PADDR[4:1] == 4'h3);
    assign pwrite_sel[4]      =   pwrite_lcl & (PADDR[4:1] == 4'h4);
    assign pwrite_sel[5]      =   pwrite_lcl & (PADDR[4:1] == 4'h5);
    assign pwrite_sel[6]      =   pwrite_lcl & (PADDR[4:1] == 4'h6);
    assign pwrite_sel[7]      =   pwrite_lcl & (PADDR[4:1] == 4'h7);
    assign pwrite_sel[8]      =   pwrite_lcl & (PADDR[4:1] == 4'h8);
    assign pwrite_sel[9]      =   pwrite_lcl & (PADDR[4:1] == 4'h9);
    assign pwrite_sel[10]     =   pwrite_lcl & (PADDR[4:1] == 4'ha);
    assign pwrite_sel[11]     =   pwrite_lcl & (PADDR[4:1] == 4'hb);
    assign pwrite_sel[12]     =   pwrite_lcl & (PADDR[4:1] == 4'hc);

    //
    // Test port state logic ...
    //
    always_comb  begin
        //test_next     =   BUS_ST_SETUP;
        twrite_lcl    =   1'b0;
        tread_lcl     =   1'b0;
        //tsetup_lcl    =   1'b0;
        tp_busy       =   1'b0;
        tvalid_d      =   1'b0;
        treg_out_d    =   tp_reg_out;

        if (tp_ce)  begin
            if (tp_we)  begin
                twrite_lcl      =    1'b1;
                tp_busy         =    1'b1;
                tvalid_d        =    1'b1;
            end else begin
                tread_lcl       =    1'b1;
                tp_busy         =    1'b1;
                tvalid_d        =    1'b1;
                treg_out_d    =    tread_data_o;
            end
        end
    end

    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (~PRESETn) begin
            tp_valid     <=   1'b0;
            tp_reg_out   <=   64'h0000000000000000;
        end else begin
            tp_valid     <=   tvalid_d;
            tp_reg_out   <=   treg_out_d;
        end
    end


    assign tpass_thru[0]         =   64'h0000000000000000;
    assign tpass_thru[1]         =   tread_data[0];
    assign tpass_thru[2]         =   tread_data[1];
    assign tpass_thru[3]         =   tread_data[2];
    assign tpass_thru[4]         =   tread_data[3];
    assign tpass_thru[5]         =   tread_data[4];
    assign tpass_thru[6]         =   tread_data[5];
    assign tpass_thru[7]         =   tread_data[6];
    assign tpass_thru[8]         =   tread_data[7];
    assign tpass_thru[9]         =   tread_data[8];
    assign tpass_thru[10]        =   tread_data[9];
    assign tpass_thru[11]        =   tread_data[10];
    assign tpass_thru[12]        =   tread_data[11];

    assign tread_data_o          =   tread_data[12];

    assign tread_sel[0]          =   tread_lcl & (tp_add == 4'h0);
    assign tread_sel[1]          =   tread_lcl & (tp_add == 4'h1);
    assign tread_sel[2]          =   tread_lcl & (tp_add == 4'h2);
    assign tread_sel[3]          =   tread_lcl & (tp_add == 4'h3);
    assign tread_sel[4]          =   tread_lcl & (tp_add == 4'h4);
    assign tread_sel[5]          =   tread_lcl & (tp_add == 4'h5);
    assign tread_sel[6]          =   tread_lcl & (tp_add == 4'h6);
    assign tread_sel[7]          =   tread_lcl & (tp_add == 4'h7);
    assign tread_sel[8]          =   tread_lcl & (tp_add == 4'h8);
    assign tread_sel[9]          =   tread_lcl & (tp_add == 4'h9);
    assign tread_sel[10]         =   tread_lcl & (tp_add == 4'ha);
    assign tread_sel[11]         =   tread_lcl & (tp_add == 4'hb);
    assign tread_sel[12]         =   tread_lcl & (tp_add == 4'hc);

    assign twrite_sel[0]         =   twrite_lcl & (tp_add == 4'h0);
    assign twrite_sel[1]         =   twrite_lcl & (tp_add == 4'h1);
    assign twrite_sel[2]         =   twrite_lcl & (tp_add == 4'h2);
    assign twrite_sel[3]         =   twrite_lcl & (tp_add == 4'h3);
    assign twrite_sel[4]         =   twrite_lcl & (tp_add == 4'h4);
    assign twrite_sel[5]         =   twrite_lcl & (tp_add == 4'h5);
    assign twrite_sel[6]         =   twrite_lcl & (tp_add == 4'h6);
    assign twrite_sel[7]         =   twrite_lcl & (tp_add == 4'h7);
    assign twrite_sel[8]         =   twrite_lcl & (tp_add == 4'h8);
    assign twrite_sel[9]         =   twrite_lcl & (tp_add == 4'h9);
    assign twrite_sel[10]        =   twrite_lcl & (tp_add == 4'ha);
    assign twrite_sel[11]        =   twrite_lcl & (tp_add == 4'hb);
    assign twrite_sel[12]        =   twrite_lcl & (tp_add == 4'hc);

    assign toggle_ctrl[0]        =   {
                                         {19{1'b0}},
                                         {4{treg_trim_load_ovr_single_pulse}},
                                         {41{1'b0}} 
                                     };
    assign toggle_ctrl[1]        =   {64{1'b0}};
    assign toggle_ctrl[2]        =   {
                                         {48{1'b0}},
                                         treg_mram_clk_single_pulse,
                                         {15{1'b0}}
                                     };
    assign toggle_ctrl[3]        =   {64{1'b0}};
    assign toggle_ctrl[4]        =   {64{1'b0}};
    assign toggle_ctrl[5]        =   {64{1'b0}};
    assign toggle_ctrl[6]        =   {64{1'b0}};
    assign toggle_ctrl[7]        =   {64{1'b0}};
    assign toggle_ctrl[8]        =   {64{1'b0}};
    assign toggle_ctrl[9]        =   {64{1'b0}};
    assign toggle_ctrl[10]       =   {64{1'b0}};
    assign toggle_ctrl[11]       =   {64{1'b0}};
    assign toggle_ctrl[12]       =   {64{1'b0}};

    //
    //  Instantiate the registers ...
    //
    genvar i;
    generate
        for (i = 0; i < 13; i++) begin
            test_reg #(
                .BIT_MASK(BIT_MASK[64 * i +: 64]),
                .READ_ONLY_MASK(READ_ONLY_MASK[64 * i +: 64]),
                .RST_VALUE(RST_VALUE[64 * i +: 64]),
                .TOGGLE_MASK(TOGGLE_MASK[64 * i +: 64]),
                .TOGGLE_VALUE(TOGGLE_VALUE[64 * i +: 64])
            ) treg (
                .clk(PCLK),
                .rst_b(PRESETn),
                //
                //  APB port ...
                //
                .pread_sel(pread_sel[i]),
                .pwrite_sel(pwrite_sel[i]),
                .pwrite_data({PWDATA, PWDATA}),
                .pbwe(pbwe),
                .ppass_thru(ppass_thru[i]),
                .pread_data(pread_data[i]),
                //
                //  Test port ...
                //
                .tread_sel(tread_sel[i]),
                .twrite_sel(twrite_sel[i]),
                .twrite_data(tp_din),
                .tbwe(tp_bwe),
                .tpass_thru(tpass_thru[i]),
                .tread_data(tread_data[i]),
                //
                //  Control/configuration output ...
                //
                .reg_out(reg_out[i]),
                //
                //  Read only data ...
                //
                .read_only_in(read_only_in[i]),
                //
                //  Status ...
                //
                .toggle_ctrl(toggle_ctrl[i]),
                .stall_i(stall_i[i]),
                .stall_o(stall_o[i])
            );
        end
    endgenerate
    //
    // Map outputs from MRAM to the read-only register addresses ...
    //
    // Register 0
    assign  treg_addr_in                    =    reg_out[0][17:0];   //  [17:0]
    assign  treg_stripe_sel                 =    reg_out[0][21:18];  //  [3:0]
    assign  treg_we                         =    reg_out[0][22];
    assign  treg_rd_pulse_meas_en           =    reg_out[0][23];
    assign  treg_rca_ovr                    =    reg_out[0][30:24];  //  [6:0]
    assign  treg_rca_ovr_en                 =    reg_out[0][31];
    assign  treg_gbl_cfg_ovr_en             =    reg_out[0][32];
    assign  treg_rd_en_ovr                  =    reg_out[0][33];
    assign  treg_ref_prg_en                 =    reg_out[0][34];
    assign  treg_dsleep_mram_en             =    reg_out[0][35];
    assign  treg_reg_logic_sup_sleep_ovr    =    reg_out[0][36];
    assign  treg_prg_rd1_byp                =    reg_out[0][37];
    assign  treg_wr_en_ovr                  =    reg_out[0][38];
    assign  treg_dma_en                     =    reg_out[0][39];
    assign  treg_vblslx_gain_mode_ovr       =    reg_out[0][40];
    // Renamed for Boron ...
    // assign  treg_nvsram_en_ovr              =    reg_out[0][44:41];  //  [3:0]
    assign  treg_powerup_trim_load_ovr      =    reg_out[0][44:41];  //  [3:0]
    // Removed for Boron ...
    // assign  treg_sa_cal_clk_ovr             =    reg_out[0][48:45];  //  [3:0]
    // assign  treg_sa_cal_en_ovr              =    reg_out[0][52:49];  //  [3:0]
    // Added for Boron ...
    assign  treg_trim_load_ovr_single_pulse =    reg_out[0][45];
    assign  treg_test_cal_en                =    reg_out[0][49];  //  [3:0]
    assign  treg_bist_reset                 =    reg_out[0][53];
    assign  treg_bist_rd_en                 =    reg_out[0][54];
    assign  treg_bist_wr_en                 =    reg_out[0][55];
    assign  treg_anatest0_sel               =    reg_out[0][58:56];  //  [2:0]
    assign  treg_anatest1_sel               =    reg_out[0][61:59];  //  [2:0]
    assign  treg_eccrom_deep_sleep          =    reg_out[0][62];
    assign  treg_ref_ecc_sel                =    reg_out[0][63];
    // Removed for Boron ...
    // assign  treg_cal_clk_speed              =    reg_out[0][63:62];  //  [1:0]
    // Register 1/2
    assign  treg_bwe                        =    {reg_out[2][14:0], reg_out[1]};  //  [78:0]
    // Register 2/3
    assign  mram_clk_en_d                   =    reg_out[2][15];
    //assign  treg_mram_clk_en                =    reg_out[2][15];
    assign  treg_din                        =    {reg_out[2][30:16], reg_out[3]}; //  [78:0]
    assign  treg_test_reg_ovr_en            =    reg_out[2][31];
    assign  treg_bist_rte_en                =    reg_out[2][32];
    assign  treg_otp_wr_en                  =    reg_out[2][33];
    assign  treg_rst_cpu_intr               =    reg_out[2][34];
    //assign  treg_RH_sigma                   =    reg_out[2][37:35];  //  [2:0]
    assign  treg_RH4margin                  =    reg_out[2][42:38];  //  [4:0]
    assign  treg_bist_stop_on_error         =    reg_out[2][43];
    assign  treg_bist_start_add             =    reg_out[2][63:44];  //  [19:0]
    // Register 4
    assign  treg_bist_data_inv              =    reg_out[4][0];
    assign  treg_disable_cpu_intr           =    reg_out[4][1];
    assign  treg_disable_ted                =    reg_out[4][2];
    assign  treg_ecc_bypass_en              =    reg_out[4][3];
    assign  treg_ecc_en                     =    reg_out[4][6:4];    //  [2:0]
    assign  treg_even_man_stripe_sel        =    reg_out[4][10:7];   //  [3:0]
    assign  treg_even_man_wr                =    reg_out[4][14:11];  //  [3:0]
    assign  treg_bist_add_inc               =    reg_out[4][17:15];  //  [2:0]
    assign  treg_odd_man_stripe_sel         =    reg_out[4][21:18];  //  [3:0]
    assign  treg_odd_man_wr                 =    reg_out[4][25:22];  //  [3:0]
    assign  treg_sah_en                     =    reg_out[4][26];
    assign  treg_scc_otp_en                 =    reg_out[4][27];
    // Removed for Boron ...
    // assign  treg_ste_ovr_sel                =    reg_out[4][31:28];  //  [3:0]
    assign  treg_bist_stop_add              =    reg_out[4][51:32];  //  [19:0]
    //assign  treg_replacement_add_sel        =    reg_out[4][54:52];  //  [2:0]
    assign  treg_mram_clk_single_pulse      =    reg_out[4][55];
    // Register 5
    assign  treg_gbl_cfg_ovr                =    reg_out[5][42:0];         //  [63:0]
    // Register 6
    //
    // [fc]cnt are read-only in Boron ...
    //
    //assign  reg_blk0_man_ccnt               =    reg_out[6][3:0];    //  [3:0]
    assign  reg_blk0_man_cnfg               =    reg_out[6][7:4];    //  [3:0]
    //assign  reg_blk0_man_fcnt               =    reg_out[6][9:8];    //  [1:0]
    //assign  reg_blk1_man_ccnt               =    reg_out[6][19:16];  //  [3:0]
    assign  reg_blk1_man_cnfg               =    reg_out[6][23:20];  //  [3:0]
    //assign  reg_blk1_man_fcnt               =    reg_out[6][25:24];  //  [1:0]
    //assign  reg_blk2_man_ccnt               =    reg_out[6][35:32];  //  [3:0]
    assign  reg_blk2_man_cnfg               =    reg_out[6][39:36];  //  [3:0]
    //assign  reg_blk2_man_fcnt               =    reg_out[6][41:40];  //  [1:0]
    //assign  reg_blk3_man_ccnt               =    reg_out[6][51:48];  //  [3:0]
    assign  reg_blk3_man_cnfg               =    reg_out[6][55:52];  //  [3:0]
    //assign  reg_blk3_man_fcnt               =    reg_out[6][57:56];  //  [1:0]
    // Register 7
    //assign  reg_blk4_man_ccnt               =    reg_out[7][3:0];    //  [3:0]
    assign  reg_blk4_man_cnfg               =    reg_out[7][7:4];    //  [3:0]
    //assign  reg_blk4_man_fcnt               =    reg_out[7][9:8];    //  [1:0]
    //assign  reg_blk5_man_ccnt               =    reg_out[7][19:16];  //  [3:0]
    assign  reg_blk5_man_cnfg               =    reg_out[7][23:20];  //  [3:0]
    //assign  reg_blk5_man_fcnt               =    reg_out[7][25:24];  //  [1:0]
    //assign  reg_blk6_man_ccnt               =    reg_out[7][35:32];  //  [3:0]
    assign  reg_blk6_man_cnfg               =    reg_out[7][39:36];  //  [3:0]
    //assign  reg_blk6_man_fcnt               =    reg_out[7][41:40];  //  [1:0]
    //assign  reg_blk7_man_ccnt               =    reg_out[7][51:48];  //  [3:0]
    assign  reg_blk7_man_cnfg               =    reg_out[7][55:52];  //  [3:0]
    //assign  reg_blk7_man_fcnt               =    reg_out[7][57:56];  //  [1:0]
    //
    assign  treg_bist_loop_count            =    reg_out[12][30:15];
    assign  treg_bist_start                 =    reg_out[12][31];
    assign  treg_bist_trim_mode             =    reg_out[12][32];
    assign  treg_bist_stop_on_repl_of       =    reg_out[12][33];
    always_ff @(negedge PCLK or negedge PRESETn) begin
        if (~PRESETn)  begin
            treg_mram_clk_en  <=  1'b0;
    //        mram_clk_en_q  <=  1'b0;
        end else
            treg_mram_clk_en  <=  mram_clk_en_d;
    //        mram_clk_en_q  <=  mram_clk_en_d;
        end
    //    assign treg_mram_clk_en  =  mram_clk_en_q;
    //
    // Route selected treg_replacement_add to output register ...
    //
    //always_comb begin
    //    case (treg_replacement_add_sel)
    //        3'b000  :  reg_replacement_add   =  {
    //                                              treg_replacement_add[2*20+:20],
    //                                              treg_replacement_add[1*20+:20],
    //                                              treg_replacement_add[0*20+:20]
    //                   };
    //        3'b001  :  reg_replacement_add   =  {
    //                                              treg_replacement_add[5*20+:20],
    //                                              treg_replacement_add[4*20+:20],
    //                                              treg_replacement_add[3*20+:20]
    //                   };
    //        3'b010  :  reg_replacement_add   =  {
    //                                              treg_replacement_add[8*20+:20],
    //                                              treg_replacement_add[7*20+:20],
    //                                              treg_replacement_add[6*20+:20]
    //                   };
    //        3'b011  :  reg_replacement_add   =  {
    //                                              treg_replacement_add[11*20+:20],
    //                                              treg_replacement_add[10*20+:20],
    //                                              treg_replacement_add[9*20+:20]
    //                   };
    //        3'b100  :  reg_replacement_add   =  {
    //                                              treg_replacement_add[14*20+:20],
    //                                              treg_replacement_add[13*20+:20],
    //                                              treg_replacement_add[12*20+:20]
    //                   };
    //        3'b101  :  reg_replacement_add   =  {
    //                                              treg_replacement_add[17*20+:20],
    //                                              treg_replacement_add[16*20+:20],
    //                                              treg_replacement_add[15*20+:20]
    //                   };
    //        3'b110  :  reg_replacement_add   =  {
    //                                              treg_replacement_add[20*20+:20],
    //                                              treg_replacement_add[19*20+:20],
    //                                              treg_replacement_add[18*20+:20]
    //                   };
    //        3'b111  :  reg_replacement_add   =  {
    //                                              treg_replacement_add[23*20+:20],
    //                                              treg_replacement_add[22*20+:20],
    //                                              treg_replacement_add[21*20+:20]
    //                   };
    //        default :  reg_replacement_add   =  {
    //                                              treg_replacement_add[2*20+:20],
    //                                              treg_replacement_add[1*20+:20],
    //                                              treg_replacement_add[0*20+:20]
    //                   };
    //    endcase
    //end
    //
    // Map outputs from MRAM to the read-only register addresses ...
    //
    assign  read_only_in[0]                  =   64'h0000000000000000;
    assign  read_only_in[1]                  =   64'h0000000000000000;
    assign  read_only_in[2]                  =   64'h0000000000000000;
    assign  read_only_in[3]                  =   64'h0000000000000000;
    assign  read_only_in[4]                  =   64'h0000000000000000;
    assign  read_only_in[5]                  =   {{21{1'b0}}, treg_gbl_cfg};    //  [63:0]
    assign  read_only_in[6]                 =  {
                                                 6'b000000,
                                                 treg_blk3_man_fcnt,    //  [1:0]
                                                 treg_blk3_man_cnfg,    //  [3:0]
                                                 treg_blk3_man_ccnt,    //  [3:0]
                                                 6'b000000,
                                                 treg_blk2_man_fcnt,    //  [1:0]
                                                 treg_blk2_man_cnfg,    //  [3:0]
                                                 treg_blk2_man_ccnt,    //  [3:0]
                                                 6'b000000,
                                                 treg_blk1_man_fcnt,    //  [1:0]
                                                 treg_blk1_man_cnfg,    //  [3:0]
                                                 treg_blk1_man_ccnt,    //  [3:0]
                                                 6'b000000,
                                                 treg_blk0_man_fcnt,    //  [1:0]
                                                 treg_blk0_man_cnfg,    //  [3:0]
                                                 treg_blk0_man_ccnt     //  [3:0]
    };
    assign  read_only_in[7]                 =  {
                                                 6'b000000,
                                                 treg_blk7_man_fcnt,    //  [1:0]
                                                 treg_blk7_man_cnfg,    //  [3:0]
                                                 treg_blk7_man_ccnt,    //  [3:0]
                                                 6'b000000,
                                                 treg_blk6_man_fcnt,    //  [1:0]
                                                 treg_blk6_man_cnfg,    //  [3:0]
                                                 treg_blk6_man_ccnt,    //  [3:0]
                                                 6'b000000,
                                                 treg_blk5_man_fcnt,    //  [1:0]
                                                 treg_blk5_man_cnfg,    //  [3:0]
                                                 treg_blk5_man_ccnt,    //  [3:0]
                                                 6'b000000,
                                                 treg_blk4_man_fcnt,    //  [1:0]
                                                 treg_blk4_man_cnfg,    //  [3:0]
                                                 treg_blk4_man_ccnt     //  [3:0]
    };
    assign  read_only_in[8]                 =    treg_dout[63:0];       //  [63:0]
    assign  read_only_in[9]                 =  { {3{1'b0}},
                                                 treg_bist_rh1,
                                                 treg_bist_rh0,
                                                 treg_bist_error_count,
                                                 treg_bist_error_loop,
                                                 treg_dout[78:64]       //  [78:0]
    };
    assign  read_only_in[10]                =  {
                                                 treg_ecc_1bit,
                                                 treg_ecc_2bit,
                                                 treg_ecc_3bit,
                                                 treg_bist_busy,
                                                 treg_bist_error,
                                                 treg_bist_err_add,     //  [19:0]
                                                 5'b0,       //  [4:0]
                                                 treg_busy,
                                                 treg_cpu_intr_flag,
                                                 treg_intr_error_add,   //  [19:0]
                                                 // Removed for Boron ...
                                                 // treg_nvsram_boot_err,  //  [3:0]
                                                 1'b0,
                                                 treg_eccrom_pwr_ok,
                                                 treg_pwr_ok,
                                                 treg_bist_rh2,                     //treg_rep_add_cnt_o,    //  [4:0]
                                                 treg_temp              //  [1:0]
    };
    assign  read_only_in[11]                =    treg_bist_error_value[63:0];
    assign  read_only_in[12]                =  {
                                                 {49{1'b0}},
                                                 treg_bist_error_value[78:64]

    };
    //
    // Let's take care of the tri-state inouts ...
    //
    // [fc]cnt are read-only in Boron ...
    //
    //assign  treg_blk0_man_ccnt    =   treg_even_man_wr[0]  ?  reg_blk0_man_ccnt  :  4'bzzzz;
    assign  treg_blk0_man_cnfg    =   treg_even_man_wr[0]  ?  reg_blk0_man_cnfg  :  4'bzzzz;
    //assign  treg_blk0_man_fcnt    =   treg_even_man_wr[0]  ?  reg_blk0_man_fcnt  :  2'bzz;
    //assign  treg_blk1_man_ccnt    =   treg_even_man_wr[1]  ?  reg_blk1_man_ccnt  :  4'bzzzz;
    assign  treg_blk1_man_cnfg    =   treg_even_man_wr[1]  ?  reg_blk1_man_cnfg  :  4'bzzzz;
    //assign  treg_blk1_man_fcnt    =   treg_even_man_wr[1]  ?  reg_blk1_man_fcnt  :  2'bzz;
    //assign  treg_blk2_man_ccnt    =   treg_even_man_wr[2]  ?  reg_blk2_man_ccnt  :  4'bzzzz;
    assign  treg_blk2_man_cnfg    =   treg_even_man_wr[2]  ?  reg_blk2_man_cnfg  :  4'bzzzz;
    //assign  treg_blk2_man_fcnt    =   treg_even_man_wr[2]  ?  reg_blk2_man_fcnt  :  2'bzz;
    //assign  treg_blk3_man_ccnt    =   treg_even_man_wr[3]  ?  reg_blk3_man_ccnt  :  4'bzzzz;
    assign  treg_blk3_man_cnfg    =   treg_even_man_wr[3]  ?  reg_blk3_man_cnfg  :  4'bzzzz;
    //assign  treg_blk3_man_fcnt    =   treg_even_man_wr[3]  ?  reg_blk3_man_fcnt  :  2'bzz;
    //assign  treg_blk4_man_ccnt    =   treg_odd_man_wr[0]   ?  reg_blk4_man_ccnt  :  4'bzzzz;
    assign  treg_blk4_man_cnfg    =   treg_odd_man_wr[0]   ?  reg_blk4_man_cnfg  :  4'bzzzz;
    //assign  treg_blk4_man_fcnt    =   treg_odd_man_wr[0]   ?  reg_blk4_man_fcnt  :  2'bzz;
    //assign  treg_blk5_man_ccnt    =   treg_odd_man_wr[1]   ?  reg_blk5_man_ccnt  :  4'bzzzz;
    assign  treg_blk5_man_cnfg    =   treg_odd_man_wr[1]   ?  reg_blk5_man_cnfg  :  4'bzzzz;
    //assign  treg_blk5_man_fcnt    =   treg_odd_man_wr[1]   ?  reg_blk5_man_fcnt  :  2'bzz;
    //assign  treg_blk6_man_ccnt    =   treg_odd_man_wr[2]   ?  reg_blk6_man_ccnt  :  4'bzzzz;
    assign  treg_blk6_man_cnfg    =   treg_odd_man_wr[2]   ?  reg_blk6_man_cnfg  :  4'bzzzz;
    //assign  treg_blk6_man_fcnt    =   treg_odd_man_wr[2]   ?  reg_blk6_man_fcnt  :  2'bzz;
    //assign  treg_blk7_man_ccnt    =   treg_odd_man_wr[3]   ?  reg_blk7_man_ccnt  :  4'bzzzz;
    assign  treg_blk7_man_cnfg    =   treg_odd_man_wr[3]   ?  reg_blk7_man_cnfg  :  4'bzzzz;
    //assign  treg_blk7_man_fcnt    =   treg_odd_man_wr[3]   ?  reg_blk7_man_fcnt  :  2'bzz;

endmodule
