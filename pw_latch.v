module pw_latch(
    input clock,
    input reset,
    input [31:0] i_insn,
    input [31:0] i_result,
    input i_MD_rdy,
    output [31:0] o_insn,
    output [31:0] o_result,
    output o_MD_rdy
);

    genvar pw_i;
    generate
        for(pw_i=0; pw_i<32; pw_i=pw_i+1)begin

            dffe_ref_falling dff_pw_1(
                .d(i_insn[pw_i]),
                .q(o_insn[pw_i]),
                .en(1'b1),
                .clr(reset),
                .clk(clock)
            );

            dffe_ref_falling dff_pw_2(
                .d(i_result[pw_i]),
                .q(o_result[pw_i]),
                .en(1'b1),
                .clr(reset),
                .clk(clock)
            );

        end

    endgenerate  

    dffe_ref_falling dff_pw_3(  
        .d(i_MD_rdy),
        .q(o_MD_rdy),
        .en(1'b1),
        .clr(reset),
        .clk(clock)
    );

endmodule