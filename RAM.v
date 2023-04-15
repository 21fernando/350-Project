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
    input wire                     IO_wEn,
    input wire [ADDRESS_WIDTH-1:0] addr,
    input wire [ADDRESS_WIDTH-1:0] IO_addr,
    input wire [DATA_WIDTH-1:0]    dataIn,
    input wire [DATA_WIDTH-1:0]    IO_dataIn,
    output reg [DATA_WIDTH-1:0]    dataOut = 0,
    output reg [DATA_WIDTH-1:0]    IO_dataOut = 0
    );
    
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
    
    //IO memory accesses
    always @(posedge clk) begin
        if(IO_wEn) begin
            MemoryArray[IO_addr] <= IO_dataIn;
        end else begin
            IO_dataOut <= MemoryArray[IO_addr];
        end
    end
endmodule
