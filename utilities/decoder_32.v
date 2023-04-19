module decoder_32(
    input [4:0] in,
    output [31:0] out
);

    mux_32 mux(
        .select(in),
        .in0(32'H00000001),
        .in1(32'H00000002),
        .in2(32'H00000004),
        .in3(32'H00000008),
        .in4(32'H00000010),
        .in5(32'H00000020),
        .in6(32'H00000040),
        .in7(32'H00000080),
        .in8(32'H00000100),
        .in9(32'H00000200),
        .in10(32'H00000400),
        .in11(32'H00000800),
        .in12(32'H00001000),
        .in13(32'H00002000),
        .in14(32'H00004000),
        .in15(32'H00008000),
        .in16(32'H00010000),
        .in17(32'H00020000),
        .in18(32'H00040000),
        .in19(32'H00080000),
        .in20(32'H00100000),
        .in21(32'H00200000),
        .in22(32'H00400000),
        .in23(32'H00800000),
        .in24(32'H01000000),
        .in25(32'H02000000),
        .in26(32'H04000000),
        .in27(32'H08000000),
        .in28(32'H10000000),
        .in29(32'H20000000),
        .in30(32'H40000000),
        .in31(32'H80000000),
        .out(out)
    );

endmodule