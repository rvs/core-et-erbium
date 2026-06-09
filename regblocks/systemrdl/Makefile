HAL_HEADER= ../../tb/c_asm_tests/include/hal_cpu_mm.h
RAL_DIR= ../../tb/ral
RALSTRUCT_DIR= ../../tb/ralstruct
RAL_STAMP= $(RAL_DIR)/.stamp
outputs= ../../doc/cpu_mm.md ../../doc/xspi_mm.md html ../../doc/sfpd.md  ../../doc/sccr.md ../verilog/System_Reg.sv ../verilog/System_Reg_pkg.sv  $(RAL_STAMP)  $(HAL_HEADER)  shakti
RDLs= hyperbus.rdl mram.rdl periph.rdl romram.rdl system.rdl top_cpu_mm.rdl top.rdl top_xspi_mm.rdl ../../ip/xspi/systemrdl/sfdp.rdl  ../../ip/xspi/systemrdl/sccr.rdl
all:$(outputs)
../verilog/System_Reg.sv:system.rdl Makefile
	peakrdl regblock --cpuif axi4-lite-flat --default-reset arst_n system.rdl -o ../verilog
$(RAL_STAMP):$(RDLs) Makefile
	mkdir -p $(RAL_DIR) $(RALSTRUCT_DIR)
	peakrdl python --async -o $(RAL_DIR)/cpu_mm top_cpu_mm.rdl
	peakrdl python --async -o $(RAL_DIR)/xspi_mm top_xspi_mm.rdl
	peakrdl cocotb_ralgen system.rdl -o $(RALSTRUCT_DIR)/ --default_regwidth=64
	peakrdl cocotb_ralgen top_cpu_mm.rdl -o $(RALSTRUCT_DIR)/ --default_regwidth=64
	peakrdl cocotb_ralgen top_xspi_mm.rdl -o $(RALSTRUCT_DIR)/ --default_regwidth=64
	touch $@
$(RAL_DIR):$(RAL_STAMP)
	@touch $@
$(HAL_HEADER):$(RDLs)
	peakrdl c-header -DPEAKRDL_CHEADER -b ltoh --std gnu11 -o $@ top_cpu_mm.rdl
shakti:../../shakti_ip/cocotb/ral/uart ../../shakti_ip/cocotb/ral/qspi
../../shakti_ip/cocotb/ral/uart: uart.rdl
	peakrdl python --async -o ../../shakti_ip/cocotb/ral uart.rdl
../../shakti_ip/cocotb/ral/qspi: qspi.rdl
	peakrdl python --async -o ../../shakti_ip/cocotb/ral qspi.rdl

../../doc/%: $(RDLs) Makefile
	peakrdl markdown top_cpu_mm.rdl  -o ../../doc/cpu_mm.md
	peakrdl markdown top_xspi_mm.rdl  -o ../../doc/xspi_mm.md
	peakrdl markdown  ../../ip/xspi/systemrdl/sfdp.rdl -o ../../doc/sfpd.md
	peakrdl markdown  ../../ip/xspi/systemrdl/sccr.rdl -o ../../doc/sccr.md
	perl -pi -e 's/## ErbiumxSPI_MemoryMap/# ErbiumxSPI_MemoryMap/' ../../doc/xspi_mm.md
	perl -pi -e 's/## ErbiumCPU_MemoryMap/# ErbiumCPU_MemoryMap/' ../../doc/cpu_mm.md
top.rdl:system.rdl hyperbus.rdl
html:
	peakrdl html top_xspi_mm.rdl  -o html
clean::
	rm -rf $(outputs) $(RAL_DIR) $(RALSTRUCT_DIR)
ral:$(RAL_STAMP) $(HAL_HEADER)
.PHONY:all clean test ral
