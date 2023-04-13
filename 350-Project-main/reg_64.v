module reg_64(
    input [63:0] d, 
    input clk, 
    input en, 
    input clr,
    output [63:0] q
);

genvar c;
generate
    for(c=0; c<64; c=c+1)begin
        dffe_ref dff(.d(d[c]), .clk(clk), .en(en), .clr(clr), .q(q[c]));
    end
endgenerate

endmodule
