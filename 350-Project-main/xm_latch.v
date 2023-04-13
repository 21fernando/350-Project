module xm_latch(
    input clock,
    input reset,
    input [31:0] i_insn,
    input [31:0] i_ALU_O,
    input [31:0] i_regfile_B,
    output [31:0] o_insn,
    output [31:0] o_ALU_O,
    output [31:0] o_regfile_B
);

genvar xm_i;
    generate
        for(xm_i=0; xm_i<32; xm_i=xm_i+1)begin

            dffe_ref_falling dff_xm_1(
                .d(i_insn[xm_i]),
                .q(o_insn[xm_i]),
                .en(1'b1),
                .clr(reset),
                .clk(clock)
            );

            dffe_ref_falling dff_xm_2(
                .d(i_ALU_O[xm_i]),
                .q(o_ALU_O[xm_i]),
                .en(1'b1),
                .clr(reset),
                .clk(clock)
            );

            dffe_ref_falling dff_xm_3(
                .d(i_regfile_B[xm_i]),
                .q(o_regfile_B[xm_i]),
                .en(1'b1),
                .clr(reset),
                .clk(clock)
            );

        end

    endgenerate    

endmodule