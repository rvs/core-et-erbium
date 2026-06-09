import random

import cocotb
from cocotb.triggers import Timer, Edge
from cocotb.clock import Clock
from cocotb.triggers import *
from cocotb.clock import Clock
#import pydevd_pycharm
# https://blog.patfarley.org/pages/cocotb-pycharm.html
#pydevd_pycharm.settrace('localhost', port=9090, stdoutToServer=True, stderrToServer=True)

class TB:
    def __init__(self):
        self.number_of_vectors = 1000
        pass

    def set_dut(self, dut):
        self.dut = dut

    def init_signals(self):
        self.dut.data_to_encode_i.value = 0
        # self.dut.ecc_encoded_data_o,
        self.dut.uncorrected_data_i.value = 0
        self.dut.disable_ted_i.value = 0
        self.dut.ecc_bypass_en_i.value = 0
        self.dut.ref_ecc_sel_i.value = 1
        # self.dut.corrected_data_o,
        # self.dut.single_error_o,
        # self.dut.double_error_o,
        # self.dut.triple_error_o

    def setup_tb(self):
        self.init_signals()

my_tb = TB()
def parity_encoder(input):
    # P1  = M1 ^ M2 ^ M4 ^ M5 ^ M7 ^ M9 ^ M11 ^ M12 ^ M14
    # P2  = M1 ^ M3 ^ M4 ^ M6 ^ M7 ^ M10 ^ M11 ^ M13 ^ M14
    # P4  = M2 ^ M3 ^ M4 ^ M8 ^ M9 ^ M10 ^ M11 ^ M15
    # P8  = M5 ^ M6 ^ M7 ^ M8 ^ M9 ^ M10 ^ M11
    # P16 = M12 ^ M13 ^ M14 ^ M15
    M = []
    for i in range(15):
        M.append((input >> i) % 2)
    P = [0, 0, 0, 0, 0]
    P[0] = M[1 - 1] ^ M[2 - 1] ^ M[4 - 1] ^ M[5 - 1] ^ M[7 - 1] ^ M[9 - 1] ^ M[11 - 1] ^ M[12 - 1] ^ M[14 - 1]
    P[1] = M[1 - 1] ^ M[3 - 1] ^ M[4 - 1] ^ M[6 - 1] ^ M[7 - 1] ^ M[10 - 1] ^ M[11 - 1] ^ M[13 - 1] ^ M[14 - 1]
    P[2] = M[2 - 1] ^ M[3 - 1] ^ M[4 - 1] ^ M[8 - 1] ^ M[9 - 1] ^ M[10 - 1] ^ M[11 - 1] ^ M[15 - 1]
    P[3] = M[5 - 1] ^ M[6 - 1] ^ M[7 - 1] ^ M[8 - 1] ^ M[9 - 1] ^ M[10 - 1] ^ M[11 - 1]
    P[4] = M[12 - 1] ^ M[13 - 1] ^ M[14 - 1] ^ M[15 - 1]
    return P

def encode_word(input):
    P = parity_encoder(input)
    M = []
    for i in range(15):
        M.append((input >> i) % 2)
    codeword = 0
    for i in range(20):
        if i in [0, 1, 3, 7, 15]:
            codeword |= P.pop(0) << i
        else:
            codeword |= M.pop(0) << i
    return codeword

def encode_codeword(input):
    expected_codeword = 0
    for i in range(4):
        expected_codeword |= (encode_word(((input >> (i * 15)) & 0x7fff))) << (i * 20)

    upper_bits = expected_codeword & 0xf0000000000000000000
    lower_bits = expected_codeword & 0x07ffffffffffffffffff
    expected_codeword = (upper_bits >> 1) | lower_bits
    return expected_codeword

@cocotb.test()
async def ref_ecc_encode_check(dut):
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    my_tb.dut.ref_ecc_sel_i.value = 1
    for i in range(my_tb.number_of_vectors):
        value_to_encode = random.randint(0, 2**64)
        my_tb.dut.data_to_encode_i.value = value_to_encode
        await Timer(1, units="ns")
        encoded_value = my_tb.dut.ecc_encoded_data_o.value.integer
        expected_codeword = encode_codeword(value_to_encode)
        # print(f"{value_to_encode:020x} {encoded_value:020x} {expected_codeword&0x7fffffffffffffffffff:020x}")
        # print(f"{(encoded_value^expected_codeword) & 0x7fffffffffffffffffff:020x}")
        await Timer(1, units="ns")
        assert encoded_value == (expected_codeword & 0x7fffffffffffffffffff)

