//Delete the carry out
module CLA_8(
    input [7:0]A, 
    input [7:0] B, 
    input Cin,
    input [7:0] gen, 
    input [7:0] prop, 
    output [7:0] S,
    output prop_group,
    output gen_group
);
    
    wire [8:0] carries;
    assign carries[0] = Cin;

    //============
    // XOR Gates
    //============

    genvar c;
    generate
        for(c=0; c<8; c = c+1)begin
            xor fa(S[c], A[c], B[c], carries[c]);
        end
    endgenerate

    //========
    // Carries
    //========

    //Carry 1
    wire w1;
    and and_1_1(w1, carries[0], prop[0]);
    or or_1(carries[1], w1, gen[0]);

    //Carry 2
    wire w2, w3;
    and and_2_1(w2, carries[0], prop[0], prop[1]);
    and and_2_2(w3, gen[0], prop[1]);
    or or_2(carries[2], w2, w3, gen[1]);

    //Carry 3
    wire w4, w5, w6;
    and and_3_1(w4, carries[0], prop[0], prop[1], prop[2]);
    and and_3_2(w5, gen[0], prop[1], prop[2]);
    and and_3_3(w6, gen[1], prop[2]);
    or or_3(carries[3], w4,w5,w6, gen[2]);

    //Carry 4 
    wire w7, w8, w9, w10;
    and and_4_1(w7, carries[0], prop[0], prop[1], prop[2], prop[3]);
    and and_4_2(w8, gen[0], prop[1], prop[2], prop[3]);
    and and_4_3(w9, gen[1], prop[2], prop[3]);
    and and_4_4(w10, gen[2], prop[3]);
    or or_4(carries[4], w7, w8, w9, w10, gen[3]);

    //Carry 5
    wire w11, w12, w13, w14, w15;
    and and_5_1(w11, carries[0], prop[0], prop[1], prop[2], prop[3], prop[4]);
    and and_5_2(w12, gen[0], prop[1], prop[2], prop[3], prop[4]);
    and and_5_3(w13, gen[1], prop[2], prop[3], prop[4]);
    and and_5_4(w14, gen[2], prop[3], prop[4]);
    and and_5_5(w15, gen[3], prop[4]);
    or or_5(carries[5], w11, w12, w13, w14, w15, gen[4]);

    //Carry 6
    wire w16, w17, w18, w19, w20, w21;
    and and_6_1(w16, carries[0], prop[0], prop[1], prop[2], prop[3], prop[4], prop[5]);
    and and_6_2(w17, gen[0], prop[1], prop[2], prop[3], prop[4], prop[5]);
    and and_6_3(w18, gen[1], prop[2], prop[3], prop[4], prop[5]);
    and and_6_4(w19, gen[2], prop[3], prop[4], prop[5]);
    and and_6_5(w20, gen[3], prop[4], prop[5]);
    and and_6_6(w21, gen[4], prop[5]);
    or or_6(carries[6], w16, w17, w18, w19, w20, w21, gen[5]);

    //Carry 7
    wire w22, w23, w24, w25, w26, w27, w28;
    and and_7_1(w22, carries[0], prop[0], prop[1], prop[2], prop[3], prop[4], prop[5], prop[6]);
    and and_7_2(w23, gen[0], prop[1], prop[2], prop[3], prop[4], prop[5], prop[6]);
    and and_7_3(w24, gen[1], prop[2], prop[3], prop[4], prop[5], prop[6]);
    and and_7_4(w25, gen[2], prop[3], prop[4], prop[5], prop[6]);
    and and_7_5(w26, gen[3], prop[4], prop[5], prop[6]);
    and and_7_6(w27, gen[4], prop[5], prop[6]);
    and and_7_7(w28, gen[5], prop[6]);
    or or_7(carries[7], w22, w23, w24, w25, w26, w27, w28, gen[6]);

    //=============================
    // Group generate and propogate
    //=============================

    wire w29, w30, w31, w32, w33, w34, w35, w36;
    and and_8_2(w29, gen[0], prop[1], prop[2], prop[3], prop[4], prop[5], prop[6], prop[7]);
    and and_8_3(w30, gen[1], prop[2], prop[3], prop[4], prop[5], prop[6], prop[7]);
    and and_8_4(w31, gen[2], prop[3], prop[4], prop[5], prop[6], prop[7]);
    and and_8_5(w32, gen[3], prop[4], prop[5], prop[6], prop[7]);
    and and_8_6(w33, gen[4], prop[5], prop[6], prop[7]);
    and and_8_7(w34, gen[5], prop[6], prop[7]);
    and and_8_8(w35, gen[6], prop[7]);
    or or_8(gen_group, w29, w30, w31, w32, w33, w34, w35, gen[7]);
    and and_8(prop_group, prop[0], prop[1], prop[2], prop[3], prop[4], prop[5], prop[6], prop[7]);

endmodule