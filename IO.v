//SW to addresses > 4096 = write to IO device, tell it to do something
//LW to addresses > 4096 = read from IO device, ask it what its status is
module IO(
    input clk,
    input IOinsn,
    input [31:0] dataIn,
    input [31:0] memAddr,
    output [31:0] dataOut,
    output [5:0] JA
    );
    
    wire new_stepper_data = memAddr[12] && IOinsn;
    wire [31:0] stepper_data_out;
    assign dataOut = stepper_data_out;
    wire [31:0] test_data = 32'd500;
    Stepper stepper(
        .CLK100MHZ(clk),
        .data_in(dataIn),
        .new_data(new_stepper_data),
        .data_out(stepper_data_out),
        .JA(JA)
    );    
     //ila_0 debuggers(.clk(clk), .probe0(new_stepper_data), .probe1(dataIn), .probe2(stepper_data_out), .probe3(stepper_data_out));
endmodule