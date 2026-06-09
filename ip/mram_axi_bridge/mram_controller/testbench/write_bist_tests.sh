#!/bin/sh
srun vcs -sverilog -full64 -R +vcs -q -notice +lint=TFIPC-L +vcs+flush+all +vcs+lic+wait -override_timescale=1ns/1ps bist_tb.sv ../verilog/bist_wrapper.v ../verilog/bist_write.v ../verilog/bist_read.sv ../verilog/bist_mux.v ../ctrl_rte/verilog/ctrl_rte.v ../ctrl_rte/testbench/mram.v ../ctrl_rte/testbench/rom.v +define+RUN_BIST_WRITE +define+START_ADDR=0
