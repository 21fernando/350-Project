module FullAdder (A, B, Cin, Cout, S);

    input A, B, Cin;
    output S, Cout;
    wire w1, w2, w3;

    xor xor1(w1, A,B);
    xor xor2(S, Cin, w1);
    and and1(w2, Cin, w1);
    and and2(w3, A, B);
    or or1(Cout, w2, w3);

endmodule