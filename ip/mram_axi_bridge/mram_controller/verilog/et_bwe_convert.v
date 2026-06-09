module et_bwe_convert (
                        input  [63:0] bwe_in,
                        output [78:0] bwe_out
                     );
    assign bwe_out = { {15{1'b1}}, bwe_in };
endmodule
