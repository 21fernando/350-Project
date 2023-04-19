module reg_65(
    input [64:0] d, 
    input clk, 
    input en, 
    input clr,
    output [64:0] q
);

genvar c;
generate
    for(c=0; c<65; c=c+1)begin
        dffe_ref dff(.d(d[c]), .clk(clk), .en(en), .clr(clr), .q(q[c]));
    end
endgenerate

endmodule
