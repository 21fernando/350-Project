module Or_32
(
    input [31:0] A,
    input [31:0] B,
    output [31:0] out
);
    genvar c;
    generate
        for(c=0; c<32; c = c+1)begin
            or or1(out[c], A[c], B[c]);
        end
    endgenerate
endmodule