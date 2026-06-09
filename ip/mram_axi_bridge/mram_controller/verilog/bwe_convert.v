module bwe_convert (
                        input [7:0] bwe_in,
                        output [78:0]  bwe_out
                     );
    assign bwe_out = { {15{1'b1}},
                       {8{bwe_in[7]}},
                       {8{bwe_in[6]}},
                       {8{bwe_in[5]}},
                       {8{bwe_in[4]}},
                       {8{bwe_in[3]}},
                       {8{bwe_in[2]}},
                       {8{bwe_in[1]}},
                       {8{bwe_in[0]}}
                     };
endmodule
