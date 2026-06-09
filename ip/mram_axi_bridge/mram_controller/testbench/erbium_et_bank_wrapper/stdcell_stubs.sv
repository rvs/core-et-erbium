// Behavioral stand-ins for foundry cells required by the wrapper RTL.
// These are used for simulation-only flows in this testbench directory.

module CKLNQD24BWP7D5T16P96CPD (
    input  logic CP,
    input  logic E,
    input  logic TE,
    output logic Q
);
    logic gate_latched;

    always_latch begin
        if (!CP) begin
            gate_latched <= (E | TE);
        end
    end

    assign Q = CP & gate_latched;
endmodule
module CKLNQD24BWP7D5T16P96CPDLVT (
    input  logic CP,
    input  logic E,
    input  logic TE,
    output logic Q
);
    logic gate_latched;

    always_latch begin
        if (!CP) begin
            gate_latched <= (E | TE);
        end
    end

    assign Q = CP & gate_latched;
endmodule
