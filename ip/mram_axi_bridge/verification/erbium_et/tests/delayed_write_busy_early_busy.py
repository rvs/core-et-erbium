import cocotb
from cocotb.triggers import RisingEdge, Timer, with_timeout
from cocotb.utils import get_sim_time
from cocotbext.axi import AxiResp
from tb import *


def _get_bank_signals(my_tb, bank_idx):
    """Return a namespace with the wrapper-level mram_ce / mram_we / mram_busy
    for a given bank, accessible from cocotb."""
    dut = my_tb.dut

    # Signals are declared in axi2mram_et_wrapper as:
    #   logic [7:0] mram_ce  [NUM_MRAM_BANKS];
    #   logic       mram_we  [NUM_MRAM_BANKS];
    #   logic [7:0] mram_busy[NUM_MRAM_BANKS];
    ce_sig = None
    we_sig = None
    busy_sig = None

    # Try array indexing first (cocotb usually handles this)
    try:
        ce_sig = dut.mram_ce[bank_idx]
        we_sig = dut.mram_we[bank_idx]
        busy_sig = dut.mram_busy[bank_idx]
    except Exception:
        pass

    if ce_sig is None:
        # Fallback: resolve via hierarchical path
        ce_sig = my_tb._resolve_dut_path(f"mram_ce[{bank_idx}]")
        we_sig = my_tb._resolve_dut_path(f"mram_we[{bank_idx}]")
        busy_sig = my_tb._resolve_dut_path(f"mram_busy[{bank_idx}]")

    return SimpleNamespace(ce=ce_sig, we=we_sig, busy=busy_sig)


def _get_mram_instance_signals(my_tb, bank_idx, inst_idx):
    """Return raw behavioral MRAM instance clk/ce/we/busy signals."""
    for bank_model_path in my_tb._bank_model_paths(bank_idx):
        instance_path = f"{bank_model_path}.mram_inst[{inst_idx}].mram_inst"
        clk_sig = my_tb._resolve_dut_path(f"{instance_path}.clk_i")
        ce_sig = my_tb._resolve_dut_path(f"{instance_path}.ce_i")
        we_sig = my_tb._resolve_dut_path(f"{instance_path}.we_i")
        busy_sig = my_tb._resolve_dut_path(f"{instance_path}.busy_o")
        write_busy_sig = my_tb._resolve_dut_path(f"{instance_path}.write_busy")
        delay_sig = my_tb._resolve_dut_path(
            f"{instance_path}.write_busy_rise_delay_ps"
        )
        write_busy_out_sig = my_tb._resolve_dut_path(
            f"{instance_path}.write_busy_out"
        )

        if (
            clk_sig is not None
            and ce_sig is not None
            and we_sig is not None
            and busy_sig is not None
            and write_busy_sig is not None
            and delay_sig is not None
            and write_busy_out_sig is not None
        ):
            return SimpleNamespace(
                clk=clk_sig,
                ce=ce_sig,
                we=we_sig,
                busy=busy_sig,
                write_busy=write_busy_sig,
                write_busy_rise_delay_ps=delay_sig,
                write_busy_out=write_busy_out_sig,
                _path=instance_path,
            )
    return None


def _set_all_mram_write_busy_rise_delays(my_tb, delay_ps):
    """Set every behavioral MRAM instance's VPI-visible delay signal."""
    updated = []
    for bank_idx in range(4):
        for inst_idx in range(8):
            inst_sigs = _get_mram_instance_signals(my_tb, bank_idx, inst_idx)
            if inst_sigs is None:
                continue
            inst_sigs.write_busy_rise_delay_ps.value = int(delay_ps)
            updated.append(inst_sigs._path)

    if len(updated) == 0:
        raise AssertionError(
            "Could not resolve any write_busy_rise_delay_ps handles to set at runtime."
        )
    return updated


def get_sim_time_ps():
    """Return current simulation time in picoseconds.

    get_sim_time() with unit='ps' returns the current time in picoseconds
    as a floating point value.
    """
    return int(get_sim_time(unit="ps"))


def get_write_busy_rise_delay_sweep_ps():
    """Return write-busy rise delays to exercise in this simulation."""
    sweep = cocotb.plusargs.get("mram_write_busy_rise_delay_sweep_ps", None)
    if sweep not in (None, True):
        return [int(item, 0) for item in str(sweep).split(",") if item.strip()]

    value = cocotb.plusargs.get("mram_write_busy_rise_delay_ps", "0")
    if value is True:
        value = 0
    configured_delay_ps = int(str(value), 0)

    delays = [0, 800]
    if configured_delay_ps not in delays:
        delays.append(configured_delay_ps)
    return delays


