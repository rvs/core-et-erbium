package Axi2MramUtils;

import Fabric_Defs :: *;
import Vector      :: *;

export vec4;
export addr_in_range;
export translate_addr;
export masked_byte_size_selection;
export isWrite;
export isRMW;
export getWriteReq;
export getRMWReq;
export expand_strb_to_bitmask;
export expand_wstrb_to_bitmask;
export bank_has_write_data;
export MemoryOperation(..);
export WriteRequest(..);
export ReadModifyWriteRequest(..);

function Vector#(4, t) vec4(t a, t b, t c, t d);
    return cons(a, cons(b, cons(c, cons(d, nil))));
endfunction

typedef struct {
    Bit#(3)  inst;
    Bit#(17) addr;
    Bit#(64) data;
    Bit#(8)  strb;
} WriteRequest deriving (Bits, Eq, FShow);
typedef struct {
    Bit#(3)  inst;
    Bit#(17) addr;
    Bit#(64) data;
    Bit#(8)  strb;
} ReadModifyWriteRequest deriving (Bits, Eq, FShow);

typedef union tagged {
    WriteRequest            Write;
    ReadModifyWriteRequest  RMW;
} MemoryOperation deriving (Bits, Eq, FShow);

function Bool addr_in_otp_window (Bit #(Wd_Addr) addr);
    return (addr >= 32'h3FFF_D000 && addr < 32'h4000_0000);
endfunction

function Bool addr_in_range (Bit #(Wd_Addr) addr);
    Bool in_mram_window = (addr[31:24] == 8'h00);
    Bool in_otp_window  = addr_in_otp_window(addr);
    return in_mram_window || in_otp_window;
endfunction

function Bit #(Wd_Addr) translate_addr (Bit #(Wd_Addr) addr);
    Bit #(Wd_Addr) translated_otp_address = addr;

    if (addr_in_otp_window(addr)) begin
        case (addr[15:8])
            8'hD0: translated_otp_address = zeroExtend({17'h100C0, addr[7:0]});
            8'hD1: translated_otp_address = zeroExtend({17'h100C3, addr[7:0]});
            8'hD2: translated_otp_address = zeroExtend({17'h100C4, addr[7:0]});
            8'hD3: translated_otp_address = zeroExtend({17'h100C9, addr[7:0]});
            8'hD4: translated_otp_address = zeroExtend({17'h100CA, addr[7:0]});
            8'hD5: translated_otp_address = zeroExtend({17'h100CF, addr[7:0]});
            8'hD6: translated_otp_address = zeroExtend({17'h120C0, addr[7:0]});
            8'hD7: translated_otp_address = zeroExtend({17'h120C3, addr[7:0]});
            8'hD8: translated_otp_address = zeroExtend({17'h120C4, addr[7:0]});
            8'hD9: translated_otp_address = zeroExtend({17'h120C9, addr[7:0]});
            8'hDA: translated_otp_address = zeroExtend({17'h120CA, addr[7:0]});
            8'hDB: translated_otp_address = zeroExtend({17'h120CF, addr[7:0]});
            8'hDC: translated_otp_address = zeroExtend({17'h140C0, addr[7:0]});
            8'hDD: translated_otp_address = zeroExtend({17'h140C3, addr[7:0]});
            8'hDE: translated_otp_address = zeroExtend({17'h140C4, addr[7:0]});
            8'hDF: translated_otp_address = zeroExtend({17'h140C9, addr[7:0]});
            8'hE0: translated_otp_address = zeroExtend({17'h140CA, addr[7:0]});
            8'hE1: translated_otp_address = zeroExtend({17'h140CF, addr[7:0]});
            8'hE2: translated_otp_address = zeroExtend({17'h160C0, addr[7:0]});
            8'hE3: translated_otp_address = zeroExtend({17'h160C3, addr[7:0]});
            8'hE4: translated_otp_address = zeroExtend({17'h160C4, addr[7:0]});
            8'hE5: translated_otp_address = zeroExtend({17'h160C9, addr[7:0]});
            8'hE6: translated_otp_address = zeroExtend({17'h160CA, addr[7:0]});
            8'hE7: translated_otp_address = zeroExtend({17'h160CF, addr[7:0]});
            8'hE8: translated_otp_address = zeroExtend({17'h180C0, addr[7:0]});
            8'hE9: translated_otp_address = zeroExtend({17'h180C3, addr[7:0]});
            8'hEA: translated_otp_address = zeroExtend({17'h180C4, addr[7:0]});
            8'hEB: translated_otp_address = zeroExtend({17'h180C9, addr[7:0]});
            8'hEC: translated_otp_address = zeroExtend({17'h180CA, addr[7:0]});
            8'hED: translated_otp_address = zeroExtend({17'h180CF, addr[7:0]});
            8'hEE: translated_otp_address = zeroExtend({17'h1A0C0, addr[7:0]});
            8'hEF: translated_otp_address = zeroExtend({17'h1A0C3, addr[7:0]});
            8'hF0: translated_otp_address = zeroExtend({17'h1A0C4, addr[7:0]});
            8'hF1: translated_otp_address = zeroExtend({17'h1A0C9, addr[7:0]});
            8'hF2: translated_otp_address = zeroExtend({17'h1A0CA, addr[7:0]});
            8'hF3: translated_otp_address = zeroExtend({17'h1A0CF, addr[7:0]});
            8'hF4: translated_otp_address = zeroExtend({17'h1C0C0, addr[7:0]});
            8'hF5: translated_otp_address = zeroExtend({17'h1C0C3, addr[7:0]});
            8'hF6: translated_otp_address = zeroExtend({17'h1C0C4, addr[7:0]});
            8'hF7: translated_otp_address = zeroExtend({17'h1C0C9, addr[7:0]});
            8'hF8: translated_otp_address = zeroExtend({17'h1C0CA, addr[7:0]});
            8'hF9: translated_otp_address = zeroExtend({17'h1C0CF, addr[7:0]});
            8'hFA: translated_otp_address = zeroExtend({17'h1E0C0, addr[7:0]});
            8'hFB: translated_otp_address = zeroExtend({17'h1E0C3, addr[7:0]});
            8'hFC: translated_otp_address = zeroExtend({17'h1E0C4, addr[7:0]});
            8'hFD: translated_otp_address = zeroExtend({17'h1E0C9, addr[7:0]});
            8'hFE: translated_otp_address = zeroExtend({17'h1E0CA, addr[7:0]});
            8'hFF: translated_otp_address = zeroExtend({17'h1E0CF, addr[7:0]});
            default: translated_otp_address = addr;
        endcase
    end

    return translated_otp_address;
