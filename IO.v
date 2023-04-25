//SW to addresses > 4096 = write to IO device, tell it to do something
//LW to addresses > 4096 = read from IO device, ask it what its status is
module IO(
    input clk,
    input [31:0] reg_24,
    output [31:0] reg_25,
    output [5:0] JA,
    input [7:0] analog_input,
    output clk_out,
    output [2:0] new_address, 
    output [2:0] min_address,
    output move_goalie,
    input limit_switch,
	input beam_break,
	output [9:0] sseg
    );
    
    wire new_stepper_data = 1'b1;
    wire [31:0] stepper_data_out;
    assign dataOut = stepper_data_out;
    wire [31:0] test_data = 32'd500;
    Stepper stepper(
        .CLK100MHZ(clk),
        .data_in(reg_24),
        .new_data(new_stepper_data),
        .JA(JA)
    );    
    
    wire [3:0] phototransistor_out;
    assign min_address = phototransistor_out[3:1];
    assign move_goalie = phototransistor_out[0];
    adc_phototransistor adc(
        .analog_input(analog_input),
        .CLK100MHZ(clk), 
        .clk_out(clk_out), 
        .output_goalie(phototransistor_out), 
        .new_address(new_address));


    assign reg_25 = {26'd0, limit_switch, beam_break, phototransistor_out};
    
endmodule