@cocotb.test()
async def ref_ecc_decode_check_no_errors(dut):
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    my_tb.dut.ref_ecc_sel_i.value = 1
    for i in range(my_tb.number_of_vectors):
        value_to_encode = random.randint(0, 2**64) & 0x0fffffffffffffff
        my_tb.dut.data_to_encode_i.value = value_to_encode
        await Timer(1, units="ns")
        encoded_value = my_tb.dut.ecc_encoded_data_o.value.integer
        my_tb.dut.uncorrected_data_i.value = encoded_value
        # print(f"{value_to_encode:020x} {encoded_value:020x} {expected_codeword&0x7fffffffffffffffffff:020x}")
        await Timer(1, units="ns")
        corrected_value = my_tb.dut.corrected_data_o.value.integer
        # print(f"{(value_to_encode^corrected_value):016x}")
        assert value_to_encode == corrected_value

@cocotb.test()
async def ref_ecc_decode_check_single_errors(dut):
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    my_tb.dut.ref_ecc_sel_i.value = 1
    allowed_data_list = [
        0x0000800100020004,
        0x0000800100025000,
        0x0000800128005000,
        0x0000940028005000,
        0x0a00140028005000,
        0x0a00140028007800,
        0x0a0014003c007800,
        0x0a001e003c007800,
        0x0f001e003c007800,
        0x0f001e003c007c40,
        0x0f001e003e207c40,
        0x0f001f103e207c40,
        0x0f881f103e207c40,
        0x0f881f103e207e02,
        0x0f881f103f017e02,
        0x0f881f80bf017e02,
        0x0fc05f80bf017e02,
        0x0fc05f80bf017f00,
        0x0fc05f80bf807f00,
        0x0fc05fc03f807f00,
        0x0fe01fc03f807f00,
        0x0fe01fc03f807f80,
        0x0fe01fc03fc07f80,
        0x0fe01fe03fc07f80,
        0x0ff01fe03fc07f80,
        0x0ff01fe03fc07f84,
        0x0ff01fe03fc27f84,
        0x0ff01fe13fc27f84,
        0x0ff09fe13fc27f84,
        0x0ff09fe13fc27fa4,
        0x0ff09fe13fd27fa4,
        0x0ff09fe93fd27fa4,
        0x0ff49fe93fd27fa4,
        0x0ff49fe93fd27fc4,
        0x0ff49fe93fe27fc4,
        0x0ff49ff13fe27fc4,
        0x0ff89ff13fe27fc4,
        0x0ff89ff13fe27fe4,
        0x0ff89ff13ff27fe4,
        0x0ff89ff93ff27fe4,
        0x0ffc9ff93ff27fe4,
        0x0ffc9ff93ff27ff4,
        0x0ffc9ff93ffa7ff4,
        0x0ffc9ffd3ffa7ff4,
        0x0ffe9ffd3ffa7ff4,
        0x0ffe9ffd3ffa7ff8,
        0x0ffe9ffd3ffc7ff8,
        0x0ffe9ffe3ffc7ff8,
        0x0fff1ffe3ffc7ff8,
        0x0fff1ffe3ffc7ffc,
        0x0fff1ffe3ffe7ffc,
        0x0fff1fff3ffe7ffc,
        0x0fff9fff3ffe7ffc,
        0x0fff9fff3ffe7ffd,
        0x0fff9fff3ffefffd,
        0x0fff9fff7ffefffd,
        0x0fffbfff7ffefffd,
        0x0fffbfff7ffeffff,
        0x0fffbfff7fffffff,
        0x0fffbfffffffffff,
        0x0fffffffffffffff,

    ]
    for data in allowed_data_list:
        for i in range(79):
            value_to_encode = data
            my_tb.dut.data_to_encode_i.value = value_to_encode
            await Timer(1, units="ns")
            encoded_value = my_tb.dut.ecc_encoded_data_o.value.integer
            err_loc = i
            my_tb.dut.uncorrected_data_i.value = encoded_value ^ (1 << (err_loc))
            # print(f"{value_to_encode:020x} {encoded_value:020x} {expected_codeword&0x7fffffffffffffffffff:020x}")
            await Timer(1, units="ns")
            corrected_value = my_tb.dut.corrected_data_o.value.integer
            print(f"error at: {err_loc}, {(value_to_encode^corrected_value):016x}")
            assert value_to_encode == corrected_value

    # for i in range(my_tb.number_of_vectors):
    #     value_to_encode = random.randint(0, 2**64) & 0x0fffffffffffffff
    #     my_tb.dut.data_to_encode_i.value = value_to_encode
    #     await Timer(1, units="ns")
    #     encoded_value = my_tb.dut.ecc_encoded_data_o.value.integer
    #     err_loc = random.randint(0, 78)
    #     my_tb.dut.uncorrected_data_i.value = encoded_value ^ (1 << (err_loc))
    #     # print(f"{value_to_encode:020x} {encoded_value:020x} {expected_codeword&0x7fffffffffffffffffff:020x}")
    #     await Timer(1, units="ns")
    #     corrected_value = my_tb.dut.corrected_data_o.value.integer
    #     print(f"error at: {err_loc}, {(value_to_encode^corrected_value):016x}")
    #     # assert value_to_encode == corrected_value


