module twos_complement(
    input [31:0] a,
    output [31:0] comp_a
);
    
    CLA_32 adder(
        .A(~a), 
        .B(32'd0), 
        .Cin(1'b1),
        .A_and_B(32'd0), 
        .A_or_B(~a),
        .Cout(), 
        .S(comp_a)
    );

endmodule