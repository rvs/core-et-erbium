#!/tools/synopsys/syn/T-2022.03-SP3/linux64/syn/bin/dc_shell -f
# https://spdocs.synopsys.com/dow_retrieve/latest/dg/dcolh/Default.htm#dcug/dcug/working_with_design_compiler/synthesis_flow.htm%3FTocPath%3DDesign%2520Compiler%2520Documents%7CDesign%2520Compiler%2520User%2520Guide%252C%2520version%2520T-2022.03-SP3%7CWorking%2520With%2520Design%2520Compiler%7C_____2
# Read the TSMC stdcell library. TT, 25C, Nominal Voltage.
# First, we need to setup the search path
set_app_var search_path {. /tools/synopsys/syn/T-2022.03-SP3/libraries/syn /tools/synopsys/syn/T-2022.03-SP3/dw/syn_ver /tools/synopsys/syn/T-2022.03-SP3/dw/sim_ver /pdk/tn16/stdcells/tcbn16ffcllbwp7d5t16p96cpd_170a/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn16ffcllbwp7d5t16p96cpd_100d/ ../verilog/}
set_app_var target_library tcbn16ffcllbwp7d5t16p96cpdtt0p8v25c_ccs.db
set_app_var link_path { * tcbn16ffcllbwp7d5t16p96cpdtt0p8v25c_ccs.db }
#read_lib /pdk/tn16/stdcells/tcbn16ffcllbwp7d5t16p96cpd_170a/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn16ffcllbwp7d5t16p96cpd_100d/tcbn16ffcllbwp7d5t16p96cpdtt0p8v25c_ccs.lib
#read_file /pdk/tn16/stdcells/tcbn16ffcllbwp7d5t16p96cpd_170a/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn16ffcllbwp7d5t16p96cpd_100d/tcbn16ffcllbwp7d5t16p96cpdtt0p8v25c_ccs.db
define_design_lib WORK -path "./dsgnwork"

# Reading in the relevant files need to synthesize the design.
analyze -format sverilog -library WORK { ../verilog/bist_mux.v ../verilog/ctrl_cnfg_ovr_logic.v ../verilog/bist_read.sv ../verilog/cpu_intr_logic.sv ../verilog/bist_rte.sv ../verilog/bist_wrapper.v ../verilog/bist_write.v ../verilog/bwe_convert.v ../verilog/clk_gate.v ../verilog/ctrl_mux.v ../verilog/ctrl_wrapper.sv ../verilog/ecc_rom_wrapper.sv ../verilog/rom_instance_flat.v ../verilog/mram_wrapper.sv ../verilog/ste.sv ../verilog/test_regs.v ecc_wrapper.sv}
elaborate mram_wrapper -library WORK -update
link
create_clock "clk" -period 3  -waveform {0.0 1.5}

# Synthesize the design.
compile
compile_ultra
# Get the total number of gates inside the design and sub-hierarchy
#report_reference
#report_reference -nosplit -hierarchy
write -hierarchy -format verilog -output axi2mram_wrapper_syn.v
report_area
# Quit out of the tool
quit
