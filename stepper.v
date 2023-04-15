`timescale 1ns / 1ps
module Stepper(
    input CLK100MHZ,
    input [31:0]
    output JA_1,
    output JA_2,
    output JA_7,
    output JA_8,
    output JA_9,
    output JA_10
    );
    
    wire EN_A, EN_B, IN1, IN2, IN3, IN4;
    assign JA_1 = EN_A;
    assign JA_2 = EN_B;
    assign JA_7 = IN1;
    assign JA_8 = IN2;
    assign JA_9 = IN3;
    assign JA_10 = IN4;
    
    assign EN_A = 1'b1;
    assign EN_B = 1'b1;
    
    // Max speed = 190 Hz = 526,315 
    // Min speed =  50 Hz = 2,000,000
    reg [21:0] counter = 22'd0;
    reg [21:0] counter_limit = 22'd1100000;
    reg [21:0] counter_half_limit = 22'd1100000;
    reg toggle_phase_1 = 1'b0;
    reg phase_1 = 1'b0;
    reg phase_2 = 1'b0;
    always @(posedge CLK100MHZ)begin
        if(counter == counter_half_limit)begin
            if(toggle_phase_1)begin
                phase_1 = ~phase_1;
            end else begin
                phase_2 = ~phase_2;
            end
            counter = 22'd0;
            toggle_phase_1 = ~toggle_phase_1;
        end else begin
            counter = counter + 1'b1;
        end
    end
    
    assign IN1 = phase_1;
    assign IN2 = ~phase_1;
    assign IN3 = phase_2;
    assign IN4 = ~phase_2;
endmodule
