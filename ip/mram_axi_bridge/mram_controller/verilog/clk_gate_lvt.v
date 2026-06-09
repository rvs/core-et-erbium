module clk_gate_lvt (
        input    clk_in,
        input    gate0,
        input    gate1,
        input    rst_b,
        output   clk_out
    );

    reg    gate_q;
    logic  gate;

    assign gate  =  gate0  &  gate1;

    CKLNQD24BWP7D5T16P96CPDLVT stdcell_clk_gate (
        .CP(clk_in),
        .E(gate),
        .TE(1'b0),
        .Q(clk_out)
    );

endmodule : clk_gate_lvt
