import cocotb
from tb import *


@cocotb.test()
async def bist_write_read_smoke(dut):
    """Quick smoke: run BIST write mode followed by BIST read mode on bank0."""
    if not controller_reg_model_ready(dut):
        return

    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(777)

    reg_model: TregRegModel = build_treg_reg_model(my_tb.axi_treg_master)
    regs = reg_model.bank0_tregs
    bist_control_fields = await regs.bist_control.read_fields()
    has_bist_rst_b = "bist_rst_b" in bist_control_fields

    bank = 0
    start_add = 0x20
    stop_add = 0x2F
    bist_pattern = 0x0123_4567_89AB_CDEF_123
    full_bwe = (1 << 79) - 1

    def read_raw_word(bank_idx, inst_idx, addr):
        my_tb.warn_direct_mram_access(
            "read",
            "bist_write_read_smoke hierarchy spot-check",
            tag="bist_write_read_smoke.direct_readback",
        )
        instance = my_tb.get_mram_instance(bank_idx, inst_idx)
        plane_idx, plane_addr = my_tb.decode_mram_word_addr(addr)
        return int(my_tb._memory_word_handle(instance, plane_idx, plane_addr).value)

    async def wait_bist_done(label, timeout_ns=5_000):
        poll_step_ns = 20
        max_polls = max(1, timeout_ns // poll_step_ns)
        saw_busy = False
        for _ in range(max_polls):
            busy = await regs.bist_status_1.bist_busy.read()
            if busy:
                saw_busy = True
            if saw_busy and not busy:
                return
            await Timer(poll_step_ns, unit="ns")
        raise AssertionError(f"{label}: timed out waiting for BIST completion")

    async def run_bist_once(label, rd_en, wr_en, loop_count=0):
        ctrl_1_setup = {
            "bist_loop_count": loop_count,
            "bist_trim_mode": 0,
            "bist_stop_on_repl_of": 0,
            "bist_reset": 0,
            "bist_rd_en": rd_en,
            "bist_wr_en": wr_en,
            "bist_start": 0,
        }
        if has_bist_rst_b:
            ctrl_1_setup["bist_rst_b"] = 1
        await regs.bist_control.write_fields(**ctrl_1_setup)
        await regs.bist_control.write_fields(
            **({"bist_rst_b": 1} if has_bist_rst_b else {}),
            bist_start=1,
        )
        await wait_bist_done(label)
        await regs.bist_control.write_fields(
            **({"bist_rst_b": 1} if has_bist_rst_b else {}),
            bist_start=0,
        )

        bist_error = await regs.bist_status_1.bist_error.read()
        bist_err_add = await regs.bist_status_1.bist_err_add.read()
        assert bist_error == 0, (
            f"{label}: bist_error asserted (bist_err_add=0x{bist_err_add:x})"
        )

    # Explicitly pulse BIST reset_n once so mkEtBist FSM gets a deterministic reset
    # even if global reset did not overlap an internal BIST clock edge.
    if has_bist_rst_b:
        await regs.bist_control.write_fields(
            bist_loop_count=0,
            bist_trim_mode=0,
            bist_stop_on_repl_of=0,
            bist_reset=0,
            bist_rd_en=0,
            bist_wr_en=0,
            bist_start=0,
            bist_rst_b=0,
        )
        await Timer(20, unit="ns")
        await regs.bist_control.write_fields(
            bist_rst_b=1,
        )
        await Timer(20, unit="ns")
    else:
        dut._log.warning(
            "bist_rst_b field not present in generated reg model; "
            "skipping explicit mkEtBist reset pulse"
        )

    # Keep MRAM clocks ungated while running the BIST smoke.
    await reg_model.bridge_regs.control_reg.write_fields(
        disable_clock_gate=0xF
    )

    # Configure expected data/mask used by BIST compare logic.
    await write_mram_control_fields(
        regs,
        bwe=full_bwe,
        din=bist_pattern,
    )

    # Configure BIST address window and behavior for write/read passes.
    await regs.bist_control.write_fields(
        bist_rte_en=0,
        bist_data_inv=0,
        bist_add_inc=0,
        bist_stop_on_error=0,
        bist_start_add=start_add,
        bist_stop_add=stop_add,
        RH4margin=10,
    )

    # 1) Write BIST pass
    await run_bist_once("write_bist", rd_en=0, wr_en=1, loop_count=0)

    # Spot-check the first instance selected by address[18:16]==0 (instances 0).
    probe_addr = start_add
    probe_even = read_raw_word(bank, 0, probe_addr)
    assert probe_even == bist_pattern, (
        f"write_bist spot-check mismatch (inst0 addr=0x{probe_addr:05x}): "
        f"expected 0x{bist_pattern:020x}, got 0x{probe_even:020x}"
    )
    await regs.bist_control.write_fields(
        bist_rte_en=0,
        bist_data_inv=0,
        bist_add_inc=0,
        bist_stop_on_error=1,
        bist_start_add=start_add,
        bist_stop_add=stop_add,
        RH4margin=10,
    )

    # 2) Read/compare BIST pass
    await run_bist_once("read_bist", rd_en=1, wr_en=0, loop_count=0)

    # 3) Reference-trim (RTE) BIST pass
    await regs.bist_control.write_fields(
        bist_rte_en=1,
        bist_data_inv=0,
        bist_add_inc=0,
        bist_stop_on_error=0,
        bist_start_add=start_add,
        bist_stop_add=stop_add,
        RH4margin=10,
    )
    await run_bist_once("rte_bist", rd_en=0, wr_en=0, loop_count=0)

    await Timer(100, unit="ns")
