module multiplier(
    input[31:0] data_operandA,
    input[31:0] data_operandB,
    input ctrl_MULT, 
    input clock,
	output[31:0] data_result,
    output data_exception, 
    output mult_ready,
    output mult_running
);
    //Counter
    wire [5:0]cycle_count;
    counter_32 counter(
        .clk(clock),
        .en(1'b1),
        .rst(ctrl_MULT),
        .count(cycle_count)
    );
    and mult_ready_and(mult_ready, cycle_count[5], cycle_count[0], mult_running);

    tffe mult_running_tff(
        .clk(clock),
        .T(ctrl_MULT | mult_ready),
        .clr(1'b0),
        .Q(mult_running), 
        .Q_not()
    );

    //Add 1 clock delay before starting so all values are settled
    wire load_results_reg;
    
    dffe_ref dff_mult(
        .d(ctrl_MULT), 
        .q(load_results_reg), 
        .clk(clock), 
        .en(1'b1), 
        .clr(1'b0)
    );

    
    //===============
    //Booths Hardware
    //===============
    wire [31:0] multiplicand, multiplier;
    wire [31:0] signed_multiplicand;
    wire [64:0] results_reg_in, results_reg_out;
    wire [31:0] CLA_in_A, CLA_in_B, cla_and, cla_or, CLA_sum;
    wire add_sub;

    reg_32 multiplicand_reg(
        .d((mult_running) ? multiplicand : data_operandA), 
        .clk(clock), 
        .en(1'b1), 
        .clr(1'b0), 
        .q(multiplicand)
    );

    reg_32 multiplier_reg(
        .d((mult_running) ? multiplier : data_operandB), 
        .clk(clock), 
        .en(1'b1), 
        .clr(1'b0), 
        .q(multiplier)
    );

    reg_65 result(
        .d(results_reg_in), 
        .clk(clock), 
        .en(1'b1), 
        .clr(ctrl_MULT), 
        .q(results_reg_out)
    );

    And_32 gen(
        .A(CLA_in_A),
        .B(CLA_in_B),
        .out(cla_and)
    );

    Or_32 prop(
        .A(CLA_in_A),
        .B(CLA_in_B),
        .out(cla_or)
    );

    CLA_32 adder(
        .A(CLA_in_A), 
        .B(CLA_in_B), 
        .Cin(add_sub),
        .A_and_B(cla_and), 
        .A_or_B(cla_or),
        .Cout(CLA_cout), 
        .S(CLA_sum)
    );


    //=================
    // Booths Algorithm
    //==================
    wire do_something;
    wire [31:0] shifted_sum;
    assign data_result = results_reg_out[32:1];
    //CLA does A-B
    assign CLA_in_A = results_reg_out[64:33];
    assign CLA_in_B = do_something ? signed_multiplicand : 32'd0;
    //Ask about this syntax
    assign results_reg_in = load_results_reg? {32'd0,multiplier,1'b0}:
        do_something? {CLA_sum[31], CLA_sum, results_reg_out[32:1]}: {results_reg_out[64], results_reg_out[64:1]};

    genvar i;
    generate
        for(i=0; i<32; i=i+1)begin
            xor xor_d(signed_multiplicand[i], multiplicand[i], add_sub);
        end
    endgenerate
    xor xor_1(do_something, results_reg_out[1], results_reg_out[0]);
    assign add_sub = results_reg_out[1];
    //========
    //Overflow
    //========

    wire ovf_1, ovf_2, ovf_3;
    wire [30:0] sign_diff;
    //Case 1: When there is a significant bit in the top half
    generate
        for(i=0; i<31; i=i+1)begin
            xor(sign_diff[i], results_reg_out[64], results_reg_out[i+33]);
        end
    endgenerate
    or or_ovf_1(ovf_1, sign_diff[0], sign_diff[1], sign_diff[2], sign_diff[3], sign_diff[4], sign_diff[5], sign_diff[6], sign_diff[7], sign_diff[8], sign_diff[9],sign_diff[10], sign_diff[11], sign_diff[12], sign_diff[13], sign_diff[14], sign_diff[15], sign_diff[16], sign_diff[17], sign_diff[18], sign_diff[19], sign_diff[20], sign_diff[21], sign_diff[22], sign_diff[23], sign_diff[24], sign_diff[25], sign_diff[26], sign_diff[27], sign_diff[28], sign_diff[29]);
    //Case 2: When the signs dont make sense
    wire w1, w2;
    and and_ovf_1(w1, ~results_reg_out[0], ~multiplicand[31], data_result[31]); // + * + = -
    and and_ovf_4(w2, results_reg_out[0], multiplicand[31], data_result[31]); // - * - = -
    or or_ovf_2(ovf_2, w1,w2);
    or and_exception(data_exception, ovf_1, ovf_2);

endmodule