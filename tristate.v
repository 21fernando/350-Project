module tristate(
    input [31:0] D,
    input E,
    output [31:0] Q
);

    assign Q = E ? D : 32'bZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ;

endmodule