def _same_instance_addr(base_addr, word_idx):
    return base_addr + word_idx * 0x100


@cocotb.test()
async def delayed_write_busy_early_busy(dut):
    """Regression for delayed MRAM write-busy rise with early busy protection.

    Proves that writes to the same MRAM instance still complete correctly even
    when the behavioral MRAM busy signal has either no added delay or rises
    more than 0.6 ns after write launch.  The MramBankTranslator early-busy latch
    (launched_write_mask -> write_busy_buf) prevents same-instance write
    hazards before the real MRAM busy signal is sampled.

    Expected regression runs:
        +mram_write_busy_rise_delay_sweep_ps=0,800
    """
    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()
    seed_rng(42)
    delay_sweep_ps = get_write_busy_rise_delay_sweep_ps()

    # Initialize a clean region
    my_tb.initialize_memory_region(0, 64 * 1024, value=0)
    axi_master = my_tb.axi_master

    my_tb.dut._log.info(
        "=== Delayed write-busy early-busy regression "
        f"(runtime delay sweep ps={delay_sweep_ps}) ==="
    )

    # ----------------------------------------------------------------
    # Drive the model's VPI-visible write_busy_rise_delay_ps signal at runtime
    # and then observe the actual write_busy_out/busy_o edge produced by the
    # MRAM model logic.  The timing reference is the model's internal
    # write_busy rise, not ce_i/we_i, because ce_i/we_i can become visible just
    # after the clock edge and then be consumed by the model on the next edge.
    # ----------------------------------------------------------------
    bank_idx = 0
    # Address 0x000 maps to bank 0, instance pair 0.
    # Instance 0 serves bytes 0-7 of the 16-byte bank word.
    inst_idx = 0

    sigs = _get_bank_signals(my_tb, bank_idx)
    if sigs.ce is None or sigs.we is None or sigs.busy is None:
        raise AssertionError(
            "Could not resolve mram_ce/we/busy signals; cannot prove delayed busy was exercised."
        )

    inst_sigs = _get_mram_instance_signals(my_tb, bank_idx, inst_idx)
    if inst_sigs is None:
        raise AssertionError(
            "Could not resolve raw MRAM instance clk/ce/we/write_busy/write_busy_out/delay signals; "
            "cannot prove runtime delayed busy timing was exercised."
        )
    my_tb.dut._log.info(f"  Monitoring raw MRAM instance at {inst_sigs._path}")

    # ----------------------------------------------------------------
    # Helper: issue an 8-byte write and return when BRESP is OKAY.
    # ----------------------------------------------------------------
    async def write8(addr, data, timeout_ns=5000):
        """Write 8 bytes and verify OKAY response."""
        op = axi_master.init_write(addr, bytes(data), size=3)  # size=3 -> 8B
        result = await with_timeout(op.wait(), timeout_ns, "ns")
        resp = axi_event_result(op).resp
        assert resp == AxiResp.OKAY, (
            f"Write to 0x{addr:06x} returned resp={resp}, expected OKAY"
        )
        return result

    # ----------------------------------------------------------------
    # Helper: read 8 bytes and return data.
    # ----------------------------------------------------------------
    async def read8(addr, timeout_ns=5000):
        op = axi_master.init_read(addr, 8, size=3)
        await with_timeout(op.wait(), timeout_ns, "ns")
        return axi_data(op)

    async def measure_one_write_delay(monitor_addr, monitor_data, expected_delay_ps):
        """Write once and measure runtime-configured MRAM busy rise delay."""
        launch_times = []
        inst_busy_rise_times = []
        busy_rise_times = []

        async def record_busy_timing():
            """Record the time from internal write_busy rise to visible busy rise."""
            nonlocal launch_times, inst_busy_rise_times, busy_rise_times

            while int(inst_sigs.write_busy.value) or int(inst_sigs.write_busy_out.value):
                await Timer(10, unit="ps")

            while len(launch_times) == 0:
                await Timer(10, unit="ps")
                if int(inst_sigs.write_busy.value):
                    launch_times.append(get_sim_time_ps())
                    if int(inst_sigs.write_busy_out.value):
                        inst_busy_rise_times.append(get_sim_time_ps())

            while len(inst_busy_rise_times) == 0 or len(busy_rise_times) == 0:
                await Timer(10, unit="ps")
                if len(inst_busy_rise_times) == 0 and int(inst_sigs.write_busy_out.value):
                    inst_busy_rise_times.append(get_sim_time_ps())
                busy_val = int(sigs.busy.value)
                if len(busy_rise_times) == 0 and ((busy_val >> inst_idx) & 1):
                    busy_rise_times.append(get_sim_time_ps())

        cocotb.start_soon(record_busy_timing())
        await Timer(100, unit="ps")
        await write8(monitor_addr, monitor_data, timeout_ns=5000)
        await Timer(2000, unit="ns")

        if (
            len(launch_times) == 0
            or len(inst_busy_rise_times) == 0
            or len(busy_rise_times) == 0
        ):
            raise AssertionError(
                "Could not capture launch/busy timing; "
                f"launch_times={launch_times}, "
                f"inst_busy_rise_times={inst_busy_rise_times}, "
                f"busy_rise_times={busy_rise_times}"
            )

        launch_time_ps = launch_times[0]
        inst_delay_ps = inst_busy_rise_times[0] - launch_time_ps
        wrapper_delay_ps = busy_rise_times[0] - launch_time_ps
        my_tb.dut._log.info(
            f"  Measured raw MRAM busy rise delay: {inst_delay_ps} ps "
            f"(expected {expected_delay_ps} ps, launch at {launch_time_ps} ps, "
            f"raw busy rise at {inst_busy_rise_times[0]} ps)"
        )
        my_tb.dut._log.info(
            f"  Measured wrapper mram_busy rise delay: {wrapper_delay_ps} ps "
            f"(wrapper busy rise at {busy_rise_times[0]} ps)"
        )

        delay_tolerance_ps = 75
        delay_error_ps = abs(inst_delay_ps - expected_delay_ps)
        assert delay_error_ps <= delay_tolerance_ps, (
            f"Expected MRAM model write_busy_out rise delay near runtime setting "
            f"{expected_delay_ps} ps; measured {inst_delay_ps} ps "
            f"(error {delay_error_ps} ps, tolerance {delay_tolerance_ps} ps). "
            f"Wrapper-level mram_busy delay from the same instance launch was "
            f"{wrapper_delay_ps} ps."
        )
        if expected_delay_ps > 600:
            assert inst_delay_ps > 600, (
                f"Expected raw MRAM busy rise delay > 600 ps; measured {inst_delay_ps} ps."
            )

    async def run_delay_scenario(delay_ps, scenario_idx):
        """Set delay at runtime, then prove write correctness and delay timing."""
        my_tb.dut._log.info(
            f"=== Runtime model write-busy delay scenario: {delay_ps} ps ==="
        )
        updated_paths = _set_all_mram_write_busy_rise_delays(my_tb, delay_ps)
        my_tb.dut._log.info(
            f"  Set write_busy_rise_delay_ps={delay_ps} on "
            f"{len(updated_paths)} MRAM instances"
        )
        await Timer(100, unit="ps")
        scenario_base = 0x1000 + scenario_idx * 0x2000

        my_tb.dut._log.info("--- Case 1: Two writes to same address ---")
        addr1 = _same_instance_addr(scenario_base, 0)
        data1a = bytearray([0xA0 + scenario_idx] * 8)
        data1b = bytearray([0xB0 + scenario_idx] * 8)

        await write8(addr1, data1a)
        await write8(addr1, data1b)
        result1 = await read8(addr1)
        assert result1 == bytes(data1b), (
            f"Case 1 failed delay={delay_ps}: expected {data1b.hex()}, got {result1.hex()}"
        )
        mismatches = my_tb.verify_mram_contents(addr1, data1b)
        assert len(mismatches) == 0, f"Case 1 MRAM mismatch: {mismatches[0]}"
        my_tb.dut._log.info("  Case 1 PASSED: same-address overwrite correct")

        my_tb.dut._log.info("--- Case 2: Different addresses, same instance ---")
        addr2a = _same_instance_addr(scenario_base, 1)
        addr2b = _same_instance_addr(scenario_base, 2)
        data2a = bytearray([0x20 + scenario_idx, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27])
        data2b = bytearray([0x40 + scenario_idx, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47])

        await write8(addr2a, data2a)
        await write8(addr2b, data2b)
        r2a = await read8(addr2a)
        r2b = await read8(addr2b)
        assert r2a == bytes(data2a), (
            f"Case 2a failed delay={delay_ps}: expected {data2a.hex()}, got {r2a.hex()}"
        )
        assert r2b == bytes(data2b), (
            f"Case 2b failed delay={delay_ps}: expected {data2b.hex()}, got {r2b.hex()}"
        )
        mismatches = my_tb.verify_mram_contents(addr2a, data2a)
        assert len(mismatches) == 0, f"Case 2a MRAM mismatch: {mismatches[0]}"
        mismatches = my_tb.verify_mram_contents(addr2b, data2b)
        assert len(mismatches) == 0, f"Case 2b MRAM mismatch: {mismatches[0]}"
        my_tb.dut._log.info("  Case 2 PASSED: same-instance different-address correct")

        my_tb.dut._log.info("--- Case 3: Full write + partial RMW ---")
        addr3 = _same_instance_addr(scenario_base, 3)
        data3_full = bytearray([0x10 + scenario_idx, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17])
        data3_patch = bytearray([0xFF, 0xFE])

        await write8(addr3, data3_full)
        op = axi_master.init_write(addr3 + 2, bytes(data3_patch), size=1)
        await with_timeout(op.wait(), 5000, "ns")
        result3 = await read8(addr3)
        expected3 = bytearray(data3_full)
        expected3[2] = 0xFF
        expected3[3] = 0xFE
        assert result3 == bytes(expected3), (
            f"Case 3 failed delay={delay_ps}: expected {expected3.hex()}, got {result3.hex()}"
        )
        mismatches = my_tb.verify_mram_contents(addr3, expected3)
        assert len(mismatches) == 0, f"Case 3 MRAM mismatch: {mismatches[0]}"
        my_tb.dut._log.info("  Case 3 PASSED: RMW partial write correct")

        my_tb.dut._log.info("--- Case 4: Burst of same-instance writes ---")
        burst_count = 8
        burst_data = {}
        for i in range(burst_count):
            addr = _same_instance_addr(scenario_base, 4 + i)
            data = bytearray([0x50 + scenario_idx + i] * 8)
            await write8(addr, data, timeout_ns=5000)
            burst_data[addr] = bytes(data)

        for addr, expected in burst_data.items():
            result = await read8(addr, timeout_ns=5000)
            assert result == expected, (
                f"Case 4 burst read delay={delay_ps} at 0x{addr:06x}: "
                f"expected {expected.hex()}, got {result.hex()}"
            )
        first_addr = _same_instance_addr(scenario_base, 4)
        last_addr = _same_instance_addr(scenario_base, 4 + burst_count - 1)
        mismatches = my_tb.verify_mram_contents(first_addr, burst_data[first_addr])
        assert len(mismatches) == 0, f"Case 4 first MRAM mismatch: {mismatches[0]}"
        mismatches = my_tb.verify_mram_contents(last_addr, burst_data[last_addr])
        assert len(mismatches) == 0, f"Case 4 last MRAM mismatch: {mismatches[0]}"
        my_tb.dut._log.info("  Case 4 PASSED: burst same-instance writes correct")

        my_tb.dut._log.info("--- Case 5: Rapid same-address writes ---")
        addr5 = _same_instance_addr(scenario_base, 12)
        write_values = [bytearray([0x70 + scenario_idx + i] * 8) for i in range(4)]
        write_ops = []
        for data in write_values:
            write_ops.append(axi_master.init_write(addr5, bytes(data), size=3))

        for op in write_ops:
            await with_timeout(op.wait(), 5000, "ns")
            assert axi_resp(op) == AxiResp.OKAY, (
                f"Case 5 write returned resp={axi_resp(op)}, expected OKAY"
            )

        result5 = await read8(addr5)
        assert result5 == bytes(write_values[-1]), (
            f"Case 5 failed delay={delay_ps}: expected {write_values[-1].hex()}, got {result5.hex()}"
        )
        mismatches = my_tb.verify_mram_contents(addr5, write_values[-1])
        assert len(mismatches) == 0, f"Case 5 MRAM mismatch: {mismatches[0]}"
        my_tb.dut._log.info("  Case 5 PASSED: rapid same-address writes correct")

        my_tb.dut._log.info("--- Monitoring runtime busy rise delay ---")
        monitor_addr = _same_instance_addr(scenario_base, 13)
        monitor_data = bytearray([0xD0 + scenario_idx, 0xAD, 0xBE, 0xEF] * 2)
        await measure_one_write_delay(monitor_addr, monitor_data, delay_ps)
        my_tb.dut._log.info(
            f"  CONFIRMED: model busy rise delay {delay_ps} ps exercised correctly"
        )

    for scenario_idx, delay_ps in enumerate(delay_sweep_ps):
        await run_delay_scenario(delay_ps, scenario_idx)

    my_tb.dut._log.info("=== All delayed write-busy early-busy tests passed ===")
    await Timer(1000, unit="ns")
