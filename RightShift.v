module RightShift(
    input [31:0] data,
    input [4:0] shamt,
    output [31:0] out
);

wire [31:0] shift_1_out;
wire [31:0] shift_2_out;
wire [31:0] shift_4_out;
wire [31:0] shift_8_out;

//========
// Shift 1
//========
mux_2_1 mux_shift_1_1(.in0(data[31]), .in1(data[31]), .out(shift_1_out[31]), .select(shamt[0]));
genvar c;
generate
    for(c=0; c<31; c=c+1)begin
        mux_2_1 mux_shift_1_c(.in0(data[c]), .in1(data[c+1]), .out(shift_1_out[c]), .select(shamt[0]));
    end
endgenerate

//========
// Shift 2
//========
mux_2_1 mux_shift_2_1(.in0(shift_1_out[31]), .in1(data[31]), .out(shift_2_out[31]), .select(shamt[1]));
mux_2_1 mux_shift_2_2(.in0(shift_1_out[30]), .in1(data[31]),  .out(shift_2_out[30]), .select(shamt[1]));
generate
    for(c=0; c<30; c=c+1)begin
        mux_2_1 mux_shift_2_c(.in0(shift_1_out[c]), .in1(shift_1_out[c+2]), .out(shift_2_out[c]), .select(shamt[1]));
    end
endgenerate

//========
// Shift 4
//========
mux_2_1 mux_shift_4_1(.in0(shift_2_out[31]), .in1(data[31]), .out(shift_4_out[31]), .select(shamt[2]));
mux_2_1 mux_shift_4_2(.in0(shift_2_out[30]), .in1(data[31]), .out(shift_4_out[30]), .select(shamt[2]));
mux_2_1 mux_shift_4_3(.in0(shift_2_out[29]), .in1(data[31]), .out(shift_4_out[29]), .select(shamt[2]));
mux_2_1 mux_shift_4_4(.in0(shift_2_out[28]), .in1(data[31]), .out(shift_4_out[28]), .select(shamt[2]));
generate
    for(c=0; c<28; c=c+1)begin
        mux_2_1 mux_shift_4_c(.in0(shift_2_out[c]), .in1(shift_2_out[c+4]), .out(shift_4_out[c]), .select(shamt[2]));
    end
endgenerate

//========
// Shift 8
//========
generate
    for(c=24; c<32; c=c+1)begin
        mux_2_1 mux_shift_8_1(.in0(shift_4_out[c]), .in1(data[31]), .out(shift_8_out[c]), .select(shamt[3]));
    end
    for(c=0; c<24; c=c+1)begin
        mux_2_1 mux_shift_8_c(.in0(shift_4_out[c]), .in1(shift_4_out[c+8]), .out(shift_8_out[c]), .select(shamt[3]));
    end
endgenerate

//=========
// Shift 16
//=========
generate
    for(c=16; c<32; c=c+1)begin
        mux_2_1 mux_shift_16_16(.in0(shift_8_out[c]), .in1(data[31]),.out(out[c]), .select(shamt[4]));
    end
    for(c=0; c<16; c=c+1)begin
        mux_2_1 mux_shift_16_c(.in0(shift_8_out[c]), .in1(shift_8_out[c+16]), .out(out[c]), .select(shamt[4]));
    end
endgenerate

endmodule