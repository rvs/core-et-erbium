import cocotb
from cocotb.triggers import RisingEdge, with_timeout

from tb import my_tb, sig_int


STATUS_REG_INDEX = 10
STATUS_CPU_INTR_FLAG_BIT = 32
STATUS_INTR_ERROR_ADDR_LSB = 12
STATUS_INTR_ERROR_ADDR_MASK = (1 << 20) - 1
DIRECT_ECC2_MASK = 0x3


def axi_byte_addr_to_word_addr(byte_addr):
    assert (byte_addr & 0x7) == 0, f"Expected 8-byte aligned address, got 0x{byte_addr:x}"
    return byte_addr >> 3


def word_addr_to_behavioral_index(word_addr):
    stripe_sel = (word_addr >> 17) & 0x3
    otp_space = (word_addr >> 19) & 0x1
    low_addr = word_addr & 0x1FFFF
    return (stripe_sel << 18) | (otp_space << 17) | low_addr


def decode_status_reg(status_value):
    return {
        "cpu_intr_flag": (status_value >> STATUS_CPU_INTR_FLAG_BIT) & 0x1,
        "intr_error_addr": (status_value >> STATUS_INTR_ERROR_ADDR_LSB) & STATUS_INTR_ERROR_ADDR_MASK,
    }


@cocotb.test()
async def cpu_interrupt_ecc2(dut):
    """Inject a 2-bit ECC error, expect cpu_intr, and read back the captured address."""
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    my_tb.set_wave_matrix_label("cpu_interrupt_ecc2")
    await my_tb.reset_sequence()

    target_byte_addr = 0x0020_0000
    expected_word_addr = axi_byte_addr_to_word_addr(target_byte_addr)
    behavioral_index = word_addr_to_behavioral_index(expected_word_addr)
    payload = bytes.fromhex("efcdab8967452301")

    bank = my_tb.get_behavioral_bank(0)
    mem_word = my_tb.get_behavioral_mem_word(0, behavioral_index)
    apb = my_tb.apb_master(0)

    dut._log.info(
        "cpu_interrupt_ecc2 write addr=0x%08x word_addr=0x%05x mem_idx=0x%05x data=%s",
        target_byte_addr,
        expected_word_addr,
        behavioral_index,
        payload.hex(),
    )
    await my_tb.axi_write(target_byte_addr, payload, size=3)
    await my_tb.wait_for_axi_idle()

    stored_codeword = int(mem_word.value)
    assert stored_codeword != 0, "Expected non-zero stored codeword after initialization write"

    corrupted_codeword = stored_codeword ^ DIRECT_ECC2_MASK

    dut._log.info(
        "cpu_interrupt_ecc2 inject stored=0x%x corrupted=0x%x mask=0x%x",
        stored_codeword,
        corrupted_codeword,
        DIRECT_ECC2_MASK,
    )
    mem_word.value = corrupted_codeword

    readback = await my_tb.axi_read(target_byte_addr, 8, size=3)
    dut._log.info(
        "cpu_interrupt_ecc2 read addr=0x%08x data=%s",
        target_byte_addr,
        readback.hex(),
    )
    await my_tb.wait_for_axi_idle()

    async def wait_for_cpu_intr():
        while not sig_int(dut.cpu_intr):
            await RisingEdge(dut.clk)

    await with_timeout(wait_for_cpu_intr(), 2000, "ns")
    assert sig_int(dut.cpu_intr) == 1

    status_value = await apb.read64(STATUS_REG_INDEX)
    status = decode_status_reg(status_value)
    dut._log.info(
        "cpu_interrupt_ecc2 status raw=0x%016x cpu_intr_flag=%d intr_error_addr=0x%05x",
        status_value,
        status["cpu_intr_flag"],
        status["intr_error_addr"],
    )

    assert status["cpu_intr_flag"] == 1
    assert status["intr_error_addr"] == expected_word_addr
