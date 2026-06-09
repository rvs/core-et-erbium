#!/bin/bash
make TOPLEVEL=axi2mram_wrapper MODULE=mram_axi_wrapper_tbench  VERILOG_SOURCES+="`pwd`/../verilog/axi2mram.v `pwd`/../verilog/mram.v `pwd`/../verilog/axi2mram_wrapper.sv"
