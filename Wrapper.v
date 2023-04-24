`timescale 1ns / 1ps
/**
 * 
 * READ THIS DESCRIPTION:
 *
 * This is the Wrapper module that will serve as the header file combining your processor, 
 * RegFile and Memory elements together.
 *
 * This file will be used to generate the bitstream to upload to the FPGA.
 * We have provided a sibling file, Wrapper_tb.v so that you can test your processor's functionality.
 * 
 * We will be using our own separate Wrapper_tb.v to test your code. You are allowed to make changes to the Wrapper files 
 * for your own individual testing, but we expect your final processor.v and memory modules to work with the 
 * provided Wrapper interface.
 * 
 * Refer to Lab 5 documents for detailed instructions on how to interface 
 * with the memory elements. Each imem and dmem modules will take 12-bit 
 * addresses and will allow for storing of 32-bit values at each address. 
 * Each memory module should receive a single clock. At which edges, is 
 * purely a design choice (and thereby up to you). 
 * 
 * You must change line 36 to add the memory file of the test you created using the assembler
 * For example, you would add sample inside of the quotes on line 38 after assembling sample.s
 *
 **/

module Wrapper (
    input CLK100MHZ, 
    input BTNC,
    output JA_1, 
    output JA_2,
    output JA_7,
    output JA_8,
    output JA_9,
    output JA_10, 
    output move_goalie,
    output [2:0] min_address, 
    input [7:0] analog_input,
    output clk_out,
    output [2:0] new_address,
	input limit_switch,
	input beam_break,
	output [9:0] sseg
    );
    
	assign clock = CLK100MHZ;
	assign reset = BTNC;

	wire rwe, mwe;
	wire[4:0] rd, rs1, rs2;
	wire[4:0] M_op;
	wire[31:0] instAddr, instData, 
		rData, regA, regB,
		memAddr, memDataIn, memDataOut;
	
	wire [5:0] JA;
    assign JA_1 = JA[0];
    assign JA_2 = JA[1];
    assign JA_7 = JA[2];
    assign JA_8 = JA[3];
    assign JA_9 = JA[4];
    assign JA_10 = JA[5];

	wire [31:0] reg_24, reg_25;

	// ADD YOUR MEMORY FILE HERE
	localparam INSTR_FILE = "C:/Users/taf27/Documents/350-Project/assembler/stepper";
	
	// Main Processing Unit
	processor CPU(.clock(clock), .reset(reset), 
								
		// ROM
		.address_imem(instAddr), .q_imem(instData),
									
		// Regfile
		.ctrl_writeEnable(rwe),     .ctrl_writeReg(rd),
		.ctrl_readRegA(rs1),     .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB),
									
		// RAM
		.wren(mwe), .address_dmem(memAddr), 
		.data(memDataOut), .q_dmem(memDataOut),
		
		//IO
		.JA(JA), .SW(SW),
		.reg_24(reg_24), .reg_25(reg_25), 
		
		.move_goalie(move_goalie),
        .min_address(min_address), 
        .analog_input(analog_input),
        .clk_out(clk_out),
        .new_address(new_address),
		.limit_switch(limit_switch),
		.beam_break(beam_break),
		.sseg(sseg)
		); 
	
	// Instruction Memory (ROM)
	// Instruction Memory (ROM)
	ROM #(.MEMFILE({INSTR_FILE, ".mem"}))
	InstMem(.clk(clock), 
		.addr(instAddr[11:0]), 
		.dataOut(instData));
	
	// Register File
	regfile RegisterFile(.clock(clock), 
		.ctrl_writeEnable(rwe), .ctrl_reset(reset), 
		.ctrl_writeReg(rd),
		.ctrl_readRegA(rs1), .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB),
		.reg_24(reg_24), .reg_25(reg_25));							
	
	// Processor Memory (RAM)
	RAM ProcMem(.clk(clock), 
		.wEn(mwe),
		.addr(memAddr[11:0]),
		.dataIn(memDataIn),
		.dataOut(memDataOut)
	);
    
	

endmodule
