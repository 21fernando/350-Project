module pc_latch(
    input clock,
    input reset, 
    input [11:0] d,
    output [11:0] q
);

    genvar pc_i;
    generate
        for(pc_i=0; pc_i<12; pc_i = pc_i + 1)begin
            dffe_ref_falling pc(
                    .d(d[pc_i]),
                    .q(q[pc_i]),
                    .en(1'b1),
                    .clr(reset),
                    .clk(clock)
                );
        end
    endgenerate

endmodule