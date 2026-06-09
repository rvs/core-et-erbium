`timescale 1ps/1ps

module tsense_wrap (
  input  logic       sys_clk,
  input  logic       rst_n,

  // Register interface
  input  logic       conv,          // write 1 to trigger one-shot conversion
  input  logic [2:0] sen_sel,       // [2]=enable, [1:0]=sensor select (0-3)
  input  logic [7:0] clk_div,       // ADC clk freq = sys_clk / (2*(clk_div+1))

  output logic [3:0] data,          // captured ADC output
  output logic       valid,         // data valid
  output logic       conv_b         // ADC conversion-in-progress status (active-low)
);

  // ---------------------------------------------------
  // ADC clock divider
  // ---------------------------------------------------
  logic [7:0] div_cnt;
  logic       adc_clk;

  always_ff @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) begin
      div_cnt <= '0;
      adc_clk <= 1'b0;
    end else begin
      if (div_cnt >= clk_div) begin
        div_cnt <= '0;
        adc_clk <= ~adc_clk;
      end else begin
        div_cnt <= div_cnt + 1'b1;
      end
    end
  end

  // ---------------------------------------------------
  // Sensor instances (tri-state outputs on shared bus)
  // ---------------------------------------------------
  wire hc_tsense_vctat;
  wire hc_tsense_vref;

  logic [3:0] sensor_en;
  assign sensor_en[0] = sen_sel[2] & (sen_sel[1:0] == 2'd0);
  assign sensor_en[1] = sen_sel[2] & (sen_sel[1:0] == 2'd1);
  assign sensor_en[2] = sen_sel[2] & (sen_sel[1:0] == 2'd2);
  assign sensor_en[3] = sen_sel[2] & (sen_sel[1:0] == 2'd3);

  tsense_sensor u_sensor0 (
    .en              (sensor_en[0]),
    .hc_tsense_vctat (hc_tsense_vctat),
    .hc_tsense_vref  (hc_tsense_vref)
  );

  tsense_sensor u_sensor1 (
    .en              (sensor_en[1]),
    .hc_tsense_vctat (hc_tsense_vctat),
    .hc_tsense_vref  (hc_tsense_vref)
  );

  tsense_sensor u_sensor2 (
    .en              (sensor_en[2]),
    .hc_tsense_vctat (hc_tsense_vctat),
    .hc_tsense_vref  (hc_tsense_vref)
  );

  tsense_sensor u_sensor3 (
    .en              (sensor_en[3]),
    .hc_tsense_vctat (hc_tsense_vctat),
    .hc_tsense_vref  (hc_tsense_vref)
  );

  // ---------------------------------------------------
  // ADC instance
  // ---------------------------------------------------
  logic       adc_en;
  logic [3:0] adc_d;
  logic       adc_drdy;
  logic       adc_conv_b;

  tsense_adc u_adc (
    .clk             (adc_clk),
    .en              (adc_en),
    .d               (adc_d),
    .drdy            (adc_drdy),
    .conv_b          (adc_conv_b),
    .hc_tsense_vctat (hc_tsense_vctat),
    .hc_tsense_vref  (hc_tsense_vref)
  );

  assign conv_b = adc_conv_b;

  // ---------------------------------------------------
  // Conversion control (sys_clk domain)
  // ---------------------------------------------------
  logic conv_prev;

  always_ff @(posedge sys_clk or negedge rst_n) begin
    if (!rst_n) begin
      data      <= 4'h0;
      valid     <= 1'b0;
      adc_en    <= 1'b0;
      conv_prev <= 1'b0;
    end else begin
      conv_prev <= conv;

      if (conv && !conv_prev) begin
        valid  <= 1'b0;
        adc_en <= 1'b1;
      end else if (adc_en && adc_drdy) begin
        data   <= adc_d;
        valid  <= 1'b1;
        adc_en <= 1'b0;
      end
    end
  end

endmodule
