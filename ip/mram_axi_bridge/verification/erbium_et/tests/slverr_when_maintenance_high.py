import cocotb
from tb import *


@cocotb.test()
async def slverr_when_maintenance_high(dut):
    """Force maintenance active and verify AXI SLVERR + maintenance status flag."""
    if not controller_reg_model_ready(dut):
        return

    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(611)

    axi_master = my_tb.axi_master
    reg_model = build_treg_reg_model(my_tb.axi_treg_master)
    regs = reg_model.bank0_tregs

    # Keep clocks ungated for deterministic behavior while forcing signals.
    await reg_model.bridge_regs.control_reg.write_fields(
        disable_clock_gate=0xF
    )

    # Ensure bank0 is powered before maintenance override.
    pwr_ok = 0
    for _ in range(100):
        pwr_ok = await reg_model.bank0_tregs.mram_status_1.pwr_ok.read()
        if pwr_ok == 1:
            break
        await Timer(10, unit="ns")
    assert pwr_ok == 1, "Expected bank0 pwr_ok=1 before maintenance test"

    try:
        await write_mram_control_fields(
            regs,
            maintenance_mode=1
        )
        await Timer(1, unit="ns")

        async def read_slverr_status():
            raw = await my_tb.axi_treg_master.read(SLVERR_STATUS_REG_ADDR, 8)
            return int.from_bytes(raw.data, "little")

        async def assert_status_after_burst(op_desc):
            # slverr_status_reg is clear-on-read.
            status = await read_slverr_status()
            assert (status & (1 << 4)) != 0, (
                f"{op_desc}: expected maintenance[4] set in slverr_status_reg, got 0x{status:016x}"
            )
            assert (status & ((1 << 2) | (1 << 3) | (1 << 4))) != 0, (
                f"{op_desc}: expected one of mram_not_ready/mram_unpowered/maintenance bits set, "
                f"got 0x{status:016x}"
            )

        # Clear stale sticky bits before per-burst checks.
        _ = await read_slverr_status()

        # Compact matrix for runtime: cover multiple burst sizes and lengths.
        burst_sizes = (0, 3, 6)          # 1B, 8B, 64B beats
        burst_lens = (0, 1, 3, 7, 31, 63)
        max_burst_bytes = 4096

        def req_bytes(size, length_field):
            return (1 << size) * (length_field + 1)

        # Read checks.
        case_idx = 0
        for size in burst_sizes:
            for arlen in burst_lens:
                burst_bytes = req_bytes(size, arlen)
                if burst_bytes > max_burst_bytes:
                    continue
                addr = 0x0000_0200 + (case_idx * 0x80)
                beats = arlen + 1
                timeout_ns = max(2000, 200 + (beats * 40))

                read_op = axi_master.init_read(addr, burst_bytes, size=size)
                await cocotb.triggers.with_timeout(read_op.wait(), timeout_ns, "ns")
                assert axi_resp(read_op) == AxiResp.SLVERR, (
                    f"Maintenance read burst size={size} arlen={arlen} addr=0x{addr:08x}: "
                    f"expected SLVERR, got {axi_resp(read_op)}"
                )
                await assert_status_after_burst(
                    f"read burst size={size} arlen={arlen} bytes={burst_bytes} addr=0x{addr:08x}"
                )
                case_idx += 1

        # Write checks.
        case_idx = 0
        for size in burst_sizes:
            for awlen in burst_lens:
                burst_bytes = req_bytes(size, awlen)
                if burst_bytes > max_burst_bytes:
                    continue
                addr = 0x0000_0600 + (case_idx * 0x80)
                beats = awlen + 1
                timeout_ns = max(2000, 200 + (beats * 40))
                payload = bytes(rand_bytes(burst_bytes))

                write_op = axi_master.init_write(addr, payload, size=size)
                await cocotb.triggers.with_timeout(write_op.wait(), timeout_ns, "ns")
                assert axi_resp(write_op) == AxiResp.SLVERR, (
                    f"Maintenance write burst size={size} awlen={awlen} addr=0x{addr:08x}: "
                    f"expected SLVERR, got {axi_resp(write_op)}"
                )
                await assert_status_after_burst(
                    f"write burst size={size} awlen={awlen} bytes={burst_bytes} addr=0x{addr:08x}"
                )
                case_idx += 1

        my_tb.dut._log.info("SLVERR on maintenance high verified across read/write burst matrix")
        await Timer(100, unit="ns")
    finally:
        await write_mram_control_fields(
            regs,
            maintenance_mode=0
        )
        await Timer(1, unit="ns")
