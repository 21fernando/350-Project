`timescale 1ns / 1ps

module Phototransistors(
    input clk,
    input [15:0] SW,
    output reg [31:0] data_out
    );
    
    reg [15:0] SW_M, SW_Q;
    
    always @(posedge clk)begin
        SW_M <= SW;
        data_out[15:0] <= SW_M;
        data_out[31:16] <= 16'd0;
    end
    
endmodule
