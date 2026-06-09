# Installation Guide
 Unzip the delivery to get the following folders
* nxp/
	* testbench/  # folder for  cocotb testbench used for simulating the design.  
	* verilog/    # folder for  netlist code that can be integrated in your system.  
	* tsmc_cells/ # folder for  standard cells used in the design  
	* doc/        # folder for this document.   
	* Hyperbus/   # folder for the hyperbus controller used for simulation  
	* lib/        # folder for argon.lib  

To Setup and QC the delivery, perform the following actions  
(*Note* Use either python version 3.10 or higher.)

## Setup the environment 
```
tar -xzvf nxp.tgz
cd nxp
python3.10 -m venv venv
source venv/bin/activate
pip3 install -r testbench/requirements.txt
```

From here on, whenever you open a new shell, run `source venv/bin/activate` from the nxp folder to reuse the environment.

## Run test

```
cd nxp
ARGON2_ROOT=$(pwd) make -C testbench
```
