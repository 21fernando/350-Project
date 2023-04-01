module fd_latch(
    input clock,
    input reset,
    input [31:0] i_insn,
    input [11:0] i_PC_plus,
    output [31:0] o_insn,
    output [11:0] o_PC_plus 
);

    genvar fd_i;
    generate

        for(fd_i=0; fd_i<32; fd_i=fd_i+1)begin

            dffe_ref_falling dff_fd_1(
                .d(i_insn[fd_i]),
                .q(o_insn[fd_i]),
                .en(1'b1),
                .clr(reset),
                .clk(clock)
            );

        end

        for(fd_i=0; fd_i<12; fd_i=fd_i+1)begin

            dffe_ref_falling dff_fd_2(
                .d(i_PC_plus[fd_i]),
                .q(o_PC_plus[fd_i]),
                .en(1'b1),
                .clr(reset),
                .clk(clock)
            );

        end
        
    endgenerate

endmodule