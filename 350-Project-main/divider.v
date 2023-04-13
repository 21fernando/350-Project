module divider(
    input[31:0] data_operandA,
    input[31:0] data_operandB,
    input ctrl_DIV, 
    input clock,
    input started,
	output[31:0] data_result,
    output data_exception, 
    output div_ready,
    output div_running
);
    //Counter
    wire [5:0]cycle_count;
    counter_32 counter(
        .clk(clock),
        .en(1'b1),
        .rst(ctrl_DIV),
        .count(cycle_count)
    );

    wire div_almost_ready, div_load_results_reg;
    and div_ready_and(div_almost_ready, cycle_count[5], cycle_count[0], div_running);

    dffe_ref dff_div(
        .d(ctrl_DIV), 
        .q(div_load_results_reg), 
        .clk(clock), 
        .en(1'b1), 
        .clr(1'b0)
    );

    dffe_ref div_ready_dff(
        .d(div_almost_ready), 
        .q(div_ready), 
        .clk(clock), 
        .en(1'b1), 
        .clr(1'b0)
    );

    tffe div_running_tff(
        .clk(clock),
        .T(ctrl_DIV | div_ready),
        .clr(1'b0),
        .Q(div_running), 
        .Q_not()
    );

    wire [31:0] divisor, dividend, positive_divisor, positive_dividend, positive_divisor_in, positive_dividend_in, divisor_comp, dividend_comp;

    reg_32 divisor_reg(
        .d((div_running) ? divisor : data_operandB), 
        .clk(clock), 
        .en(1'b1), 
        .clr(1'b0), 
        .q(divisor)
    );

    reg_32 dividend_reg(
        .d((div_running) ? dividend : data_operandA), 
        .clk(clock), 
        .en(1'b1), 
        .clr(1'b0), 
        .q(dividend)
    );

    reg_32 positive_divisor_reg(
        .d(positive_divisor_in), 
        .clk(clock), 
        .en(1'b1), 
        .clr(ctrl_DIV), 
        .q(positive_divisor)
    );

    reg_32 positive_dividend_reg(
        .d(positive_dividend_in), 
        .clk(clock), 
        .en(1'b1), 
        .clr(ctrl_DIV), 
        .q(positive_dividend)
    );

    //Take the Twos complement of the divisor
    twos_complement twos_complement_a(
        .a(divisor),
        .comp_a(divisor_comp)
    );
    //Pick the positive or negative value of the divisor
    mux_2 divisor_sign(
        .out(positive_divisor_in), 
        .in0(divisor),
        .in1(divisor_comp), 
        .select(divisor[31])
    );

    //Take the Twos complement of the divisor
    twos_complement twos_complement_b(
        .a(dividend),
        .comp_a(dividend_comp)
    );
    //Pick the positive or negative value of the divisor
    mux_2 dividend_sign(
        .out(positive_dividend_in), 
        .in0(dividend),
        .in1(dividend_comp), 
        .select(dividend[31])
    );

    wire [31:0] div_CLA_in_A, div_CLA_in_B, div_CLA_and, div_CLA_or, div_CLA_sum, signed_divisor;
    wire div_add_sub, div_CLA_cout; 

    And_32 div_gen(
        .A(div_CLA_in_A),
        .B(div_CLA_in_B),
        .out(div_CLA_and)
    );

    Or_32 div_prop(
        .A(div_CLA_in_A),
        .B(div_CLA_in_B),
        .out(div_CLA_or)
    );

    CLA_32 div_adder(
        .A(div_CLA_in_A), 
        .B(div_CLA_in_B), 
        .Cin(div_add_sub),
        .A_and_B(div_CLA_and), 
        .A_or_B(div_CLA_or),
        .Cout(div_CLA_cout), 
        .S(div_CLA_sum)
    );
    
    genvar i;
    generate
        for(i=0; i<32;i=i+1)begin
            xor div_xor(signed_divisor[i], positive_divisor_in[i], div_add_sub);
        end
    endgenerate

    wire [63:0] aq_reg_in, aq_reg_out;
    wire [31:0] a_part_out_shifted, q_part_out_shifted, q_part_out, a_part_out, a_part_in, q_part_in;
    reg_64 aq_reg(
        .d(aq_reg_in), 
        .clk(clock), 
        .en(1'b1), 
        .clr(ctrl_DIV),
        .q(aq_reg_out)
    );

    wire dont_need_last_correction;
    assign dont_need_last_correction = div_almost_ready & ~a_part_out_shifted[31];

    assign a_part_out_shifted = aq_reg_out[62:31];
    assign q_part_out_shifted = {aq_reg_out[30:0],1'b0};
    assign q_part_out = aq_reg_out[31:0];
    assign a_part_out = aq_reg_out[63:32];
    assign a_part_in = aq_reg_in[63:32];
    assign q_part_in = aq_reg_in[31:0];

    assign div_CLA_in_A = a_part_out_shifted;
    assign div_CLA_in_B = signed_divisor;
    assign aq_reg_in[63:32] = div_load_results_reg ? 32'd0 : 
        (dont_need_last_correction)? aq_reg_out[63:32] : div_CLA_sum;
    assign aq_reg_in[31:0] = div_load_results_reg ? positive_dividend_in : 
        div_almost_ready? aq_reg_out[31:0] :{q_part_out_shifted[31:1], ~a_part_in[31]};

    wire [31:0] comp_q_part_out;
    twos_complement twos_complement_out(
        .a(q_part_out),
        .comp_a(comp_q_part_out)
    );
    wire sign_right;
    xnor xnor1(sign_right, dividend[31], divisor[31]) ;
    assign data_result = (data_exception) ? 32'b0 : 
        (sign_right) ? q_part_out : comp_q_part_out;
    assign div_add_sub = div_almost_ready? 1'b0 : ~a_part_out_shifted[31];
    assign data_exception = ~|divisor;

endmodule