@cocotb.test()
async def ref_ecc_verify_rom_codes(dut):
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    my_tb.dut.ref_ecc_sel_i.value = 1
    ecc_rom_upper_section = [
        0b00000000000000101010,
        0b01010000000000001010,
        0b01111000000000001000,
        0b01111100010000000000,
        0b01111110000000010000,
        0b01111111000010000000,
        0b01111111100000001000,
        0b01111111100000100010,
        0b01111111101010100000,
        0b01111111110010100001,
        0b01111111111000100011,
        0b01111111111110100010,
        0b01111111111111000011,
        0b01111111111111101001,
        0b01111111111111101110,
        0b01111111111111110111,
    ]
    ecc_rom_section = [
        0b00000000000000101010,
        0b10100000000000001010,
        0b11110000000000001000,
        0b11110100010000000000,
        0b11110110000000010000,
        0b11110111000010000000,
        0b11110111100000001000,
        0b11110111100000100010,
        0b11110111101010100000,
        0b11110111110010100001,
        0b11110111111000100011,
        0b11110111111110100010,
        0b11110111111111000011,
        0b11110111111111101001,
        0b11110111111111101110,
        0b11110111111111110111,
    ]

    # Construct the ecc codes
    ecc_rom_codes = []
    col_i = [0, 0, 0, 0]
    col_sel = 0
    while True:
        ecc_rom_codes.append(
            [
                ecc_rom_section[col_i[0]],
                ecc_rom_section[col_i[1]],
                ecc_rom_section[col_i[2]],
                ecc_rom_upper_section[col_i[3]]
            ]
        )
        col_i[col_sel] += 1
        if col_i[col_sel] == 16:
            break
        col_sel += 1
        if col_sel == 4:
            col_sel = 0
    for i in ecc_rom_codes:
        constructed_code = (i[0] << 0 ) | \
                           (i[1] << 20) | \
                           (i[2] << 40) | \
                           (i[3] << 60)
        my_tb.dut.uncorrected_data_i.value = constructed_code
        await Timer(1, units="ns")
        # print(f"{value_to_encode:020x} {encoded_value:020x} {expected_codeword&0x7fffffffffffffffffff:020x}")
        corrected_value = my_tb.dut.corrected_data_o.value.integer
        my_tb.dut.data_to_encode_i.value = corrected_value
        await Timer(1, units="ns")
        encoded_value = my_tb.dut.ecc_encoded_data_o.value.integer
        await Timer(1, units="ns")
        print(f"{(constructed_code):020x} {(encoded_value):020x} {my_tb.dut.data_to_encode_i.value.integer:016x}")
        assert encoded_value == constructed_code
