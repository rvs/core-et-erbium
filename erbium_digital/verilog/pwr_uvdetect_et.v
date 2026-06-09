module pwr_uvdetect_et( pwr_uv_b
`ifdef GLS
  , vdd18, vdd_c, vdd_d, vss
`endif
);

    // Port declarations

    output pwr_uv_b;
`ifdef GLS
    inout vdd18;
    inout vdd_c;
    inout vdd_d;
    inout vss;
`endif
    assign pwr_uv_b = 1;
endmodule

