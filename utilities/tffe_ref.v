module tffe(
    input clk,
    input T,
    input clr,
    output Q, 
    output Q_not
);
    wire dff_d, T_not, w1, w2;

    dffe_ref dff(
        .q(Q), 
        .d(dff_d), 
        .clk(clk),
        .en(T),
        .clr(clr)
    );

    not out_not(Q_not, Q);
    or dff_in(dff_d, w1, w2);
    and and_1(w1, T, Q_not);
    not t_not(T_not, T);
    and and_2(w2, T_not, Q);

endmodule