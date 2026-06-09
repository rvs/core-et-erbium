module clk_gate (
        input    clk_in,
        input    gate0,
        input    gate1,
        input    rst_b,
        output   clk_out
    );

    reg    gate_q;
    logic  gate;

    assign gate  =  gate0  &  gate1;

    CKLNQD24BWP7D5T16P96CPD chipid_clk_gate (
        .CP(clk_in),
        .E(gate),
        .TE(1'b0),
        .Q(clk_out)
    );

    /*
    always_latch  begin
        if (~rst_b)
            gate_q <= 1'b0;
        else if (~clk_in)
            gate_q <= gate;
    end

    assign clk_out  =  gate_q  &  clk_in;
    */
endmodule : clk_gate
