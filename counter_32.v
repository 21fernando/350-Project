module counter_32(
    input clk,
    input en,
    input rst,
    output [5:0] count
);

wire T2,T3,T4,T5,T6;

and(T2, en, count[0]);
and(T3, T2, count[1]);
and(T4, T3, count[2]);
and(T5, T4, count[3]);
and(T6, T5, count[4]);

tffe tff_1(
    .clk(clk),
    .T(en),
    .clr(rst),
    .Q(count[0]), 
    .Q_not()
);

tffe tff_2(
    .clk(clk),
    .T(T2),
    .clr(rst),
    .Q(count[1]), 
    .Q_not()
);

tffe tff_3(
    .clk(clk),
    .T(T3),
    .clr(rst),
    .Q(count[2]), 
    .Q_not()
);

tffe tff_4(
    .clk(clk),
    .T(T4),
    .clr(rst),
    .Q(count[3]), 
    .Q_not()
);

tffe tff_5(
    .clk(clk),
    .T(T5),
    .clr(rst),
    .Q(count[4]), 
    .Q_not()
);

tffe tff_6(
    .clk(clk),
    .T(T6),
    .clr(rst),
    .Q(count[5]), 
    .Q_not()
);

endmodule