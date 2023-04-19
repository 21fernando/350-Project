module CLA_32(
    input [31:0]A, 
    input [31:0] B, 
    input Cin,
    input [31:0] A_and_B, 
    input [31:0] A_or_B,
    output Cout, 
    output [31:0] S
);

    wire [4:0] carries;
    wire [3:0] gen, prop;
    assign Cout = carries[4];
    assign carries[0] = Cin;

    //8 Bit CLAS
    CLA_8 cla_1(
        .A(A[7:0]), 
        .B(B[7:0]), 
        .Cin(carries[0]), 
        .S(S[7:0]), 
        .gen(A_and_B[7:0]),
        .prop(A_or_B[7:0]),
        .gen_group(gen[0]), 
        .prop_group(prop[0])
    );
    CLA_8 cla_2(
        .A(A[15:8]), 
        .B(B[15:8]), 
        .Cin(carries[1]), 
        .S(S[15:8]), 
        .gen(A_and_B[15:8]),
        .prop(A_or_B[15:8]),
        .gen_group(gen[1]), 
        .prop_group(prop[1])
    );
    CLA_8 cla_3(
        .A(A[23:16]), 
        .B(B[23:16]), 
        .Cin(carries[2]), 
        .S(S[23:16]), 
        .gen(A_and_B[23:16]),
        .prop(A_or_B[23:16]),
        .gen_group(gen[2]), 
        .prop_group(prop[2])
    );
    CLA_8 cla_4(
        .A(A[31:24]), 
        .B(B[31:24]), 
        .Cin(carries[3]), 
        .S(S[31:24]), 
        .gen(A_and_B[31:24]),
        .prop(A_or_B[31:24]),
        .gen_group(gen[3]), 
        .prop_group(prop[3])
    );

    //========
    // Carries
    //========

    //Carry 1
    wire w1;
    and(w1, carries[0], prop[0]);
    or or_1(carries[1], gen[0], w1);

    //Carry 2
    wire w2, w3;
    and(w2, carries[0], prop[0], prop[1]);
    and(w3, gen[0], prop[1]);
    or(carries[2], gen[1], w2, w3);

    //Carry 3
    wire w4, w5, w6;
    and(w4, carries[0], prop[0], prop[1], prop[2]);
    and(w5, gen[0], prop[1], prop[2]);
    and(w6, gen[1], prop[2]);
    or(carries[3], gen[2], w4, w5, w6);

    //Carry 4
    wire w7, w8, w9, w10;
    and(w7, carries[0], prop[0], prop[1], prop[2], prop[3]);
    and(w8, gen[0], prop[1], prop[2], prop[3]);
    and(w9, gen[1], prop[2], prop[3]);
    and(w10, gen[2], prop[3]);
    or(carries[4], gen[3], w4, w5, w6);


endmodule