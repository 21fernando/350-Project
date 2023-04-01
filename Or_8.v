module Or_8
(
    input [7:0] A,
    input [7:0] B,
    output [7:0] out
);
    genvar c;
    generate
        for(c=0; c<8; c = c+1)begin
            or or1(out[c], A[c], B[c]);
        end
    endgenerate
endmodule