/**
 * READ THIS DESCRIPTION!
 *
 * This is your processor module that will contain the bulk of your code submission. You are to implement
 * a 5-stage pipelined processor in this module, accounting for hazards and implementing bypasses as
 * necessary.
 *
 * Ultimately, your processor will be tested by a master skeleton, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file, Wrapper.v, acts as a small wrapper around your processor for this purpose. Refer to Wrapper.v
 * for more details.
 *
 * As a result, this module will NOT contain the RegFile nor the memory modules. Study the inputs 
 * very carefully - the RegFile-related I/Os are merely signals to be sent to the RegFile instantiated
 * in your Wrapper module. This is the same for your memory elements. 
 *
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readRegA,                  // O: Register to read from port A of RegFile
    ctrl_readRegB,                  // O: Register to read from port B of RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readRegA,                  // I: Data from port A of RegFile
    data_readRegB,                   // I: Data from port B of RegFile

    JA
	
	);

	// Control signals
	input clock, reset;
	
	// Imem
    output [31:0] address_imem;
	input [31:0] q_imem;

	// Dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

    output [5:0] JA;
	
    //Stall wire
    wire stall, MD_stall, bypassing_stall;

	/* YOUR CODE STARTS HERE */

    //=======================================================================//
    //========================== FETCH STAGE ================================//
    //=======================================================================//
    
    //Latch output wires
    wire [31:0] D_insn;
    wire [11:0] D_PC_plus;

    //PC wires
    wire [11:0] PC_in, PC_out, PC_plus;
    wire [15:0] PC_CLA_out;

    pc_latch pc_reg(
        .clock(clock),
        .reset(reset), 
        .d(PC_in),
        .q(PC_out)
    );

    CLA_16 pc_CLA(
        .A({4'd0, PC_out}), 
        .B(16'd1), 
        .Cin(1'b0),
        .A_and_B({4'd0, PC_out} & 16'd1), 
        .A_or_B({4'd0, PC_out} | 16'd1),
        .Cout(), 
        .S(PC_CLA_out)
    );

    assign PC_plus = PC_CLA_out[11:0];
    assign stall  = MD_stall || bypassing_stall;
    assign PC_in = (E_branched_jumped) ? E_PC_target : ( (stall) ? PC_out : PC_plus);

    assign address_imem = {20'd0, PC_out};
    
    fd_latch fd_latch_a(
        .clock(clock),
        .reset(reset),
        .i_insn((stall) ? D_insn : (E_branched_jumped) ? 32'd0 : q_imem),
        .i_PC_plus((stall) ? PC_out : PC_plus),
        .o_insn(D_insn),
        .o_PC_plus(D_PC_plus) 
    );

    //=======================================================================//
    //========================== DECODE STAGE ===============================//
    //=======================================================================//
    
    //Latch output wires
    wire [11:0] E_PC_plus;
    wire [31:0] E_insn, E_regfile_A, E_regfile_B, dx_latch_insn_in;
    
    assign ctrl_writeEnable = W_we;
    assign ctrl_writeReg = W_rd;
    assign ctrl_readRegA =  (D_insn[31:27] == 5'b10110) ? 5'd0 : D_insn[21:17]; //RS
    assign ctrl_readRegB =  (D_insn[31:27] == 5'b00111 || D_insn[31:27] == 5'b00110 || D_insn[31:27] == 5'b00010 || D_insn[31:27] == 5'b00100) ? D_insn[26:22] : 
                            (D_insn[31:27] == 5'b10110) ? 5'd30 : D_insn[16:12]; //RT
    assign data_writeReg = W_write_data;

    assign dx_latch_insn_in = (stall || E_branched_jumped) ? 32'd0 : D_insn;
    dx_latch dx_latch_a(
        .clock(clock),
        .reset(reset),
        .i_insn(dx_latch_insn_in),
        .i_PC_plus(D_PC_plus),
        .i_regfile_A(data_readRegA),
        .i_regfile_B(data_readRegB),
        .o_insn(E_insn),
        .o_PC_plus(E_PC_plus), 
        .o_regfile_A(E_regfile_A),
        .o_regfile_B(E_regfile_B)
    );

    //=======================================================================//
    //========================= EXECUTE STAGE ===============================//
    //=======================================================================//
    //ALU wires 
    wire [31:0] E_alu_op_a, E_alu_op_b, E_alu_out, E_ALU_o_selected;
    wire [4:0] E_alu_opcode, E_alu_shamt;
    wire E_alu_ne, E_alu_lt, E_alu_ovf;
    wire E_r_type, E_other_sub;
    
    //Source and Destination registers
    wire [4:0] E_rs, E_rt, E_rd;
    assign E_rs = E_insn[21:17];
    assign E_rt = E_insn[16:12];
    assign E_rd = E_insn[26:22];

    //Bypassing
    wire [4:0] E_byp_B_part;
    assign E_byp_B_part = (E_insn[31:27] == 5'b10110) ? 5'd30 : (E_insn[31:27] == 5'b00100 || E_insn[31:27] == 5'b00010 || E_insn[31:27] == 5'b00110) ? E_rd : E_rt;
    wire [31:0] E_regfile_A_byp, E_regfile_B_byp;
    wire E_M_X_byp_A, E_M_X_byp_B, E_W_X_byp_A, E_W_X_byp_B, M_insn_doesnt_write_rd, W_insn_doesnt_write_rd;
    assign W_insn_doesnt_write_rd = (W_insn[31:27] == 5'b00111) || (W_insn[31:27] == 5'b00010) || (W_insn[31:27] == 5'b00110);
    assign M_insn_doesnt_write_rd = (M_insn[31:27] == 5'b00111) || (M_insn[31:27] == 5'b00010) || (M_insn[31:27] == 5'b00110);
    assign E_M_X_byp_A = M_rd == E_rs && ~M_insn_doesnt_write_rd && E_rs != 5'd0;
    assign E_W_X_byp_A = W_rd == E_rs && ~W_insn_doesnt_write_rd && E_rs != 5'd0;
    assign E_M_X_byp_B = M_rd == E_byp_B_part && ~M_insn_doesnt_write_rd && E_byp_B_part != 5'd0;
    assign E_W_X_byp_B = W_rd == E_byp_B_part && ~W_insn_doesnt_write_rd && E_byp_B_part != 5'd0; 

    //Edge Case
    assign bypassing_stall = (E_insn[31:27] == 5'b01000) && ((ctrl_readRegA == E_rd) || ((ctrl_readRegB == E_rd) && (D_insn[31:27] != 5'b00111 ))); 
    
    assign E_regfile_A_byp = (E_M_X_byp_A)? M_alu_out:
                            (E_W_X_byp_A) ? W_write_data : 
                            E_regfile_A; //RS
    assign E_regfile_B_byp = (E_M_X_byp_B)? M_alu_out:
                            (E_W_X_byp_B) ? W_write_data : 
                            (E_insn[31:27] == 5'b10101) ? {4'd0, E_insn[26:0]}: E_regfile_B; //RT
    

    //Latch output wires
    wire [31:0] M_insn, M_alu_out, M_regfile_B; 
    
    wire [31:0] E_sx_immed;
    wire E_immed_insn;

    assign E_not_immed_insn = (E_insn[31:27] == 5'b00000 || E_insn[28:27] == 2'b10);
    assign E_sx_immed = {{15{E_insn[16]}}, E_insn[16:0]};

    assign E_alu_op_a = E_regfile_A_byp;
    assign E_alu_op_b = (~E_not_immed_insn) ? E_sx_immed : E_regfile_B_byp; 
    assign E_alu_shamt = E_insn[11:7];
    assign E_r_type = E_insn[31:27] == 5'd0;
    assign E_other_sub = E_insn[28:27] == 2'b10;
    assign E_alu_opcode = (E_r_type) ? E_insn[6:2] : 
                        (E_other_sub) ? 5'b00001 : 5'b00000;

    alu alu_a(
        .data_operandA(E_alu_op_a), 
        .data_operandB(E_alu_op_b), 
        .ctrl_ALUopcode(E_alu_opcode), 
        .ctrl_shiftamt(E_alu_shamt), 
        .data_result(E_alu_out), 
        .isNotEqual(E_alu_ne), 
        .isLessThan(E_alu_lt), 
        .overflow(E_alu_ovf)
    );

    //Branch Jump logic
    wire E_branched_jumped, E_BLT_taken, E_BNE_taken, E_BEX_taken, E_BLT_insn, E_BNE_insn, E_BEX_insn, E_jal_insn, E_jr_insn, E_j_insn;
    wire [31:0] E_PC_target, E_PC_adder, E_PC_adder_in_A, E_PC_adder_in_B;
    wire exception;
    assign exception = 1'b0;
    assign E_BNE_insn = E_insn[31:27] == 5'b00010;
    assign E_BLT_insn = E_insn[31:27] == 5'b00110;
    assign E_BEX_insn = E_insn[31:27] == 5'b10110;
    assign E_jal_insn = E_insn[31:27] == 5'b00011;
    assign E_jr_insn = E_insn[31:27] == 5'b00100;
    assign E_j_insn = E_insn[31:27] == 5'b00001;
    and E_and_1(E_BNE_taken, E_BNE_insn, E_alu_ne);
    and E_and_2(E_BLT_taken, E_BLT_insn,~E_alu_lt && E_alu_ne);
    and E_and_3(E_BEX_taken, E_BEX_insn, E_alu_ne);
    or E_or_1(E_branched_jumped, E_BLT_taken, E_BNE_taken, E_BEX_taken, E_jal_insn, E_jr_insn, E_j_insn);
    assign E_ALU_o_selected = (E_insn[31:27] == 5'b00011) ? E_PC_plus : E_alu_out;
    assign E_PC_target = (E_jr_insn) ? E_regfile_B_byp : E_PC_adder;
    assign E_PC_adder_in_A = (E_BNE_insn || E_BLT_insn) ? E_sx_immed : {5'd0,E_insn[26:0]};
    assign E_PC_adder_in_B = (E_BNE_insn || E_BLT_insn) ? E_PC_plus : 32'd0;
    CLA_32 compute_new_PC(
        .A(E_PC_adder_in_A), 
        .B(E_PC_adder_in_B), 
        .Cin(1'b0),
        .A_and_B(E_PC_adder_in_A & E_PC_adder_in_B), 
        .A_or_B(E_PC_adder_in_A | E_PC_adder_in_B),
        .Cout(), 
        .S(E_PC_adder)
    );

    //Exception Handling
    wire[31:0] E_insn_exception, E_insn_out, E_ALU_o_exception, E_ALU_o_in;
    wire E_exception, MD_exception;
    assign E_exception = (E_insn[31:27] == 5'd0 || E_insn[31:27] == 5'b00101) && (E_alu_ovf || (MD_exception && MD_ready));
    assign E_insn_exception = {E_insn[31:27] , 5'd30, E_insn[21:0]};
    assign E_insn_out = (E_exception) ? E_insn_exception : E_insn;
    assign E_ALU_o_in = (~E_exception) ? E_ALU_o_selected : 
                        (MD_input_insn[6:2] == 5'b00110) ? 32'd4 : 
                        (MD_input_insn[6:2] == 5'b00111) ? 32'd5 :
                        (E_insn[31:27] == 5'b00101) ? 32'd2 : 
                        (E_alu_opcode == 5'b00000) ? 32'd1 : 32'd3  ; 
    xm_latch xm_latch_a(
        .clock(clock),
        .reset(reset),
        .i_insn(E_insn_out),
        .i_ALU_O(E_ALU_o_in),
        .i_regfile_B(E_regfile_B_byp),
        .o_insn(M_insn),
        .o_ALU_O(M_alu_out),
        .o_regfile_B(M_regfile_B)
    );  

    //=======================================================================//
    //========================== MULTDIV STAGE ==============================//
    //=======================================================================// 
    wire [31:0] MD_output, MD_insn, MD_reg_result, MD_input_insn;
    wire MD_ready, M_MD_ready, MD_mult, MD_div, MD_running;

    assign MD_mult = E_insn[31:27] == 5'b00000 && E_insn[6:2] == 5'b00110;
    assign MD_div = E_insn[31:27] == 5'b00000 && E_insn[6:2] == 5'b00111;

    multdiv multdiv_a(
	    .data_operandA(E_alu_op_a), 
        .data_operandB(E_alu_op_b), 
	    .ctrl_MULT(MD_mult), 
        .ctrl_DIV(MD_div), 
	    .clock(clock), 
	    .data_result(MD_output), 
        .data_exception(MD_exception), 
        .data_resultRDY(MD_ready),
        .running(MD_running)
    );

    //Stall logic
    assign MD_stall = MD_running;
    assign MD_input_insn = (MD_insn[31:27] == 5'd0 && MD_insn[4:3] == 2'b11 && MD_running) ? MD_insn : E_insn;
    
    //Exception Handling
    //If I have an exception, change this instruction so writeback thinks we have a normal insn [6:2]
    wire [31:0] MD_input_insn_exception;
    assign MD_input_insn_exception = (MD_exception && MD_ready) ? {MD_input_insn[31:7], 5'd0, MD_input_insn[1:0]} : MD_input_insn;
    
    pw_latch pw_latch_a(
        .clock(clock),
        .reset(reset),
        .i_insn(MD_input_insn_exception),
        .i_result(MD_output),
        .i_MD_rdy(MD_ready),
        .o_insn(MD_insn),
        .o_result(MD_reg_result),
        .o_MD_rdy(M_MD_ready)
    );

    //=======================================================================//
    //========================== MEMORY STAGE ===============================//
    //=======================================================================//

    //Latch output wires
    wire [31:0] W_insn, W_alu_o, W_mem_D, W_MD_O, W_MD_insn;
    wire W_MD_rdy;

    //Source and Destination registers
    wire [4:0] M_rs, M_rd;
    assign M_rs = M_insn[21:17];
    assign M_rd = (M_insn[31:27] == 5'b10101) ? 5'd30 : 
                  (M_insn[31:27] == 5'b00011) ? 5'd31 : M_insn[26:22];

    //Bypassing
    wire[31:0] M_regfile_B_byp;
    wire M_W_M_byp;
    assign M_W_M_byp = (W_rd == M_rd && ~W_insn_doesnt_write_rd);
    assign M_regfile_B_byp = (M_W_M_byp) ? W_write_data : M_regfile_B;

    // Dmem
    assign address_dmem = M_alu_out;
    assign data = M_regfile_B_byp;
    assign wren = M_insn[31:27] == 5'b00111 && M_alu_out[31:30] == 2'b00;

    //If JAL, modify instruction to put reg 31 here, hopefully this moves some combinational delay to this stage instead of writeback
    wire [31:0] M_modified_insn, M_selected_insn;
    assign M_modified_insn = {M_insn[31:27], 5'b11111, M_insn[21:0]};
    assign M_selected_insn = (M_insn[31:27] == 5'b00011) ? M_modified_insn : M_insn;
    mw_latch mw_latch_a(
        .clock(clock),
        .reset(reset),
        .i_insn(M_selected_insn),
        .i_ALU_O(M_alu_out),
        .i_mem_D(CPUmemDataIn),
        .i_MD_O(MD_reg_result),
        .i_MD_insn(MD_insn),
        .i_MD_rdy(M_MD_ready),
        .o_insn(W_insn),
        .o_ALU_O(W_alu_o),
        .o_mem_D(W_mem_D),
        .o_MD_O(W_MD_O),
        .o_MD_insn(W_MD_insn),
        .o_MD_rdy(W_MD_rdy)
    );

    wire[31:0] IOdataOut, CPUmemDataIn; 
    //Cases:
	//memAddr[13:12] == 11 ==> Invalid
	//memAddr[13:12] == 10 ==> IO Read
	//memAddr[13:12] == 01 ==> IO Write
	//memAddr[13:12] == 00 ==> Non-IO mem access
    assign IOinsn = (M_insn[31:27] == 5'b00111 || M_insn[31:27] == 5'b01000) && (address_dmem[13] == 1'b1 || address_dmem[12] == 1'b1);
	wire [31:0] test;
	assign test = {10'd0, 22'd700000};
	wire [21:0] debug;
	assign debug = data[21:0];
	wire new_stepper_data = address_dmem[12] && IOinsn;
    Stepper stepper(
        .CLK100MHZ(clock),
        .data_in(data),
        .new_data(new_stepper_data),
        .data_out(IOdataOut),
        .JA(JA)
    ); 
    ila_0 debuggers(.clk(clock), .probe0(new_stepper_data), .probe1(data), .probe2(IOdataOut), .probe3(debug));
	assign CPUmemDataIn = (IOinsn && (address_dmem[13] == 1'b1)) ? IOdataOut : q_dmem;

    //=======================================================================//
    //======================== WRITEBACK STAGE ==============================//
    //=======================================================================//
    wire W_we, W_write_mem_val, W_write_mult_val;
    wire[31:0] W_write_data;
    wire[4:0] W_rd, W_rs;
    assign W_write_mem_val = W_insn[31:27] == 5'b01000;
    assign W_write_mult_val = W_MD_insn[31:27] == 5'b00000 && W_MD_insn[4:3] == 2'b11;
    assign W_write_data = (W_write_mem_val) ? W_mem_D : ((W_write_mult_val) ? W_MD_O : W_alu_o);
    assign W_rd = (W_insn[31:27] == 5'b10101) ? 5'd30 : 
                  (W_insn[31:27] == 5'b00011) ? 5'd31 :
                  (W_write_mult_val) ? W_MD_insn[26:22] : W_insn[26:22];
    assign W_rs = E_insn[21:17];
    assign W_we = (W_insn[31:27]==5'b0) ? ((W_write_mult_val)? W_MD_rdy : 1'b1 ): 
                (W_insn[30]==1'b1) ? 1'b1 : 
                (W_insn[29:27] == 5'b101) ? 1'b1 : 
                (W_insn[31:27] == 5'b00011) ? 1'b1 : 1'b0;
	

	/* END CODE */

endmodule
