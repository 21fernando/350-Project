`timescale 1ns / 1ps
//Output address are written to by the CPU, are read from through the read ports 
//Input addresses are written to from devices, are read by CPU through memory
//Memory Mapping Scheme:
//Address 4095 = Stepper Control Register (Output)
//Address 4094 = Other (Output)
//Address 4093 = Other (Output)
//Address 4092 = Other (Output)
//Address 4091 = Other (Output)
//Address 4090 = Phototransistors (Input)
//Address 4089 = Beam Break Sensor (Input)
//Address 4088 = Other (Input)
//Address 4087 = Other (Input)
//Address 4086 = Other (Input)
module RAM #( parameter DATA_WIDTH = 32, ADDRESS_WIDTH = 12, DEPTH = 4096) (
    input wire                     clk,
    input wire                     wEn,
    input wire [ADDRESS_WIDTH-1:0] addr,
    input wire [4:0]               IO_wEn,
    input wire [DATA_WIDTH-1:0]    IO_input_1,
    input wire [DATA_WIDTH-1:0]    IO_input_2,
    input wire [DATA_WIDTH-1:0]    IO_input_3,
    input wire [DATA_WIDTH-1:0]    IO_input_4,
    input wire [DATA_WIDTH-1:0]    IO_input_5,
    input wire [DATA_WIDTH-1:0]    dataIn,
    output reg [DATA_WIDTH-1:0]    dataOut = 0, 
    output reg [DATA_WIDTH-1:0]    IO_output_1 = 0,
    output reg [DATA_WIDTH-1:0]    IO_output_2 = 0,
    output reg [DATA_WIDTH-1:0]    IO_output_3 = 0,
    output reg [DATA_WIDTH-1:0]    IO_output_4 = 0,
    output reg [DATA_WIDTH-1:0]    IO_output_5 = 0);
    
    reg[DATA_WIDTH-1:0] MemoryArray[0:DEPTH-1];
    
    integer i;
    initial begin
        for (i = 0; i < DEPTH; i = i + 1) begin
            MemoryArray[i] <= 0;
        end
        // if(MEMFILE > 0) begin
        //     $readmemh(MEMFILE, MemoryArray);
        // end
    end
    
    //Normal CPU memory accesses
    always @(posedge clk) begin
        if(wEn) begin
            MemoryArray[addr] <= dataIn;
        end else begin
            dataOut <= MemoryArray[addr];
        end
    end

    //IO read ports for devices
    always @(posedge clk) begin
        IO_output_1 <= MemoryArray[4091];
        IO_output_2 <= MemoryArray[4092];
        IO_output_3 <= MemoryArray[4093];
        IO_output_4 <= MemoryArray[4094];
        IO_output_5 <= MemoryArray[4095];
    end

    //IO write ports for devices
    always @(posedge clk) begin
        if(IO_wEn[0]) begin
            MemoryArray[4086] <= IO_input_1;
        end
        if(IO_wEn[1]) begin
            MemoryArray[4087] <= IO_input_2;
        end
        if(IO_wEn[2]) begin
            MemoryArray[4088] <= IO_input_3;
        end
        if(IO_wEn[3]) begin
            MemoryArray[4089] <= IO_input_4;
        end
        if(IO_wEn[4]) begin
            MemoryArray[4090] <= IO_input_5;
        end
    end
endmodule
