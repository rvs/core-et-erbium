import cocotb
from tb import *


@cocotb.test()
async def generated_bridge_reg_model_smoke(dut):
    """Use the generated async register model to verify bridge register access."""
    if not controller_reg_model_ready(dut):
        return

    my_tb.set_dut(dut)
    my_tb.setup_tb()
    await my_tb.reset_sequence()

    reg_model: TregRegModel = build_treg_reg_model(my_tb.axi_treg_master)

    await reg_model.bridge_regs.arbiter_mode_reg.write_fields(
        arbiter_mode=ARBITER_OLDEST_FIRST
    )
    await Timer(10, unit="ns")

    fields = await reg_model.bridge_regs.arbiter_mode_reg.read_fields()
    assert fields["arbiter_mode"] == ARBITER_OLDEST_FIRST, (
        f"arbiter_mode_reg readback mismatch: {fields['arbiter_mode']}"
    )
    assert sig_int(my_tb.dut.axi2mram_arbiter_mode) == ARBITER_OLDEST_FIRST, (
        f"axi2mram_arbiter_mode hierarchy mismatch: {sig_int(my_tb.dut.axi2mram_arbiter_mode)}"
    )
