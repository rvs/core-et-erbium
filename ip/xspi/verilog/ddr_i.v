/*
 Copyright: Copyright (c) 2025 Ainekko, Co. All rights reserved.
 Author: Vijayvithal <jvs@nekko.ai>
 Created on: 2025-10-31
 Description: Input bus handler.
     For SPI Modes the commands address and data can come at different rates.
     On receiving the command we need to decode it to identify whether the next phase is data or address.
     In a pipelined decoder this is too late.
     So we impose a limit that the data and address should be at the same rate, command could be at different rate.
     The module takes two rates, it ingests the first byte after csn goes low at the first rate and the remaining bytes at different rate.
     The Ingested data is demangled and either 1 or two bytes are outputted with a Data valid signal.

     For Hyperbus mode command and data are at 8D rate.
*/
module ddr_i #(parameter BUS_WIDTH=8) (
input wire [BUS_WIDTH-1 : 0] din,
output reg [BUS_WIDTH-1 : 0] data_re,
output reg [BUS_WIDTH-1 : 0] data_fe,
input wire rwds_in,
output reg rwds_re,
output reg rwds_fe,
output reg data_valid,
input wire [3:0] cmd_data_rate,
input wire [3:0] addr_data_rate,
input wire ena,
input wire ddr_mode,
input wire clk
);
enum {S1,D1,S2,D2,S4,D4,S8,D8,HB} Rates;

reg [3:0] bit_counter;
reg [3:0] data_rate =cmd_data_rate;
reg first_byte;
always@(posedge clk)
        if(!ena)begin
                data_rate <= cmd_data_rate;
                first_byte <= 1'b1;
                data_valid<=0;
                case(cmd_data_rate)
                        S1: bit_counter<=7;
                        D1: bit_counter<=3;
                        S4: bit_counter<=1;
                        default: bit_counter<=0;
                endcase
        end else begin
                data_valid<=0;
                bit_counter <= bit_counter -1;
                if(bit_counter == 0 )begin
                    if(first_byte && cmd_data_rate!=S1 && cmd_data_rate !=D1)begin 
                        case(cmd_data_rate)
                                S1: bit_counter<=7;
                                D1: bit_counter<=3;
                                S4: bit_counter<=1;
                                default: bit_counter<=0;
                        endcase
                        first_byte <=0;
                        data_rate<=cmd_data_rate;
                        data_valid<=1;
                    end else begin 
                        case(addr_data_rate)
                                S1: bit_counter<=7;
                                D1: bit_counter<=3;
                                S4: bit_counter<=1;
                                default: bit_counter<=0;
                        endcase
                        data_rate<=addr_data_rate;
                        data_valid<=1;
                    end
                end
        end

always @(posedge clk) if(ena) begin
    case (data_rate)
        S1,D1://SPI
               data_re<={data_re[6:0],din[0]};
        S4,D4: // QSPI
               data_re<={data_re[3:0],din[3:0]};
        default: // OSPI
            data_re <=din[7:0];
    endcase
    rwds_re <= rwds_in;
end
always @(negedge clk) if(ena & ddr_mode)begin
    case (data_rate)
        D1://SPI
               data_fe<={data_fe[6:0],din[0]};
        D4: // QSPI
               data_fe<={data_fe[3:0],din[3:0]};
        D8,HB: // OSPI
            data_fe <=din[7:0];
    default:
            data_fe <=data_fe;
    endcase
    rwds_fe <= rwds_in;
end
endmodule
// vim: expandtab ts=4 shiftwidth=4
