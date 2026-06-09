####################################
# Helper Functions
####################################

# Define a procedure to read file lines into a list
####################################
# Setting up Paths and environment #
####################################
set CORNER tt0p8v25c
set SYN_VER latest
set TOP_DESIGN mkxspi
set IOCELL_CORNER_MAP [dict create ffgnp0p88v0c ffgnp0p88v1p98v0c ffgnp0p88v125c ffgnp0p88v1p98v125c ffgnp0p88vm40c ffgnp0p88v1p98vm40c ssgnp0p72v0c ssgnp0p72v1p62v0c ssgnp0p72v125c ssgnp0p72v1p62v125c ssgnp0p72vm40c ssgnp0p72v1p62vm40c tt0p8v25c tt0p8v1p8v25c tt0p8v85c tt0p8v1p8v85c]
set IOCELL_CORNER [dict get $IOCELL_CORNER_MAP $CORNER]

define_design_lib WORK -path "./dsgnwork"
set_app_var search_path {
    . 
    /tools/synopsys/syn/${SYN_VER}/libraries/syn 
    /tools/synopsys/syn/${SYN_VER}/dw/syn_ver 
    /tools/synopsys/syn/${SYN_VER}/dw/sim_ver 
    /pdk/tn16/stdcells/tcbn16ffcllbwp7d5t16p96cpd_170a/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn16ffcllbwp7d5t16p96cpd_100d/ 
    /pdk/tn16/iocells/tphn16ffcllgv18e_170c/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tphn16ffcllgv18e_cdm5a_170a/ 
    /pdk/tn16/iocells/tphn16ffcllgv18e_170c/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tphn16ffcllgv18e_110i/
}


set_app_var target_library [list \
    tcbn16ffcllbwp7d5t16p96cpdtt0p8v25c_ccs.db \
    tphn16ffcllgv18e_cdm5a${IOCELL_CORNER}.db \
    tphn16ffcllgv18e${IOCELL_CORNER}.db \
]
set_app_var link_path [list \
    * \
    tcbn16ffcllbwp7d5t16p96cpdtt0p8v25c_ccs.db \
    tphn16ffcllgv18e_cdm5a${IOCELL_CORNER}.db \
    tphn16ffcllgv18e${IOCELL_CORNER}.db \
]

# Enable GHM flow
set_app_var hdlin_enable_hier_map true
# set_clock_gating_style -sequential_cell latch -positive_edge_logic {integrated} -negative_edge_logic {integrated} -control_point before -minimum_bitwidth 1 -max_fanout 8
########################################
# Setting search path to Design Blocks #
########################################
# lappend search_path /pdk/tn16/ip/Veevx/argon-ip-deliverables/db/BANK/db/

###############################################
# Setting up and reading in the verilog files #
###############################################
set dc_allow_rtl_pg true
# Use this variable to set the modules that you want to blackbox during verilog reading  e.g. "MODULE1 MODULE2 ..."
#set_app_var hdlin_sv_blackbox_modules ""
analyze -format sverilog -vcs "rtl.f"
# Use this variable to set the modules that you want to blackbox during elaboration e.g. "MODULE1 MODULE2 ..."
#set_app_var hdlin_elaborate_black_box ""

#####################
# Elaboration Phase #
#####################
elaborate $TOP_DESIGN

######################
# Timing Constraints #
######################
#read_sdc ${script_dir}/design_constraints.sdc
source design_constraints.sdc
#################
# Design Checks #
#################
current_design  $TOP_DESIGN
set_verification_top
check_design -unmapped {LINT-61} > reports/unmapped.rpt
check_design > reports/check_design
link > reports/link.rpt

#############
# Synthesis #
#############
current_design  $TOP_DESIGN
#compile  -map_effort high -area_effort high -gate_clock > reports/compile.rpt
#compile_ultra -no_autoungroup -gate_clock > reports/compile_ultra.rpt
compile  -map_effort high -area_effort high  > reports/compile.rpt
compile_ultra -no_autoungroup  > reports/compile_ultra.rpt

#################
# Final Reports #
#################
change_name -hierarchy -rules verilog
report_reference
report_reference -nosplit -hierarchy > reports/reference.rpt
write -hierarchy -format verilog -output carbon_digital_synth.v
write -hierarchy -format ddc -output carbon_digital_synth.ddc
report_area -hierarchy > reports/area.rpt
write_sdc pnr_constraints.sdc
return
exit

