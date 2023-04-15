`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/15/2023 05:00:38 PM
// Design Name: 
// Module Name: sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sim;
    
    wire clk, BTNC, JA_1, JA_2, JA_7, JA_8, JA_9, JA_10;
    
    Wrapper wrapper(
    .CLK100MHZ(clk), 
    .BTNC(BTNC),
    .JA_1(JA_1), 
    .JA_2(JA_2),
    .JA_7(JA_7),
    .JA_8(JA_8),
    .JA_9(JA_9),
    .JA_10(JA_10));
    
    initial begin
        clk = 1'b0;
        BTNC = 1;
		#1;
		BTNC = 0;
    end
    
    always #10 clk = ~clk;
    
    
endmodule
