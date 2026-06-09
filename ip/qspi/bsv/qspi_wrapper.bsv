package qspi_wrapper;
import qspi::*;
`include "qspi.defines"
import device_common::*;

(*synthesize*)
module qspi_32_64_0#(Clock slow_clock, Reset slow_reset)(Ifc_qspi_axi4lite#(32,64,0) );
	let _tmp <- mkqspi_axi4lite(slow_clock,slow_reset,0,'hffffff);
	return _tmp;
endmodule

endpackage
