module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
        
    input [31:0] data_operandA, data_operandB;
    input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

    output [31:0] data_result;
    output isNotEqual, isLessThan, overflow;

    // add your code here:
    wire [31:0] add_sub_out, and_out, or_out, left_shift_out, right_shift_out; 

    mux_8 out_mux(
        .out(data_result),
        .select(ctrl_ALUopcode[2:0]),
        .in0(add_sub_out),
        .in1(add_sub_out),
        .in2(and_out),
        .in3(or_out),
        .in4(left_shift_out),
        .in5(right_shift_out),
        .in6(32'b00000000000000000000000000000000),
        .in7(32'b00000000000000000000000000000000)
    );

    
    //====
    // CLA
    //====

    wire adder_cout, sub;
    wire [31:0] CLA_in_B;
    CLA_32 cla(
        .A(data_operandA), 
        .B(CLA_in_B), 
        .Cin(sub),
        .A_and_B(and_out),
        .A_or_B(or_out),
        .Cout(adder_cout),
        .S(add_sub_out)
    );

    wire w8;
    not not_4(w8, ctrl_ALUopcode[1]);
    and add_sub_sel(sub, w8, ctrl_ALUopcode[0]);

    genvar i;
    generate
        for(i=0; i<32; i=i+1)begin
            xor xor_d(CLA_in_B[i], data_operandB[i], sub);
        end
    endgenerate
    //=============
    // Left Shifter
    //=============

    LeftShift lshifter(.data(data_operandA), .shamt(ctrl_shiftamt), .out(left_shift_out));

    //=============
    // Right Shifter
    //=============

    RightShift rshifter(.data(data_operandA), .shamt(ctrl_shiftamt), .out(right_shift_out));

    //====
    // AND
    //====


    And_32 and_32(.A(data_operandA), .B(CLA_in_B), .out(and_out));


    //====
    // OR
    //====

    Or_32 or_32(.A(data_operandA), .B(CLA_in_B), .out(or_out));


    //=========
    // Overflow
    //=========

    wire w1,w2,w3,w4,w5,w6;
    xor axf(w3, sub, data_operandB[31]);
    not not_1(w4, data_operandA[31]);
    not not_2(w5, w3);
    not not_3(w6, add_sub_out[31]);
    and m_1(w1, data_operandA[31], w3, w6);
    and m_7(w2, w4, w5, add_sub_out[31]);
    or ovf(overflow, w2, w1);

    //=============
    // Is Not Equal
    //=============

    or isNotEqOut(isNotEqual, add_sub_out[0], add_sub_out[1], add_sub_out[2], add_sub_out[3]
    , add_sub_out[4], add_sub_out[5], add_sub_out[6], add_sub_out[7]
    , add_sub_out[8], add_sub_out[9], add_sub_out[10], add_sub_out[11]
    , add_sub_out[12], add_sub_out[13], add_sub_out[14], add_sub_out[15]
    , add_sub_out[16], add_sub_out[17], add_sub_out[18], add_sub_out[19]
    , add_sub_out[20], add_sub_out[21], add_sub_out[22], add_sub_out[23]
    , add_sub_out[24], add_sub_out[25], add_sub_out[26], add_sub_out[27]
    , add_sub_out[28], add_sub_out[29], add_sub_out[30], add_sub_out[31]
    );

    //=============
    // Is Less Than
    //=============
    wire w7;
    xor(w7, add_sub_out[31], overflow);
    and isLessThanout(isLessThan, w7, 1'b1);


endmodule