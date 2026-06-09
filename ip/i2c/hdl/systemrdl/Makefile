#
# Copyright: Copyright (c) 2026 Ainekko, Co. All rights reserved.
# Author: Vijayvithal <jvs@nekko.ai>
# Created on: 2026-02-04
# Description: A brief description of the file's purpose.
#
#
i2c:
	peakrdl regblock --cpuif apb4-flat --default-reset arst_n i2c.rdl -o ../verilog
rdl:
	peakrdl python --async -o ../../cocotb/ral i2c.rdl
