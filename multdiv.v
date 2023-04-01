module multdiv(
	data_operandA, data_operandB, 
	ctrl_MULT, ctrl_DIV, 
	clock, 
	data_result, data_exception, data_resultRDY, running);

    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock;

    output [31:0] data_result;
    output data_exception, data_resultRDY, running;

    //===============
    //Mult/Div Select
    //===============

    wire [31:0] mult_result, div_result;
    wire mult_ready, div_ready, mult_running, div_running;
    wire div_ovf, mult_ovf;

    assign data_result = mult_ready ? mult_result : div_result;
    assign data_exception = mult_ready ? mult_ovf : div_ovf;
    assign data_resultRDY = mult_ready || div_ready;
    assign running = mult_running || div_running;

    //==========
    //Multiplier
    //==========

    multiplier mult(
        .data_operandA(data_operandA),
        .data_operandB(data_operandB),
        .ctrl_MULT(ctrl_MULT), 
        .clock(clock),
	    .data_result(mult_result),
        .data_exception(mult_ovf), 
        .mult_ready(mult_ready),
        .mult_running(mult_running)
    );

    //========
    //Divider
    //========

    divider div(
        .data_operandA(data_operandA),
        .data_operandB(data_operandB),
        .ctrl_DIV(ctrl_DIV), 
        .clock(clock),
        .data_result(div_result),
        .data_exception(div_ovf), 
        .div_ready(div_ready),
        .div_running(div_running)
    );

endmodule
