module cpu_intr_logic(
    input logic         clk,
    input logic         rst_b,

    input logic         disable_i,
    input logic         rst_intr_i,
    input logic         double_bit_error_i,
    input logic         triple_bit_error_i,
    input logic  [3:0]  stripe_sel_i,
    input logic  [17:0] add_i,

    output logic [19:0] error_add_o,
    output logic        cpu_intr_o
);

    logic [3:0]     stripe_sel_d, stripe_sel_q0, stripe_sel_q1;
    logic [17:0]    add_d, add_q0, add_q1;
    logic [19:0]    error_add_d, error_add_q;
    logic [1:0]     stripe_sel_log2;
    logic           cpu_intr_d, cpu_intr_q;

    always_ff @(posedge clk, negedge rst_b) begin
        if (~rst_b) begin
            error_add_q    <= 0;
            cpu_intr_q      <= 0;
            add_q0          <= 0;
            add_q1          <= 0;
            stripe_sel_q0   <= 0;
            stripe_sel_q1   <= 0;
        end else begin
            if (rst_intr_i) begin
                cpu_intr_q      <= 0;
                error_add_q    <= 0;
            end else begin
                cpu_intr_q      <= cpu_intr_d;
                error_add_q    <= error_add_d;
            end
            add_q0          <= add_d;
            add_q1          <= add_q0;
            stripe_sel_q0   <= stripe_sel_d;
            stripe_sel_q1   <= stripe_sel_q0;

        end
    end

    always_comb begin
        error_add_o    = error_add_q;
        cpu_intr_o      = cpu_intr_q;
        add_d           = add_i;
        stripe_sel_d    = stripe_sel_i;
        cpu_intr_d      = cpu_intr_q;
        error_add_d    = error_add_q;

        // 4'b1000 => 2'b11;
        // 4'b0100 => 2'b10;
        // 4'b0010 => 2'b01;
        // 4'b0001 => 2'b00;
        stripe_sel_log2 = stripe_sel_q1[3] == 1 ? 2'b11 :
                          stripe_sel_q1[2] == 1 ? 2'b10 :
                          stripe_sel_q1[1] == 1 ? 2'b01 :
                          stripe_sel_q1[0] == 1 ? 2'b00 :
                          2'b00;
        //stripe_sel_log2 = $clog2(stripe_sel_q1);
        if ((double_bit_error_i | triple_bit_error_i) & ~disable_i) begin
            if (~cpu_intr_q) begin
                // Capture the first error we encounter
                error_add_d    = {add_q1[17], stripe_sel_log2, add_q1[16:0]};
                cpu_intr_d      = 1;
            end else begin
                // Keep our error until it is reset.
                cpu_intr_d      = cpu_intr_q;
                error_add_d    = error_add_q;
            end
        end
    end
endmodule
