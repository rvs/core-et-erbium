## Application Variable  
set_app_var enable_rdc true  
   
## Methodology and Goal  
# set goal_name "lint_rtl" 
   
## Custom Severity  
   
## Tag and Parameter  
# configure_lint_tag -enable -tag UndrivenNUnloaded-ML -goal $goal_name -severity warning
# configure_lint_tag -enable -tag UnloadedInPort-ML -goal $goal_name -severity warning
# configure_lint_tag -enable -tag UnloadedNet-ML -goal $goal_name -severity warning
# configure_lint_tag -enable -tag UnloadedOutTerm-ML -goal $goal_name -severity warning 
# configure_lint_setup -goal $goal_name 
   
## Design Import  
analyze -format sverilog -vcs {-F ../erbium_digital/verilog/rtl.f ../ERBIUM_DIGITAL_TOP/verilog/ERBIUM_DIGITAL_TOP_16MB.sv} 
set top "ERBIUM_DIGITAL_TOP_16MB" 
elaborate $top -verbose 
   
## Constraint  
read_sdc ERBIUM_DIGITAL_TOP_16MB.sdc
infer_setup -type reset -incremental
write_inferred_setup -type reset -file inferred_reset.sdc
   
## Run RDC Check  
check_rdc -type setup
# check_rdc -type corruption
   
## Waiver File  
   
## Report  
report_rdc
   
## Save Session  
save_session -session "rdc_session" -compression "lz4"    
view_activity
