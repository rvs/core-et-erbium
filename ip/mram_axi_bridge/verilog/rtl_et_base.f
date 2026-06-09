+incdir+../mram_controller/verilog/
${BSC_VLIB_ET}/RevertReg.v
${BSC_VLIB_ET}/SizedFIFO.v
${BSC_VLIB_ET}/SizedFIFO.v
${BSC_VLIB_ET}/GatedClock.v
${BSC_VLIB_ET}/MakeReset0.v

../regblocks/verilog/axi2mram_bridge_registers_pkg.sv
../regblocks/verilog/axi2mram_bridge_registers.sv
../mram_controller/regblocks/verilog/controller_regs_pkg.sv
../mram_controller/regblocks/verilog/controller_regs.sv
../verilog/mkMramBankTranslator.v
../verilog/MramBusyNegedgeReg.v
../verilog/mkAxi2Mram.v
../verilog/axi2mram_et_wrapper.sv

../mram_controller/verilog/erbium_et_bank_wrapper.sv
../mram_controller/verilog/et_ctrl_wrapper.sv
../mram_controller/verilog/et_ctrl_top.sv
../mram_controller/verilog/ctrl_cnfg_ovr_logic.v
../mram_controller/verilog/clk_gate_lvt.v
../mram_controller/verilog/et_cpu_intr_logic.sv
../mram_controller/verilog/et_bwe_convert.v
../mram_controller/verilog/test_regs.v
../mram_controller/verilog/et_ctrl_mux.v
../mram_controller/verilog/et_bist_wrapper.v
../mram_controller/verilog/et_bist_mux.v
../mram_controller/verilog/mkBistEtMramTranslator.v
../mram_controller/verilog/mkEtBist.v
../mram_controller/verilog/FIFO2.v
../mram_controller/verilog/Counter.v
../mram_controller/verilog/ecc_rom_wrapper.sv
../mram_controller/verilog/rom_16kb_top.v
../mram_controller/verilog/boot_sequencer.sv
../mram_controller/verilog/et_bch_encoder.sv
// ../mram_controller/verilog/et_bch_decoder.sv
../mram_controller/verilog/et_pipeline_bch_decode.sv
../mram_controller/verilog/et_ecc_wrapper.sv
../mram_controller/verilog/ref_ecc_encoder.sv
../mram_controller/verilog/ref_ecc_repair.sv
../mram_controller/verilog/hamming_encoder.sv
../mram_controller/verilog/hamming_corrector.sv
-y ../mram_controller/verilog/
