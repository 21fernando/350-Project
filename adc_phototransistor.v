module adc_phototransistor(analog_input, CLK100MHZ, clk_out, output_goalie, new_address);
    input [7:0] analog_input;
    input CLK100MHZ;
    output reg clk_out;
	
	output [31:0] output_goalie;
	wire [2:0] min_address;
	wire move_goalie;
	assign output_goalie [31:4] = 28'd0;
	assign output_goalie [3:1] = min_address;
	assign output_goalie [0] = move_goalie;
	reg [7:0] transistor_count;
    
     reg [16:0] freq_count;

    output [2:0] new_address;
    //assign clk_out = CLK100MHZ;
    //assign clk_out = clk_out2;
    
    wire [31:0] transistor_extend, register_transistor[7:0];
    reg[32:0] clk_count;
    
    

    always @(posedge CLK100MHZ) begin
        if(clk_count == 500000) begin
            clk_count <= 0;
	        //clk_out2 <= ~clk_out2;
	        clk_out <= ~clk_out;
        end
        else begin
           clk_count <= clk_count + 1;
        end
    end

    wire [7:0] regEnable_transistor;
    
    
	reg output_ready;
   
   // cycle between the 8 phototransistors to see which one that the ADC should be sampling
    always @(posedge clk_out) begin
        freq_count <= freq_count + 1;
        if(freq_count == 5) begin
        
	        output_ready <= 1;
	        
        end
        else if (freq_count == 1) begin
            if(transistor_count < 7) begin
                transistor_count <= transistor_count + 1;
            end
            else begin
                transistor_count <= 0;
            end
        end
        else if (freq_count == 7) begin
            output_ready <= 0;
            freq_count <= 0;
            
        end
        
    end
        
    //decoder to store which transistor to enable for the registers below
    decoder3to8 decoder_transistors(regEnable_transistor, transistor_count);

    // outputs indicating which address to sample next
    assign new_address = transistor_count;

    //outputs that are the values from the ADC that would later be used for other parts of the circuit in our assembly code


	wire [7:0] v12;
	wire [7:0] v23;
	wire [7:0] v34;
	wire [7:0] v45;
	wire [7:0] v56;
	wire [7:0] v67;
	wire [7:0] v78;

	wire [2:0] a12;
	wire [2:0] a23;
	wire [2:0] a34;
	wire [2:0] a45;
	wire [2:0] a56;
	wire [2:0] a67;
	wire [2:0] a78;


	assign v12 = register_transistor[0]<register_transistor[1] ? register_transistor[0] : register_transistor[1];
	assign v23 = v12<register_transistor[2] ? v12 : register_transistor[2];
	assign v34 = v23<register_transistor[3] ? v23 : register_transistor[3];
	assign v45 = v34<register_transistor[4] ? v34 : register_transistor[4];
	assign v56 = v45<register_transistor[5] ? v45 : register_transistor[5];
	assign v67 = v56<register_transistor[6] ? v56 : register_transistor[6];
	assign v78 = v67<=register_transistor[7] ? v67 : register_transistor[7];


	assign a12 = register_transistor[0]<register_transistor[1] ? 3'd0 : 3'd1;
	assign a23 = v12<register_transistor[2] ? a12 : 3'd2;
	assign a34 = v23<register_transistor[3] ? a23 : 3'd3;
	assign a45 = v34<register_transistor[4] ? a34 : 3'd4;
	assign a56 = v45<register_transistor[5] ? a45 : 3'd5;
	assign a67 = v56<register_transistor[6] ? a56 : 3'd6;
	assign a78 = v67<register_transistor[7] ? a67 : 3'd7;

	wire [7:0] min_val;

	assign min_val = v78;
	assign min_address = a78;

	assign move_goalie = min_val < 8'd120 ? 1'b1 : 1'b0;

   
    //input that was received by the FPGA from the ADC
    assign transistor_extend[31:8] = 24'd0;
    assign transistor_extend[7:0] = analog_input;
   
    //this is used to latch the data for the specified transistor or resistor value that is currently being sampled by the ADC
    genvar i;
    generate
        for(i = 0; i < 8; i = i + 1) begin: loop_transistor
		  reg_32 transistor_register(transistor_extend, clk_out, regEnable_transistor[i] && output_ready, 1'b0, register_transistor[i]);
        end
    endgenerate
    
endmodule