endfunction

function Bit#(64) masked_byte_size_selection(Bit#(3) word_size_b);
    Bit#(64) mask   = 0;
    Bit#(1) byte_mask = '1;
    Bit#(2) hword_mask = '1;
    Bit#(4) word_mask = '1;
    Bit#(8) dword_mask = '1;
    Bit#(16) qword_mask = '1;
    Bit#(32) oword_mask = '1;
    Bit#(64) xword_mask = '1;
    case (unpack(word_size_b))
        3'd0: mask = zeroExtend(byte_mask);
        3'd1: mask = zeroExtend(hword_mask);
        3'd2: mask = zeroExtend(word_mask);
        3'd3: mask = zeroExtend(dword_mask);
        3'd4: mask = zeroExtend(qword_mask);
        3'd5: mask = zeroExtend(oword_mask);
        3'd6: mask = xword_mask;
        default: mask = 0;
    endcase
    return mask;
endfunction

function Bit#(64) expand_strb_to_bitmask(Bit#(8) strb);
    Bit#(64) mask = 0;
    for (Integer i = 0; i < 8; i = i + 1)
        if (strb[i] == 1) mask[(i*8+7):(i*8)] = 8'hFF;
    return mask;
endfunction

function Bit#(512) expand_wstrb_to_bitmask(Bit#(64) strb);
    Bit#(512) mask = 0;
    for (Integer i = 0; i < 64; i = i + 1)
        if (strb[i] == 1) mask[(i*8+7):(i*8)] = 8'hFF;
    return mask;
endfunction

function Bool isWrite(MemoryOperation op);
    return (op matches tagged Write .* ? True : False);
endfunction

function Bool isRMW(MemoryOperation op);
    return (op matches tagged RMW .* ? True : False);
endfunction

function WriteRequest getWriteReq(MemoryOperation op);
    case (op) matches
        tagged Write .req: return req;
        default: return ?;
    endcase
endfunction

function ReadModifyWriteRequest getRMWReq(MemoryOperation op);
    case (op) matches
        tagged RMW .req: return req;
        default: return ?;
    endcase
endfunction

function Bool bank_has_write_data(Bit#(64) wstrb, Integer bank_idx);
    Bool has_data = False;
    case (bank_idx)
        0: has_data = (|wstrb[15:0])  == 1;
        1: has_data = (|wstrb[31:16]) == 1;
        2: has_data = (|wstrb[47:32]) == 1;
        3: has_data = (|wstrb[63:48]) == 1;
    endcase
    return has_data;
endfunction

endpackage
