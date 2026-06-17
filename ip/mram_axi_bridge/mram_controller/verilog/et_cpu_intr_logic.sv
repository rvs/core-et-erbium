// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: Copyright (c) 2026 Ainekko, Co.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

module et_cpu_intr_logic(
    input logic         clk,
    input logic         rst_b,

    input logic         disable_i,
    input logic         rst_intr_i,
    input logic         single_bit_error_i,
    input logic         double_bit_error_i,
    input logic         triple_bit_error_i,
    input logic         mask_single_bit_errors_i,
    input logic         mask_double_bit_errors_i,
    input logic         mask_triple_bit_errors_i,
    input logic  [3:0]  dout_en_i,
    input logic  [16:0] add_i,

    output logic [18:0] error_add_o,
    output logic        ecc_1bit_flag_o,
    output logic        ecc_2bit_flag_o,
    output logic        ecc_3bit_flag_o,
    output logic        cpu_intr_o
);

    logic [3:0]     dout_en_d, dout_en_q0, dout_en_q1;
    logic [16:0]    add_d, add_q0, add_q1;
    logic [18:0]    error_add_d, error_add_q;
    logic [1:0]     dout_en_log2;
    logic           cpu_intr_d, cpu_intr_q;
    logic           ecc_1bit_flag_d, ecc_1bit_flag_q;
    logic           ecc_2bit_flag_d, ecc_2bit_flag_q;
    logic           ecc_3bit_flag_d, ecc_3bit_flag_q;
    logic           single_bit_error_masked;
    logic           double_bit_error_masked;
    logic           triple_bit_error_masked;
    logic           any_error_masked;

    always_ff @(posedge clk, negedge rst_b) begin
        if (~rst_b) begin
            error_add_q      <= 0;
            cpu_intr_q       <= 0;
            add_q0           <= 0;
            add_q1           <= 0;
            dout_en_q0       <= 0;
            dout_en_q1       <= 0;
            ecc_1bit_flag_q  <= 0;
            ecc_2bit_flag_q  <= 0;
            ecc_3bit_flag_q  <= 0;
        end else begin
            if (rst_intr_i) begin
                cpu_intr_q       <= 0;
                error_add_q      <= 0;
                ecc_1bit_flag_q  <= 0;
                ecc_2bit_flag_q  <= 0;
                ecc_3bit_flag_q  <= 0;
            end else begin
                cpu_intr_q       <= cpu_intr_d;
                error_add_q      <= error_add_d;
                ecc_1bit_flag_q  <= ecc_1bit_flag_d;
                ecc_2bit_flag_q  <= ecc_2bit_flag_d;
                ecc_3bit_flag_q  <= ecc_3bit_flag_d;
            end
            add_q0           <= add_d;
            add_q1           <= add_q0;
            dout_en_q0       <= dout_en_d;
            dout_en_q1       <= dout_en_q0;

        end
    end

    always_comb begin
        error_add_o      = error_add_q;
        cpu_intr_o       = cpu_intr_q;
        ecc_1bit_flag_o  = ecc_1bit_flag_q;
        ecc_2bit_flag_o  = ecc_2bit_flag_q;
        ecc_3bit_flag_o  = ecc_3bit_flag_q;
        add_d            = add_i;
        dout_en_d        = dout_en_i;

        single_bit_error_masked = single_bit_error_i & ~mask_single_bit_errors_i;
        double_bit_error_masked = double_bit_error_i & ~mask_double_bit_errors_i;
        triple_bit_error_masked = triple_bit_error_i & ~mask_triple_bit_errors_i;
        any_error_masked        = single_bit_error_masked | double_bit_error_masked | triple_bit_error_masked;

        // 4'b1000 => 2'b11;
        // 4'b0100 => 2'b10;
        // 4'b0010 => 2'b01;
        // 4'b0001 => 2'b00;
        dout_en_log2      = dout_en_q1[3] == 1 ? 2'b11 :
                            dout_en_q1[2] == 1 ? 2'b10 :
                            dout_en_q1[1] == 1 ? 2'b01 :
                            dout_en_q1[0] == 1 ? 2'b00 :
                            2'b00;
        //dout_en_log2 = $clog2(dout_en_q1);
        if (any_error_masked & ~disable_i) begin
            if (~cpu_intr_q) begin
                // Capture the first error we encounter
                error_add_d      = {add_q1[16], dout_en_log2, add_q1[15:0]};
                cpu_intr_d       = 1;
                ecc_1bit_flag_d  = single_bit_error_masked;
                ecc_2bit_flag_d  = double_bit_error_masked;
                ecc_3bit_flag_d  = triple_bit_error_masked;
            end else begin
                // Keep our error until it is reset.
                cpu_intr_d       = cpu_intr_q;
                error_add_d      = error_add_q;
                ecc_1bit_flag_d  = ecc_1bit_flag_q;
                ecc_2bit_flag_d  = ecc_2bit_flag_q;
                ecc_3bit_flag_d  = ecc_3bit_flag_q;
            end
        end else begin
            // Hold previous status until rst_intr_i explicitly clears it.
            cpu_intr_d       = cpu_intr_q;
            error_add_d      = error_add_q;
            ecc_1bit_flag_d  = ecc_1bit_flag_q;
            ecc_2bit_flag_d  = ecc_2bit_flag_q;
            ecc_3bit_flag_d  = ecc_3bit_flag_q;
        end
    end
endmodule
