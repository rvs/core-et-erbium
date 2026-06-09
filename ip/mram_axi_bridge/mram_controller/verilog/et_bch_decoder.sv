//============================================================
// BCH(78,64,t=2) Decoder + overall parity — purely combinational
// Shortened from BCH(127,113,t=2) over GF(2^7)
// Primitive polynomial: x^7 + x^3 + 1
// Corrects 1- and 2-bit errors; DETECTS 3-bit errors
//
// Input:  79-bit received word
//         [78]    = overall parity
//         [77:64] = BCH parity [13:0]
//         [63:0]  = data [63:0]
// Output: corrected 64-bit data + error status flags
//============================================================

module et_bch_decoder (
    input  wire [78:0] received,
    input  wire        ecc_bypass_en,
    output wire [77:0] corrected_data,
    output wire        no_error,
    output wire        single_bit_error,
    output wire        double_bit_error,
    output wire        triple_bit_error,
    output wire        uncorrectable
);

    //------------------------------------------------------------
    // Overall parity check
    //   parity_error = 1 means odd number of total bit errors
    //------------------------------------------------------------
    wire parity_check = ^received[77:0];
    wire parity_error = received[78] ^ parity_check;

    //------------------------------------------------------------
    // GF(2^7) multiply:  p(x) = x^7 + x^3 + 1
    //------------------------------------------------------------
    function [6:0] gf_mult;
        input [6:0] a, b;
        reg [13:0] p;
        begin
            p = (b[0] ? {7'b0, a}        : 14'b0)
              ^ (b[1] ? {6'b0, a, 1'b0}  : 14'b0)
              ^ (b[2] ? {5'b0, a, 2'b0}  : 14'b0)
              ^ (b[3] ? {4'b0, a, 3'b0}  : 14'b0)
              ^ (b[4] ? {3'b0, a, 4'b0}  : 14'b0)
              ^ (b[5] ? {2'b0, a, 5'b0}  : 14'b0)
              ^ (b[6] ? {1'b0, a, 6'b0}  : 14'b0);
            if (p[12]) p = p ^ 14'h1120;
            if (p[11]) p = p ^ 14'h0890;
            if (p[10]) p = p ^ 14'h0448;
            if (p[9]) p = p ^ 14'h0224;
            if (p[8]) p = p ^ 14'h0112;
            if (p[7]) p = p ^ 14'h0089;
            gf_mult = p[6:0];
        end
    endfunction

    //------------------------------------------------------------
    // GF(2^7) inverse lookup table
    //------------------------------------------------------------
    function [6:0] gf_inv;
        input [6:0] a;
        begin
            case (a)
                7'd  0: gf_inv = 7'd0;
                7'd  1: gf_inv = 7'd1;
                7'd  2: gf_inv = 7'd68;
                7'd  3: gf_inv = 7'd120;
                7'd  4: gf_inv = 7'd34;
                7'd  5: gf_inv = 7'd40;
                7'd  6: gf_inv = 7'd60;
                7'd  7: gf_inv = 7'd94;
                7'd  8: gf_inv = 7'd17;
                7'd  9: gf_inv = 7'd77;
                7'd 10: gf_inv = 7'd20;
                7'd 11: gf_inv = 7'd117;
                7'd 12: gf_inv = 7'd30;
                7'd 13: gf_inv = 7'd86;
                7'd 14: gf_inv = 7'd47;
                7'd 15: gf_inv = 7'd24;
                7'd 16: gf_inv = 7'd76;
                7'd 17: gf_inv = 7'd8;
                7'd 18: gf_inv = 7'd98;
                7'd 19: gf_inv = 7'd64;
                7'd 20: gf_inv = 7'd10;
                7'd 21: gf_inv = 7'd116;
                7'd 22: gf_inv = 7'd126;
                7'd 23: gf_inv = 7'd50;
                7'd 24: gf_inv = 7'd15;
                7'd 25: gf_inv = 7'd46;
                7'd 26: gf_inv = 7'd43;
                7'd 27: gf_inv = 7'd59;
                7'd 28: gf_inv = 7'd83;
                7'd 29: gf_inv = 7'd84;
                7'd 30: gf_inv = 7'd12;
                7'd 31: gf_inv = 7'd87;
                7'd 32: gf_inv = 7'd38;
                7'd 33: gf_inv = 7'd74;
                7'd 34: gf_inv = 7'd4;
                7'd 35: gf_inv = 7'd41;
                7'd 36: gf_inv = 7'd49;
                7'd 37: gf_inv = 7'd66;
                7'd 38: gf_inv = 7'd32;
                7'd 39: gf_inv = 7'd75;
                7'd 40: gf_inv = 7'd5;
                7'd 41: gf_inv = 7'd35;
                7'd 42: gf_inv = 7'd58;
                7'd 43: gf_inv = 7'd26;
                7'd 44: gf_inv = 7'd63;
                7'd 45: gf_inv = 7'd110;
                7'd 46: gf_inv = 7'd25;
                7'd 47: gf_inv = 7'd14;
                7'd 48: gf_inv = 7'd67;
                7'd 49: gf_inv = 7'd36;
                7'd 50: gf_inv = 7'd23;
                7'd 51: gf_inv = 7'd127;
                7'd 52: gf_inv = 7'd81;
                7'd 53: gf_inv = 7'd71;
                7'd 54: gf_inv = 7'd89;
                7'd 55: gf_inv = 7'd90;
                7'd 56: gf_inv = 7'd109;
                7'd 57: gf_inv = 7'd105;
                7'd 58: gf_inv = 7'd42;
                7'd 59: gf_inv = 7'd27;
                7'd 60: gf_inv = 7'd6;
                7'd 61: gf_inv = 7'd95;
                7'd 62: gf_inv = 7'd111;
                7'd 63: gf_inv = 7'd44;
                7'd 64: gf_inv = 7'd19;
                7'd 65: gf_inv = 7'd99;
                7'd 66: gf_inv = 7'd37;
                7'd 67: gf_inv = 7'd48;
                7'd 68: gf_inv = 7'd2;
                7'd 69: gf_inv = 7'd121;
                7'd 70: gf_inv = 7'd80;
                7'd 71: gf_inv = 7'd53;
                7'd 72: gf_inv = 7'd92;
                7'd 73: gf_inv = 7'd118;
                7'd 74: gf_inv = 7'd33;
                7'd 75: gf_inv = 7'd39;
                7'd 76: gf_inv = 7'd16;
                7'd 77: gf_inv = 7'd9;
                7'd 78: gf_inv = 7'd97;
                7'd 79: gf_inv = 7'd100;
                7'd 80: gf_inv = 7'd70;
                7'd 81: gf_inv = 7'd52;
                7'd 82: gf_inv = 7'd85;
                7'd 83: gf_inv = 7'd28;
                7'd 84: gf_inv = 7'd29;
                7'd 85: gf_inv = 7'd82;
                7'd 86: gf_inv = 7'd13;
                7'd 87: gf_inv = 7'd31;
                7'd 88: gf_inv = 7'd91;
                7'd 89: gf_inv = 7'd54;
                7'd 90: gf_inv = 7'd55;
                7'd 91: gf_inv = 7'd88;
                7'd 92: gf_inv = 7'd72;
                7'd 93: gf_inv = 7'd119;
                7'd 94: gf_inv = 7'd7;
                7'd 95: gf_inv = 7'd61;
                7'd 96: gf_inv = 7'd101;
                7'd 97: gf_inv = 7'd78;
                7'd 98: gf_inv = 7'd18;
                7'd 99: gf_inv = 7'd65;
                7'd100: gf_inv = 7'd79;
                7'd101: gf_inv = 7'd96;
                7'd102: gf_inv = 7'd123;
                7'd103: gf_inv = 7'd106;
                7'd104: gf_inv = 7'd108;
                7'd105: gf_inv = 7'd57;
                7'd106: gf_inv = 7'd103;
                7'd107: gf_inv = 7'd122;
                7'd108: gf_inv = 7'd104;
                7'd109: gf_inv = 7'd56;
                7'd110: gf_inv = 7'd45;
                7'd111: gf_inv = 7'd62;
                7'd112: gf_inv = 7'd114;
                7'd113: gf_inv = 7'd125;
                7'd114: gf_inv = 7'd112;
                7'd115: gf_inv = 7'd124;
                7'd116: gf_inv = 7'd21;
                7'd117: gf_inv = 7'd11;
                7'd118: gf_inv = 7'd73;
                7'd119: gf_inv = 7'd93;
                7'd120: gf_inv = 7'd3;
                7'd121: gf_inv = 7'd69;
                7'd122: gf_inv = 7'd107;
                7'd123: gf_inv = 7'd102;
                7'd124: gf_inv = 7'd115;
                7'd125: gf_inv = 7'd113;
                7'd126: gf_inv = 7'd22;
                7'd127: gf_inv = 7'd51;
            endcase
        end
    endfunction

    //------------------------------------------------------------
    // GF(2^7) discrete log: returns i such that alpha^i = a
    // Returns 127 for a=0 (invalid)
    //------------------------------------------------------------
    function [6:0] gf_log;
        input [6:0] a;
        begin
            case (a)
                7'd  0: gf_log = 7'd127;
                7'd  1: gf_log = 7'd0;
                7'd  2: gf_log = 7'd1;
                7'd  3: gf_log = 7'd31;
                7'd  4: gf_log = 7'd2;
                7'd  5: gf_log = 7'd62;
                7'd  6: gf_log = 7'd32;
                7'd  7: gf_log = 7'd103;
                7'd  8: gf_log = 7'd3;
                7'd  9: gf_log = 7'd7;
                7'd 10: gf_log = 7'd63;
                7'd 11: gf_log = 7'd15;
                7'd 12: gf_log = 7'd33;
                7'd 13: gf_log = 7'd84;
                7'd 14: gf_log = 7'd104;
                7'd 15: gf_log = 7'd93;
                7'd 16: gf_log = 7'd4;
                7'd 17: gf_log = 7'd124;
                7'd 18: gf_log = 7'd8;
                7'd 19: gf_log = 7'd121;
                7'd 20: gf_log = 7'd64;
                7'd 21: gf_log = 7'd79;
                7'd 22: gf_log = 7'd16;
                7'd 23: gf_log = 7'd115;
                7'd 24: gf_log = 7'd34;
                7'd 25: gf_log = 7'd11;
                7'd 26: gf_log = 7'd85;
                7'd 27: gf_log = 7'd38;
                7'd 28: gf_log = 7'd105;
                7'd 29: gf_log = 7'd46;
                7'd 30: gf_log = 7'd94;
                7'd 31: gf_log = 7'd51;
                7'd 32: gf_log = 7'd5;
                7'd 33: gf_log = 7'd82;
                7'd 34: gf_log = 7'd125;
                7'd 35: gf_log = 7'd60;
                7'd 36: gf_log = 7'd9;
                7'd 37: gf_log = 7'd44;
                7'd 38: gf_log = 7'd122;
                7'd 39: gf_log = 7'd77;
                7'd 40: gf_log = 7'd65;
                7'd 41: gf_log = 7'd67;
                7'd 42: gf_log = 7'd80;
                7'd 43: gf_log = 7'd42;
                7'd 44: gf_log = 7'd17;
                7'd 45: gf_log = 7'd69;
                7'd 46: gf_log = 7'd116;
                7'd 47: gf_log = 7'd23;
                7'd 48: gf_log = 7'd35;
                7'd 49: gf_log = 7'd118;
                7'd 50: gf_log = 7'd12;
                7'd 51: gf_log = 7'd28;
                7'd 52: gf_log = 7'd86;
                7'd 53: gf_log = 7'd25;
                7'd 54: gf_log = 7'd39;
                7'd 55: gf_log = 7'd57;
                7'd 56: gf_log = 7'd106;
                7'd 57: gf_log = 7'd19;
                7'd 58: gf_log = 7'd47;
                7'd 59: gf_log = 7'd89;
                7'd 60: gf_log = 7'd95;
                7'd 61: gf_log = 7'd71;
                7'd 62: gf_log = 7'd52;
                7'd 63: gf_log = 7'd110;
                7'd 64: gf_log = 7'd6;
                7'd 65: gf_log = 7'd14;
                7'd 66: gf_log = 7'd83;
                7'd 67: gf_log = 7'd92;
                7'd 68: gf_log = 7'd126;
                7'd 69: gf_log = 7'd30;
                7'd 70: gf_log = 7'd61;
                7'd 71: gf_log = 7'd102;
                7'd 72: gf_log = 7'd10;
                7'd 73: gf_log = 7'd37;
                7'd 74: gf_log = 7'd45;
                7'd 75: gf_log = 7'd50;
                7'd 76: gf_log = 7'd123;
                7'd 77: gf_log = 7'd120;
                7'd 78: gf_log = 7'd78;
                7'd 79: gf_log = 7'd114;
                7'd 80: gf_log = 7'd66;
                7'd 81: gf_log = 7'd41;
                7'd 82: gf_log = 7'd68;
                7'd 83: gf_log = 7'd22;
                7'd 84: gf_log = 7'd81;
                7'd 85: gf_log = 7'd59;
                7'd 86: gf_log = 7'd43;
                7'd 87: gf_log = 7'd76;
                7'd 88: gf_log = 7'd18;
                7'd 89: gf_log = 7'd88;
                7'd 90: gf_log = 7'd70;
                7'd 91: gf_log = 7'd109;
                7'd 92: gf_log = 7'd117;
                7'd 93: gf_log = 7'd27;
                7'd 94: gf_log = 7'd24;
                7'd 95: gf_log = 7'd56;
                7'd 96: gf_log = 7'd36;
                7'd 97: gf_log = 7'd49;
                7'd 98: gf_log = 7'd119;
                7'd 99: gf_log = 7'd113;
                7'd100: gf_log = 7'd13;
                7'd101: gf_log = 7'd91;
                7'd102: gf_log = 7'd29;
                7'd103: gf_log = 7'd101;
                7'd104: gf_log = 7'd87;
                7'd105: gf_log = 7'd108;
                7'd106: gf_log = 7'd26;
                7'd107: gf_log = 7'd55;
                7'd108: gf_log = 7'd40;
                7'd109: gf_log = 7'd21;
                7'd110: gf_log = 7'd58;
                7'd111: gf_log = 7'd75;
                7'd112: gf_log = 7'd107;
                7'd113: gf_log = 7'd54;
                7'd114: gf_log = 7'd20;
                7'd115: gf_log = 7'd74;
                7'd116: gf_log = 7'd48;
                7'd117: gf_log = 7'd112;
                7'd118: gf_log = 7'd90;
                7'd119: gf_log = 7'd100;
                7'd120: gf_log = 7'd96;
                7'd121: gf_log = 7'd97;
                7'd122: gf_log = 7'd72;
                7'd123: gf_log = 7'd98;
                7'd124: gf_log = 7'd53;
                7'd125: gf_log = 7'd73;
                7'd126: gf_log = 7'd111;
                7'd127: gf_log = 7'd99;
            endcase
        end
    endfunction

    //------------------------------------------------------------
    // Polynomial position → bus position lookup
    //   poly 0..13 (parity)  → bus 64..77
    //   poly 14..77 (data)   → bus 0..63
    //------------------------------------------------------------
    function [6:0] poly_to_bus;
        input [6:0] pp;
        begin
            if (pp < 7'd14)
                poly_to_bus = pp + 7'd64;  // parity bits
            else
                poly_to_bus = pp - 7'd14;  // data bits
        end
    endfunction

    //------------------------------------------------------------
    // Syndrome computation (over BCH codeword bits [77:0])
    //   S1 = R(alpha)   S3 = R(alpha^3)
    //   Computed using bus-position-aware alpha powers
    //------------------------------------------------------------
    wire [6:0] S1, S3;

    assign S1[0] = received[0] ^ received[1] ^ received[5] ^ received[7] ^ received[8] ^ received[9] ^ received[11] ^ received[13] ^ received[14] ^ received[16] ^ received[17] ^ received[23] ^ received[24] ^ received[27] ^ received[28] ^ received[30] ^ received[32] ^ received[35] ^ received[36] ^ received[37] ^ received[40] ^ received[41] ^ received[42] ^ received[43] ^ received[45] ^ received[46] ^ received[48] ^ received[53] ^ received[55] ^ received[57] ^ received[59] ^ received[60] ^ received[61] ^ received[62] ^ received[63] ^ received[64] ^ received[71] ^ received[75];
    assign S1[1] = received[1] ^ received[2] ^ received[6] ^ received[8] ^ received[9] ^ received[10] ^ received[12] ^ received[14] ^ received[15] ^ received[17] ^ received[18] ^ received[24] ^ received[25] ^ received[28] ^ received[29] ^ received[31] ^ received[33] ^ received[36] ^ received[37] ^ received[38] ^ received[41] ^ received[42] ^ received[43] ^ received[44] ^ received[46] ^ received[47] ^ received[49] ^ received[54] ^ received[56] ^ received[58] ^ received[60] ^ received[61] ^ received[62] ^ received[63] ^ received[65] ^ received[72] ^ received[76];
    assign S1[2] = received[2] ^ received[3] ^ received[7] ^ received[9] ^ received[10] ^ received[11] ^ received[13] ^ received[15] ^ received[16] ^ received[18] ^ received[19] ^ received[25] ^ received[26] ^ received[29] ^ received[30] ^ received[32] ^ received[34] ^ received[37] ^ received[38] ^ received[39] ^ received[42] ^ received[43] ^ received[44] ^ received[45] ^ received[47] ^ received[48] ^ received[50] ^ received[55] ^ received[57] ^ received[59] ^ received[61] ^ received[62] ^ received[63] ^ received[66] ^ received[73] ^ received[77];
    assign S1[3] = received[1] ^ received[3] ^ received[4] ^ received[5] ^ received[7] ^ received[9] ^ received[10] ^ received[12] ^ received[13] ^ received[19] ^ received[20] ^ received[23] ^ received[24] ^ received[26] ^ received[28] ^ received[31] ^ received[32] ^ received[33] ^ received[36] ^ received[37] ^ received[38] ^ received[39] ^ received[41] ^ received[42] ^ received[44] ^ received[49] ^ received[51] ^ received[53] ^ received[55] ^ received[56] ^ received[57] ^ received[58] ^ received[59] ^ received[61] ^ received[67] ^ received[71] ^ received[74] ^ received[75];
    assign S1[4] = received[2] ^ received[4] ^ received[5] ^ received[6] ^ received[8] ^ received[10] ^ received[11] ^ received[13] ^ received[14] ^ received[20] ^ received[21] ^ received[24] ^ received[25] ^ received[27] ^ received[29] ^ received[32] ^ received[33] ^ received[34] ^ received[37] ^ received[38] ^ received[39] ^ received[40] ^ received[42] ^ received[43] ^ received[45] ^ received[50] ^ received[52] ^ received[54] ^ received[56] ^ received[57] ^ received[58] ^ received[59] ^ received[60] ^ received[62] ^ received[68] ^ received[72] ^ received[75] ^ received[76];
    assign S1[5] = received[3] ^ received[5] ^ received[6] ^ received[7] ^ received[9] ^ received[11] ^ received[12] ^ received[14] ^ received[15] ^ received[21] ^ received[22] ^ received[25] ^ received[26] ^ received[28] ^ received[30] ^ received[33] ^ received[34] ^ received[35] ^ received[38] ^ received[39] ^ received[40] ^ received[41] ^ received[43] ^ received[44] ^ received[46] ^ received[51] ^ received[53] ^ received[55] ^ received[57] ^ received[58] ^ received[59] ^ received[60] ^ received[61] ^ received[63] ^ received[69] ^ received[73] ^ received[76] ^ received[77];
    assign S1[6] = received[0] ^ received[4] ^ received[6] ^ received[7] ^ received[8] ^ received[10] ^ received[12] ^ received[13] ^ received[15] ^ received[16] ^ received[22] ^ received[23] ^ received[26] ^ received[27] ^ received[29] ^ received[31] ^ received[34] ^ received[35] ^ received[36] ^ received[39] ^ received[40] ^ received[41] ^ received[42] ^ received[44] ^ received[45] ^ received[47] ^ received[52] ^ received[54] ^ received[56] ^ received[58] ^ received[59] ^ received[60] ^ received[61] ^ received[62] ^ received[70] ^ received[74] ^ received[77];

    assign S3[0] = received[0] ^ received[3] ^ received[4] ^ received[5] ^ received[6] ^ received[9] ^ received[11] ^ received[14] ^ received[17] ^ received[19] ^ received[20] ^ received[22] ^ received[24] ^ received[26] ^ received[32] ^ received[33] ^ received[36] ^ received[41] ^ received[42] ^ received[43] ^ received[45] ^ received[47] ^ received[48] ^ received[49] ^ received[52] ^ received[53] ^ received[54] ^ received[58] ^ received[59] ^ received[61] ^ received[62] ^ received[64] ^ received[69] ^ received[71] ^ received[73] ^ received[74];
    assign S3[1] = received[0] ^ received[1] ^ received[3] ^ received[5] ^ received[6] ^ received[7] ^ received[10] ^ received[11] ^ received[12] ^ received[16] ^ received[17] ^ received[19] ^ received[20] ^ received[23] ^ received[24] ^ received[31] ^ received[35] ^ received[36] ^ received[37] ^ received[38] ^ received[39] ^ received[41] ^ received[44] ^ received[45] ^ received[47] ^ received[51] ^ received[53] ^ received[54] ^ received[55] ^ received[56] ^ received[58] ^ received[59] ^ received[61] ^ received[62] ^ received[63] ^ received[68] ^ received[69] ^ received[72] ^ received[77];
    assign S3[2] = received[2] ^ received[3] ^ received[5] ^ received[9] ^ received[11] ^ received[12] ^ received[13] ^ received[14] ^ received[16] ^ received[17] ^ received[19] ^ received[20] ^ received[21] ^ received[23] ^ received[24] ^ received[25] ^ received[26] ^ received[27] ^ received[28] ^ received[29] ^ received[34] ^ received[36] ^ received[38] ^ received[39] ^ received[43] ^ received[46] ^ received[47] ^ received[48] ^ received[49] ^ received[52] ^ received[54] ^ received[57] ^ received[60] ^ received[62] ^ received[63] ^ received[67] ^ received[71] ^ received[72] ^ received[73] ^ received[74] ^ received[75] ^ received[77];
    assign S3[3] = received[0] ^ received[1] ^ received[3] ^ received[7] ^ received[9] ^ received[10] ^ received[11] ^ received[12] ^ received[14] ^ received[15] ^ received[17] ^ received[18] ^ received[19] ^ received[21] ^ received[22] ^ received[23] ^ received[24] ^ received[25] ^ received[26] ^ received[27] ^ received[32] ^ received[34] ^ received[36] ^ received[37] ^ received[41] ^ received[44] ^ received[45] ^ received[46] ^ received[47] ^ received[50] ^ received[52] ^ received[55] ^ received[58] ^ received[60] ^ received[61] ^ received[63] ^ received[65] ^ received[69] ^ received[70] ^ received[71] ^ received[72] ^ received[73] ^ received[75];
    assign S3[4] = received[2] ^ received[3] ^ received[4] ^ received[5] ^ received[8] ^ received[10] ^ received[13] ^ received[16] ^ received[18] ^ received[19] ^ received[21] ^ received[23] ^ received[25] ^ received[31] ^ received[32] ^ received[35] ^ received[40] ^ received[41] ^ received[42] ^ received[44] ^ received[46] ^ received[47] ^ received[48] ^ received[51] ^ received[52] ^ received[53] ^ received[57] ^ received[58] ^ received[60] ^ received[61] ^ received[68] ^ received[70] ^ received[72] ^ received[73] ^ received[77];
    assign S3[5] = received[0] ^ received[2] ^ received[4] ^ received[5] ^ received[6] ^ received[9] ^ received[10] ^ received[11] ^ received[15] ^ received[16] ^ received[18] ^ received[19] ^ received[22] ^ received[23] ^ received[30] ^ received[34] ^ received[35] ^ received[36] ^ received[37] ^ received[38] ^ received[40] ^ received[43] ^ received[44] ^ received[46] ^ received[50] ^ received[52] ^ received[53] ^ received[54] ^ received[55] ^ received[57] ^ received[58] ^ received[60] ^ received[61] ^ received[62] ^ received[67] ^ received[68] ^ received[71] ^ received[76] ^ received[77];
    assign S3[6] = received[1] ^ received[2] ^ received[4] ^ received[8] ^ received[10] ^ received[11] ^ received[12] ^ received[13] ^ received[15] ^ received[16] ^ received[18] ^ received[19] ^ received[20] ^ received[22] ^ received[23] ^ received[24] ^ received[25] ^ received[26] ^ received[27] ^ received[28] ^ received[33] ^ received[35] ^ received[37] ^ received[38] ^ received[42] ^ received[45] ^ received[46] ^ received[47] ^ received[48] ^ received[51] ^ received[53] ^ received[56] ^ received[59] ^ received[61] ^ received[62] ^ received[66] ^ received[70] ^ received[71] ^ received[72] ^ received[73] ^ received[74] ^ received[76];

    //------------------------------------------------------------
    // BCH syndrome-based classification
    //------------------------------------------------------------
    wire s1_is_zero = (S1 == 7'b0);
    wire s3_is_zero = (S3 == 7'b0);

    wire [6:0] S1_sq    = gf_mult(S1, S1);
    wire [6:0] S1_cubed = gf_mult(S1_sq, S1);

    wire bch_no_err    = s1_is_zero & s3_is_zero;
    wire bch_one_cand  = ~s1_is_zero & (S3 == S1_cubed);
    wire bch_two_cand  = ~s1_is_zero & (S3 != S1_cubed);
    wire bch_det_only  = s1_is_zero & ~s3_is_zero;

    //------------------------------------------------------------
    // Single-error location
    //   gf_log(S1) gives polynomial position of the error
    //   poly_to_bus converts to bus bit index
    //------------------------------------------------------------
    wire [6:0] err_poly_pos = gf_log(S1);
    wire bch_one_valid = bch_one_cand & (err_poly_pos < 7'd78);
    wire [6:0] err_bus_pos  = poly_to_bus(err_poly_pos);

    //------------------------------------------------------------
    // Double-error: error-locator polynomial
    //   sigma(x) = 1 + sigma1*x + sigma2*x^2
    //------------------------------------------------------------
    wire [6:0] sigma1 = S1;
    wire [6:0] S1_inv = gf_inv(S1);
    wire [6:0] sigma2 = gf_mult(S1_cubed ^ S3, S1_inv);

    //------------------------------------------------------------
    // Chien search: evaluate sigma(alpha^{-poly_pos[i]})
    //   for each bus position i = 0..77
    //------------------------------------------------------------
    wire [77:0] chien_hit;

    assign chien_hit[ 0] = (gf_mult(sigma2, 7'd127) ^ gf_mult(sigma1, 7'd99) ^ 7'd1) == 7'b0;  // bus[0]→poly[14]
    assign chien_hit[ 1] = (gf_mult(sigma2, 7'd121) ^ gf_mult(sigma1, 7'd117) ^ 7'd1) == 7'b0;  // bus[1]→poly[15]
    assign chien_hit[ 2] = (gf_mult(sigma2, 7'd60) ^ gf_mult(sigma1, 7'd126) ^ 7'd1) == 7'b0;  // bus[2]→poly[16]
    assign chien_hit[ 3] = (gf_mult(sigma2, 7'd15) ^ gf_mult(sigma1, 7'd63) ^ 7'd1) == 7'b0;  // bus[3]→poly[17]
    assign chien_hit[ 4] = (gf_mult(sigma2, 7'd101) ^ gf_mult(sigma1, 7'd91) ^ 7'd1) == 7'b0;  // bus[4]→poly[18]
    assign chien_hit[ 5] = (gf_mult(sigma2, 7'd59) ^ gf_mult(sigma1, 7'd105) ^ 7'd1) == 7'b0;  // bus[5]→poly[19]
    assign chien_hit[ 6] = (gf_mult(sigma2, 7'd104) ^ gf_mult(sigma1, 7'd112) ^ 7'd1) == 7'b0;  // bus[6]→poly[20]
    assign chien_hit[ 7] = (gf_mult(sigma2, 7'd26) ^ gf_mult(sigma1, 7'd56) ^ 7'd1) == 7'b0;  // bus[7]→poly[21]
    assign chien_hit[ 8] = (gf_mult(sigma2, 7'd66) ^ gf_mult(sigma1, 7'd28) ^ 7'd1) == 7'b0;  // bus[8]→poly[22]
    assign chien_hit[ 9] = (gf_mult(sigma2, 7'd84) ^ gf_mult(sigma1, 7'd14) ^ 7'd1) == 7'b0;  // bus[9]→poly[23]
    assign chien_hit[10] = (gf_mult(sigma2, 7'd21) ^ gf_mult(sigma1, 7'd7) ^ 7'd1) == 7'b0;  // bus[10]→poly[24]
    assign chien_hit[11] = (gf_mult(sigma2, 7'd39) ^ gf_mult(sigma1, 7'd71) ^ 7'd1) == 7'b0;  // bus[11]→poly[25]
    assign chien_hit[12] = (gf_mult(sigma2, 7'd111) ^ gf_mult(sigma1, 7'd103) ^ 7'd1) == 7'b0;  // bus[12]→poly[26]
    assign chien_hit[13] = (gf_mult(sigma2, 7'd125) ^ gf_mult(sigma1, 7'd119) ^ 7'd1) == 7'b0;  // bus[13]→poly[27]
    assign chien_hit[14] = (gf_mult(sigma2, 7'd61) ^ gf_mult(sigma1, 7'd127) ^ 7'd1) == 7'b0;  // bus[14]→poly[28]
    assign chien_hit[15] = (gf_mult(sigma2, 7'd45) ^ gf_mult(sigma1, 7'd123) ^ 7'd1) == 7'b0;  // bus[15]→poly[29]
    assign chien_hit[16] = (gf_mult(sigma2, 7'd41) ^ gf_mult(sigma1, 7'd121) ^ 7'd1) == 7'b0;  // bus[16]→poly[30]
    assign chien_hit[17] = (gf_mult(sigma2, 7'd40) ^ gf_mult(sigma1, 7'd120) ^ 7'd1) == 7'b0;  // bus[17]→poly[31]
    assign chien_hit[18] = (gf_mult(sigma2, 7'd10) ^ gf_mult(sigma1, 7'd60) ^ 7'd1) == 7'b0;  // bus[18]→poly[32]
    assign chien_hit[19] = (gf_mult(sigma2, 7'd70) ^ gf_mult(sigma1, 7'd30) ^ 7'd1) == 7'b0;  // bus[19]→poly[33]
    assign chien_hit[20] = (gf_mult(sigma2, 7'd85) ^ gf_mult(sigma1, 7'd15) ^ 7'd1) == 7'b0;  // bus[20]→poly[34]
    assign chien_hit[21] = (gf_mult(sigma2, 7'd55) ^ gf_mult(sigma1, 7'd67) ^ 7'd1) == 7'b0;  // bus[21]→poly[35]
    assign chien_hit[22] = (gf_mult(sigma2, 7'd107) ^ gf_mult(sigma1, 7'd101) ^ 7'd1) == 7'b0;  // bus[22]→poly[36]
    assign chien_hit[23] = (gf_mult(sigma2, 7'd124) ^ gf_mult(sigma1, 7'd118) ^ 7'd1) == 7'b0;  // bus[23]→poly[37]
    assign chien_hit[24] = (gf_mult(sigma2, 7'd31) ^ gf_mult(sigma1, 7'd59) ^ 7'd1) == 7'b0;  // bus[24]→poly[38]
    assign chien_hit[25] = (gf_mult(sigma2, 7'd97) ^ gf_mult(sigma1, 7'd89) ^ 7'd1) == 7'b0;  // bus[25]→poly[39]
    assign chien_hit[26] = (gf_mult(sigma2, 7'd58) ^ gf_mult(sigma1, 7'd104) ^ 7'd1) == 7'b0;  // bus[26]→poly[40]
    assign chien_hit[27] = (gf_mult(sigma2, 7'd74) ^ gf_mult(sigma1, 7'd52) ^ 7'd1) == 7'b0;  // bus[27]→poly[41]
    assign chien_hit[28] = (gf_mult(sigma2, 7'd86) ^ gf_mult(sigma1, 7'd26) ^ 7'd1) == 7'b0;  // bus[28]→poly[42]
    assign chien_hit[29] = (gf_mult(sigma2, 7'd81) ^ gf_mult(sigma1, 7'd13) ^ 7'd1) == 7'b0;  // bus[29]→poly[43]
    assign chien_hit[30] = (gf_mult(sigma2, 7'd54) ^ gf_mult(sigma1, 7'd66) ^ 7'd1) == 7'b0;  // bus[30]→poly[44]
    assign chien_hit[31] = (gf_mult(sigma2, 7'd73) ^ gf_mult(sigma1, 7'd33) ^ 7'd1) == 7'b0;  // bus[31]→poly[45]
    assign chien_hit[32] = (gf_mult(sigma2, 7'd48) ^ gf_mult(sigma1, 7'd84) ^ 7'd1) == 7'b0;  // bus[32]→poly[46]
    assign chien_hit[33] = (gf_mult(sigma2, 7'd12) ^ gf_mult(sigma1, 7'd42) ^ 7'd1) == 7'b0;  // bus[33]→poly[47]
    assign chien_hit[34] = (gf_mult(sigma2, 7'd3) ^ gf_mult(sigma1, 7'd21) ^ 7'd1) == 7'b0;  // bus[34]→poly[48]
    assign chien_hit[35] = (gf_mult(sigma2, 7'd102) ^ gf_mult(sigma1, 7'd78) ^ 7'd1) == 7'b0;  // bus[35]→poly[49]
    assign chien_hit[36] = (gf_mult(sigma2, 7'd93) ^ gf_mult(sigma1, 7'd39) ^ 7'd1) == 7'b0;  // bus[36]→poly[50]
    assign chien_hit[37] = (gf_mult(sigma2, 7'd53) ^ gf_mult(sigma1, 7'd87) ^ 7'd1) == 7'b0;  // bus[37]→poly[51]
    assign chien_hit[38] = (gf_mult(sigma2, 7'd47) ^ gf_mult(sigma1, 7'd111) ^ 7'd1) == 7'b0;  // bus[38]→poly[52]
    assign chien_hit[39] = (gf_mult(sigma2, 7'd109) ^ gf_mult(sigma1, 7'd115) ^ 7'd1) == 7'b0;  // bus[39]→poly[53]
    assign chien_hit[40] = (gf_mult(sigma2, 7'd57) ^ gf_mult(sigma1, 7'd125) ^ 7'd1) == 7'b0;  // bus[40]→poly[54]
    assign chien_hit[41] = (gf_mult(sigma2, 7'd44) ^ gf_mult(sigma1, 7'd122) ^ 7'd1) == 7'b0;  // bus[41]→poly[55]
    assign chien_hit[42] = (gf_mult(sigma2, 7'd11) ^ gf_mult(sigma1, 7'd61) ^ 7'd1) == 7'b0;  // bus[42]→poly[56]
    assign chien_hit[43] = (gf_mult(sigma2, 7'd100) ^ gf_mult(sigma1, 7'd90) ^ 7'd1) == 7'b0;  // bus[43]→poly[57]
    assign chien_hit[44] = (gf_mult(sigma2, 7'd25) ^ gf_mult(sigma1, 7'd45) ^ 7'd1) == 7'b0;  // bus[44]→poly[58]
    assign chien_hit[45] = (gf_mult(sigma2, 7'd36) ^ gf_mult(sigma1, 7'd82) ^ 7'd1) == 7'b0;  // bus[45]→poly[59]
    assign chien_hit[46] = (gf_mult(sigma2, 7'd9) ^ gf_mult(sigma1, 7'd41) ^ 7'd1) == 7'b0;  // bus[46]→poly[60]
    assign chien_hit[47] = (gf_mult(sigma2, 7'd32) ^ gf_mult(sigma1, 7'd80) ^ 7'd1) == 7'b0;  // bus[47]→poly[61]
    assign chien_hit[48] = (gf_mult(sigma2, 7'd8) ^ gf_mult(sigma1, 7'd40) ^ 7'd1) == 7'b0;  // bus[48]→poly[62]
    assign chien_hit[49] = (gf_mult(sigma2, 7'd2) ^ gf_mult(sigma1, 7'd20) ^ 7'd1) == 7'b0;  // bus[49]→poly[63]
    assign chien_hit[50] = (gf_mult(sigma2, 7'd68) ^ gf_mult(sigma1, 7'd10) ^ 7'd1) == 7'b0;  // bus[50]→poly[64]
    assign chien_hit[51] = (gf_mult(sigma2, 7'd17) ^ gf_mult(sigma1, 7'd5) ^ 7'd1) == 7'b0;  // bus[51]→poly[65]
    assign chien_hit[52] = (gf_mult(sigma2, 7'd38) ^ gf_mult(sigma1, 7'd70) ^ 7'd1) == 7'b0;  // bus[52]→poly[66]
    assign chien_hit[53] = (gf_mult(sigma2, 7'd77) ^ gf_mult(sigma1, 7'd35) ^ 7'd1) == 7'b0;  // bus[53]→poly[67]
    assign chien_hit[54] = (gf_mult(sigma2, 7'd49) ^ gf_mult(sigma1, 7'd85) ^ 7'd1) == 7'b0;  // bus[54]→poly[68]
    assign chien_hit[55] = (gf_mult(sigma2, 7'd46) ^ gf_mult(sigma1, 7'd110) ^ 7'd1) == 7'b0;  // bus[55]→poly[69]
    assign chien_hit[56] = (gf_mult(sigma2, 7'd79) ^ gf_mult(sigma1, 7'd55) ^ 7'd1) == 7'b0;  // bus[56]→poly[70]
    assign chien_hit[57] = (gf_mult(sigma2, 7'd117) ^ gf_mult(sigma1, 7'd95) ^ 7'd1) == 7'b0;  // bus[57]→poly[71]
    assign chien_hit[58] = (gf_mult(sigma2, 7'd63) ^ gf_mult(sigma1, 7'd107) ^ 7'd1) == 7'b0;  // bus[58]→poly[72]
    assign chien_hit[59] = (gf_mult(sigma2, 7'd105) ^ gf_mult(sigma1, 7'd113) ^ 7'd1) == 7'b0;  // bus[59]→poly[73]
    assign chien_hit[60] = (gf_mult(sigma2, 7'd56) ^ gf_mult(sigma1, 7'd124) ^ 7'd1) == 7'b0;  // bus[60]→poly[74]
    assign chien_hit[61] = (gf_mult(sigma2, 7'd14) ^ gf_mult(sigma1, 7'd62) ^ 7'd1) == 7'b0;  // bus[61]→poly[75]
    assign chien_hit[62] = (gf_mult(sigma2, 7'd71) ^ gf_mult(sigma1, 7'd31) ^ 7'd1) == 7'b0;  // bus[62]→poly[76]
    assign chien_hit[63] = (gf_mult(sigma2, 7'd119) ^ gf_mult(sigma1, 7'd75) ^ 7'd1) == 7'b0;  // bus[63]→poly[77]
    assign chien_hit[64] = (gf_mult(sigma2, 7'd1) ^ gf_mult(sigma1, 7'd1) ^ 7'd1) == 7'b0;  // bus[64]→poly[0]
    assign chien_hit[65] = (gf_mult(sigma2, 7'd34) ^ gf_mult(sigma1, 7'd68) ^ 7'd1) == 7'b0;  // bus[65]→poly[1]
    assign chien_hit[66] = (gf_mult(sigma2, 7'd76) ^ gf_mult(sigma1, 7'd34) ^ 7'd1) == 7'b0;  // bus[66]→poly[2]
    assign chien_hit[67] = (gf_mult(sigma2, 7'd19) ^ gf_mult(sigma1, 7'd17) ^ 7'd1) == 7'b0;  // bus[67]→poly[3]
    assign chien_hit[68] = (gf_mult(sigma2, 7'd98) ^ gf_mult(sigma1, 7'd76) ^ 7'd1) == 7'b0;  // bus[68]→poly[4]
    assign chien_hit[69] = (gf_mult(sigma2, 7'd92) ^ gf_mult(sigma1, 7'd38) ^ 7'd1) == 7'b0;  // bus[69]→poly[5]
    assign chien_hit[70] = (gf_mult(sigma2, 7'd23) ^ gf_mult(sigma1, 7'd19) ^ 7'd1) == 7'b0;  // bus[70]→poly[6]
    assign chien_hit[71] = (gf_mult(sigma2, 7'd99) ^ gf_mult(sigma1, 7'd77) ^ 7'd1) == 7'b0;  // bus[71]→poly[7]
    assign chien_hit[72] = (gf_mult(sigma2, 7'd126) ^ gf_mult(sigma1, 7'd98) ^ 7'd1) == 7'b0;  // bus[72]→poly[8]
    assign chien_hit[73] = (gf_mult(sigma2, 7'd91) ^ gf_mult(sigma1, 7'd49) ^ 7'd1) == 7'b0;  // bus[73]→poly[9]
    assign chien_hit[74] = (gf_mult(sigma2, 7'd112) ^ gf_mult(sigma1, 7'd92) ^ 7'd1) == 7'b0;  // bus[74]→poly[10]
    assign chien_hit[75] = (gf_mult(sigma2, 7'd28) ^ gf_mult(sigma1, 7'd46) ^ 7'd1) == 7'b0;  // bus[75]→poly[11]
    assign chien_hit[76] = (gf_mult(sigma2, 7'd7) ^ gf_mult(sigma1, 7'd23) ^ 7'd1) == 7'b0;  // bus[76]→poly[12]
    assign chien_hit[77] = (gf_mult(sigma2, 7'd103) ^ gf_mult(sigma1, 7'd79) ^ 7'd1) == 7'b0;  // bus[77]→poly[13]

    //------------------------------------------------------------
    // Chien-search hit count
    //------------------------------------------------------------
    reg [6:0] chien_count;
    integer _j;
    always @(*) begin
        chien_count = 7'd0;
        for (_j = 0; _j < 78; _j = _j + 1)
            chien_count = chien_count + {6'b0, chien_hit[_j]};
    end

    wire bch_two_valid = bch_two_cand & (chien_count == 7'd2);

    //------------------------------------------------------------
    // Combined error classification with overall parity
    //------------------------------------------------------------
    assign no_error = bch_no_err & ~parity_error;

    assign single_bit_error = (bch_one_valid & parity_error)
                            | (bch_no_err    & parity_error);

    assign double_bit_error = (bch_two_valid  & ~parity_error)
                            | (bch_one_valid  & ~parity_error);

    assign triple_bit_error = (bch_two_valid  & parity_error)
                            | (bch_two_cand   & ~bch_two_valid & parity_error)
                            | (bch_one_cand   & ~bch_one_valid & parity_error)
                            | (bch_det_only   & parity_error);

    assign uncorrectable = (bch_det_only  & ~parity_error)
                         | (bch_two_cand  & ~bch_two_valid & ~parity_error)
                         | (bch_one_cand  & ~bch_one_valid & ~parity_error);

    //------------------------------------------------------------
    // Error correction pattern (bus-ordered)
    //------------------------------------------------------------
    reg [77:0] error_pattern;
    always @(*) begin
        error_pattern = 78'b0;
        if (bch_one_valid) begin
            error_pattern[err_bus_pos] = 1'b1;
        end else if (bch_two_valid & ~parity_error) begin
            error_pattern = chien_hit;
        end
    end

    //------------------------------------------------------------
    // Corrected output
    //------------------------------------------------------------
    wire [77:0] corrected_codeword = ecc_bypass_en? received[77:0] : received[77:0] ^ error_pattern;
    assign corrected_data = corrected_codeword;

endmodule
