module And_8
(
    input [7:0] A,
    input [7:0] B,
    output [7:0] out
);
    genvar c;
    generate
        for(c=0; c<8; c = c+1)begin
            and and1(out[c], A[c], B[c]);
        end
    endgenerate
endmodule