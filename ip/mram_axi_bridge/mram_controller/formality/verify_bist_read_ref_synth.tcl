#!/tools/synopsys/fm/U-2022.12/bin/formality -f
read_sverilog -container r -libname WORK { /scratch/argon/mjaggers/git/argon-hdl/controller/verilog/ste.sv }
set_top ste
read_verilog -container i -libname WORK -05 { /scratch/argon/mjaggers/git/argon-hdl/controller/synth/ste_syn.v }
read_db { /pdk/tn16/stdcells/tcbn16ffcllbwp7d5t16p96cpd_170a/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn16ffcllbwp7d5t16p96cpd_100d/tcbn16ffcllbwp7d5t16p96cpdtt1v25c_ccs.db }
set_top ste
match
verify
exit

