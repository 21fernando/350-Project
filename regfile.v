module regfile (
	clock,
	ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, data_writeReg,
	data_readRegA, data_readRegB
);

	input clock, ctrl_writeEnable, ctrl_reset;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;

	output [31:0] data_readRegA, data_readRegB;

	wire [31:0] reg_out [31:0];
	wire [31:0] reg_en;
	wire [31:0] write_sel;
	wire [31:0] read_1_sel;
	wire [31:0] read_2_sel;

	// add your code here

	//=======================
	// Register Instantiation
	//=======================
	genvar c;
	generate
		for(c=0; c<32; c=c+1)begin
			reg_32 r(.q(reg_out[c]), .d(data_writeReg), .clk(clock), .en(reg_en[c]), .clr(ctrl_reset));
		end
	endgenerate

	//===============
	// Register Write
	//===============

	decoder_32 write_en_decoder(.in(ctrl_writeReg), .out(write_sel));

	generate
		for(c=1; c<32; c=c+1)begin
			and and_en(reg_en[c], write_sel[c], ctrl_writeEnable);
		end
	endgenerate

	//Hardwire 0 register to be not writeable
	assign reg_en[0] = 1'b0;


	//==============
	// Register Read
	//==============

	//Decoders
	decoder_32 read_1_decoder(.in(ctrl_readRegA), .out(read_1_sel));
	decoder_32 read_2_decoder(.in(ctrl_readRegB), .out(read_2_sel));

	//Tristates
	generate
		for(c=0; c<32; c=c+1)begin
			tristate tri_buf1(.D(reg_out[c]), .E(read_1_sel[c]), .Q(data_readRegA));
			tristate tri_buf2(.D(reg_out[c]), .E(read_2_sel[c]), .Q(data_readRegB));
		end
	endgenerate

endmodule
