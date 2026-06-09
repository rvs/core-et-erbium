## Application Variable  
set_app_var enable_lint true  
   
## Methodology and Goal  
set goal_name "lint_rtl" 
   
## Custom Severity  
   
## Tag and Parameter  
configure_lint_tag -enable -tag UndrivenNUnloaded-ML -goal $goal_name -severity warning
configure_lint_tag -enable -tag UnloadedInPort-ML -goal $goal_name -severity warning
configure_lint_tag -enable -tag UnloadedNet-ML -goal $goal_name -severity warning
configure_lint_tag -enable -tag UnloadedOutTerm-ML -goal $goal_name -severity warning 
configure_lint_setup -goal $goal_name 
   
## Design Import  
analyze -format sverilog -vcs {-F ../erbium_digital/verilog/rtl.f} 
set top "erbium_digital_et_aon" 
elaborate $top -verbose 
   
## Constraint  
   
## Run Lint Check  
check_lint 
   
## Waiver File  
   
## Report  
report_violations  -app { setup design lint } 
   
## Save Session  
save_session -session "my_session" -compression "lz4"    
view_activity
