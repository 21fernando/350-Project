module counter_32_tb();

    reg clk;
    reg en;
    reg rst;
    wire [4:0] count;

    counter_32 counter(.clk(clk), .en(en), .rst(rst), .count(count));

    initial begin 
        $dumpfile("counter_32.vcd");
        $dumpvars(0, counter_32_tb);
    end
    
    initial begin
        clk = 1'b0;
        en = 1'b0;
        rst = 1'b0;
        #5;
        rst = 1'b1;
        #1;
        rst = 1'b0;
        #5;
        en=1'b1;
        #200;
        $finish;
    end

    always #1 clk = ~clk;

    always @(clk, en, rst) begin
        #1
        $display("rst = %b, en = %b => count = %b", rst, en, count);
    end


endmodule