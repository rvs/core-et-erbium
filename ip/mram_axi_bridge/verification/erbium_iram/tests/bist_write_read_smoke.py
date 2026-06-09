import cocotb

from tb import my_tb
from tests.bist_common import MASK79, configure_bist, configure_bist_pattern, pulse_bist_start, read_mem_word, read_status1, wait_bist_done, write_mem_word


@cocotb.test()
async def bist_write_read_smoke(dut):
    """Quick non-ET BIST smoke: write a small window, then read/compare it back."""
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    my_tb.set_wave_matrix_label("bist_write_read_smoke")
    await my_tb.reset_sequence()

    apb = my_tb.apb_master(0)
    pattern = 0x0123_4567_89AB_CDEF_123 & MASK79
    start_addr = 0x00020
    stop_addr = 0x00027

    for bist_addr in range(start_addr, stop_addr + 1):
        write_mem_word(0, bist_addr, 0)

    await configure_bist_pattern(apb, din=pattern, bwe=MASK79)
    await configure_bist(
        apb,
        wr_en=1,
        rd_en=0,
        rte_en=0,
        bist_reset=0,
        start_add=start_addr,
        stop_add=stop_addr,
        add_inc=0,
        loop_count=0,
        data_inv=0,
        stop_on_error=0,
        stop_on_repl_of=0,
        trim_mode=0,
        rh4_margin=0,
        ref_prg_en=0,
        test_reg_ovr_en=0,
    )

    dut._log.info(
        "write_bist start=0x%05x stop=0x%05x pattern=0x%020x",
        start_addr,
        stop_addr,
        pattern,
    )
    await pulse_bist_start(apb)
    write_status = await wait_bist_done(apb)
    assert write_status["bist_error"] == 0

    for bist_addr in range(start_addr, stop_addr + 1):
        observed = read_mem_word(0, bist_addr)
        assert observed == pattern, (
            f"write_bist: addr=0x{bist_addr:05x} expected 0x{pattern:020x}, "
            f"got 0x{observed:020x}"
        )

    await configure_bist(
        apb,
        wr_en=0,
        rd_en=1,
        rte_en=0,
        bist_reset=0,
        start_add=start_addr,
        stop_add=stop_addr,
        add_inc=0,
        loop_count=0,
        data_inv=0,
        stop_on_error=1,
        stop_on_repl_of=0,
        trim_mode=0,
        rh4_margin=0,
        ref_prg_en=0,
        test_reg_ovr_en=0,
    )

    dut._log.info("read_bist start=0x%05x stop=0x%05x", start_addr, stop_addr)
    await pulse_bist_start(apb)
    read_status = await wait_bist_done(apb)
    assert read_status["bist_error"] == 0

    final_status = await read_status1(apb)
    assert final_status["bist_busy"] == 0
    assert final_status["bist_error"] == 0
