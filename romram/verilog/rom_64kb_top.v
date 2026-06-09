//Custom Compiler Version T-2022.06-SP2
//Sat Jul  8 11:47:10 2023

////////////////////////////////////////////////////////////////////////////////
// Library          : argon
// Cell             : rom_instance_flat
// View             : schematic
// View Search List : symbol
// View Stop List   : functional behavioral symbol
////////////////////////////////////////////////////////////////////////////////
module rom_64kb_top( addr, ce, clk,ds, rst_b, rd_out);
    // Port declarations
    input [9:0]  addr;
    input ce;
    input clk;
    input ds;
    input rst_b;
    output [63:0]  rd_out;
endmodule //rom_instance_flat

