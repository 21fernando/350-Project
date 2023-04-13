module CLA_16(
    input [15:0]A, 
    input [15:0] B, 
    input Cin,
    input [15:0] A_and_B, 
    input [15:0] A_or_B,
    output Cout, 
    output [15:0] S
);

    wire [3:0] carries;
    wire [2:0] gen, prop;
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

endmodule