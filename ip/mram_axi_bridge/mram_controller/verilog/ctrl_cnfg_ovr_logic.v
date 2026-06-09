module ctrl_cnfg_ovr_logic (
        input  [42:0]  treg_gbl_cfg_ovr,
        input          treg_gbl_cfg_ovr_en,
        inout  [42:0]  gbl_cfg,
        input          dsleep,
        input          treg_mram_dsleep_en,
        input          test_cal_en,
        output         mram_dsleep
    );

    assign  mram_dsleep    =  dsleep  |  treg_mram_dsleep_en;
    assign  gbl_cfg        =  (treg_gbl_cfg_ovr_en | test_cal_en) ? treg_gbl_cfg_ovr  :  {43{1'bz}};
    
endmodule

