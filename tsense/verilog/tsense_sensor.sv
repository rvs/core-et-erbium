`timescale 1ps/1ps

module tsense_sensor (
  input  logic en,
  output logic hc_tsense_vctat,
  output logic hc_tsense_vref
`ifdef GLS
  ,inout vdd,
  inout vdd18,
  inout vss
`endif
);

  assign hc_tsense_vctat = en ? 1'b1 : 1'bz;
  assign hc_tsense_vref  = en ? 1'b1 : 1'bz;

endmodule
