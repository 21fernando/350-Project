`timescale 1ns / 1ps
module Stepper(
    input CLK100MHZ,
    input [31:0] data_in,
    input new_data,
    output [5:0] JA);
    
    assign JA = {JA_1, JA_2, JA_7, JA_8, JA_9, JA_10};
    
    wire EN_A, EN_B, IN1, IN2, IN3, IN4;
    assign JA_1 = EN_A;
    assign JA_2 = EN_B;
    assign JA_7 = IN1;
    assign JA_8 = IN2;
    assign JA_9 = IN3;
    assign JA_10 = IN4;
    
    reg [31:0] command;
    reg [1:0] state;
    reg [20:0] target_pos;
    always @(negedge CLK100MHZ)begin
        if(new_data == 1'b1)begin
            command <= data_in;
            state <= data_in[22:21];
            target_pos <= data_in[20:0];
        end
    end
    
    // Max speed = 190 Hz = 526,315 
    // Min speed =  50 Hz = 2,000,000
    reg [21:0] counter = 22'd0;
    reg [21:0] counter_limit = 22'd2000000;//22'd263158;
    reg toggle_phase_1 = 1'b0;
    reg phase_1 = 1'b0;
    reg phase_2 = 1'b0;
    reg [20:0] current_pos = 22'd0;

    
    always @(posedge CLK100MHZ)begin
        if(counter == counter_limit)begin
            if(toggle_phase_1)begin
                phase_1 <= ~phase_1;
            end else begin
                phase_2 <= ~phase_2;
            end
            counter <= 22'd0;
            toggle_phase_1 <= ~toggle_phase_1;
            if((moving_backward || moving_forward)) begin
                if(moving_forward) begin
                    current_pos <= current_pos + 1;
                end else begin
                    current_pos <= current_pos - 1;
                end
            end
        end else begin
            counter <= counter + 1'b1;
        end
     end
    
    reg moving_forward;
    reg moving_backward;
    always @(posedge CLK100MHZ) begin 
        if(current_pos < target_pos) begin
            moving_forward <= 1'b1;// ^ (current_pos[20] ^ target_pos[20]) ;
            moving_backward <= 1'b0;// ^ (current_pos[20] ^ target_pos[20]);
        end else if (current_pos > target_pos) begin
            moving_forward <= 1'b0;// ^ (current_pos[20] ^ target_pos[20]);
            moving_backward <= 1'b1;// ^ (current_pos[20] ^ target_pos[20]);
        end else begin
            moving_forward <= 1'b0;
            moving_backward <= 1'b0;
        end
    end
    
    assign IN1 = (moving_forward) ? phase_1 : phase_2;
    assign IN2 = (moving_forward) ? ~phase_1 : ~phase_2;
    assign IN3 = (moving_forward) ? phase_2 : phase_1;
    assign IN4 = (moving_forward) ? ~phase_2 : ~phase_1;
    assign EN_A = (moving_backward || moving_forward);
    assign EN_B = (moving_backward || moving_forward);
    
    
   
endmodule
