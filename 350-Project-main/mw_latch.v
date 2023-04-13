module mw_latch(
    input clock,
    input reset,
    input [31:0] i_insn,
    input [31:0] i_ALU_O,
    input [31:0] i_mem_D,
    input [31:0] i_MD_O,
    input [31:0] i_MD_insn,
    input i_MD_rdy,
    output [31:0] o_insn,
    output [31:0] o_ALU_O,
    output [31:0] o_mem_D,
    output [31:0] o_MD_O,
    output [31:0] o_MD_insn,
    output o_MD_rdy
);

    genvar mw_i;
    generate

        for(mw_i=0; mw_i<32; mw_i=mw_i+1)begin

            dffe_ref_falling dff_mw_1(
                .d(i_insn[mw_i]),
                .q(o_insn[mw_i]),
                .en(1'b1),
                .clr(reset),
                .clk(clock)
            );

            dffe_ref_falling dff_mw_2(
                .d(i_ALU_O[mw_i]),
                .q(o_ALU_O[mw_i]),
                .en(1'b1),
                .clr(reset),
                .clk(clock)
            );

            dffe_ref_falling dff_mw_3(
                .d(i_mem_D[mw_i]),
                .q(o_mem_D[mw_i]),
                .en(1'b1),
                .clr(reset),
                .clk(clock)
            );

            dffe_ref_falling dff_mw_4(
                .d(i_MD_O[mw_i]),
                .q(o_MD_O[mw_i]),
                .en(1'b1),
                .clr(reset),
                .clk(clock)
            );

            dffe_ref_falling dff_mw_5(
                .d(i_MD_insn[mw_i]),
                .q(o_MD_insn[mw_i]),
                .en(1'b1),
                .clr(reset),
                .clk(clock)
            );
            
        end

    endgenerate

    dffe_ref_falling dff_mw_6(
        .d(i_MD_rdy),
        .q(o_MD_rdy),
        .en(1'b1),
        .clr(reset),
        .clk(clock)
    );

endmodule