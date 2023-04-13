module dx_latch(
    input clock,
    input reset,
    input [31:0] i_insn,
    input [11:0] i_PC_plus,
    input [31:0] i_regfile_A,
    input [31:0] i_regfile_B,
    output [31:0] o_insn,
    output [11:0] o_PC_plus, 
    output [31:0] o_regfile_A,
    output [31:0] o_regfile_B
);

    genvar dx_i;
    
    generate

        for(dx_i=0; dx_i<32; dx_i=dx_i+1)begin

            dffe_ref_falling dff_dx_1(
                .d(i_insn[dx_i]),
                .q(o_insn[dx_i]),
                .en(1'b1),
                .clr(reset),
                .clk(clock)
            );

            dffe_ref_falling dff_dx_2(
                .d(i_regfile_A[dx_i]),
                .q(o_regfile_A[dx_i]),
                .en(1'b1),
                .clr(reset),
                .clk(clock)
            );

            dffe_ref_falling dff_dx_3(
                .d(i_regfile_B[dx_i]),
                .q(o_regfile_B[dx_i]),
                .en(1'b1),
                .clr(reset),
                .clk(clock)
            );

        end

        for(dx_i=0; dx_i<12; dx_i=dx_i+1)begin

            dffe_ref_falling dff_dx_4(
                .d(i_PC_plus[dx_i]),
                .q(o_PC_plus[dx_i]),
                .en(1'b1),
                .clr(reset),
                .clk(clock)
            );
            
        end

    endgenerate

endmodule