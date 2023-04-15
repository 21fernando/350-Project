module IO(
    input clk,
    input [31:0] IO_dataIn,
    output [31:0] IO_dataOut,
    output [11:0] IO_addr,
    output IO_wEn,
    output [5:0] JA
    );
    
    assign IO_wEn = 1'b0;
    assign IO_addr = 12'd4095;
    assign IO_dataOut = 31'd0; 
    
    Stepper stepper(
        .CLK100MHZ(clk),
        .command(IO_dataIn),
        .JA(JA)
    );    

endmodule