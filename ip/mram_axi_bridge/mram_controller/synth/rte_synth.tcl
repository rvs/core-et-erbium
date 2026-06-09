#!/tools/synopsys/syn/T-2022.03-SP3/linux64/syn/bin/dc_shell -f
# https://spdocs.synopsys.com/dow_retrieve/latest/dg/dcolh/Default.htm#dcug/dcug/working_with_design_compiler/synthesis_flow.htm%3FTocPath%3DDesign%2520Compiler%2520Documents%7CDesign%2520Compiler%2520User%2520Guide%252C%2520version%2520T-2022.03-SP3%7CWorking%2520With%2520Design%2520Compiler%7C_____2
# Read the TSMC stdcell library. TT, 25C, Nominal Voltage.
# First, we need to setup the search path
set_app_var search_path {. /tools/synopsys/syn/T-2022.03-SP3/libraries/syn /tools/synopsys/syn/T-2022.03-SP3/dw/syn_ver /tools/synopsys/syn/T-2022.03-SP3/dw/sim_ver /pdk/tn16/stdcells/tcbn16ffcllbwp7d5t16p96cpd_170a/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn16ffcllbwp7d5t16p96cpd_100d/}
set_app_var target_library tcbn16ffcllbwp7d5t16p96cpdtt0p8v25c_ccs.db
set_app_var link_path { * tcbn16ffcllbwp7d5t16p96cpdtt0p8v25c_ccs.db }
#read_lib /pdk/tn16/stdcells/tcbn16ffcllbwp7d5t16p96cpd_170a/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn16ffcllbwp7d5t16p96cpd_100d/tcbn16ffcllbwp7d5t16p96cpdtt0p8v25c_ccs.lib
#read_file /pdk/tn16/stdcells/tcbn16ffcllbwp7d5t16p96cpd_170a/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn16ffcllbwp7d5t16p96cpd_100d/tcbn16ffcllbwp7d5t16p96cpdtt0p8v25c_ccs.db

# Reading in the relevant files need to synthesize the design.
analyze -format sverilog -library WORK {../verilog/bist_rte.sv}
elaborate ctrl_rte -library WORK -update
#link
create_clock "clk_i" -period 12  -waveform {0.0 6.0}

# Synthesize the design.
compile

# Get the total number of gates inside the design and sub-hierarchy
report_reference
report_reference -nosplit -hierarchy
write -hierarchy -format verilog -output bist_rte_syn.v
report_area
# Quit out of the tool
#quit
