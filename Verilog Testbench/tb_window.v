`timescale 1ns / 1ps

module tb_window();
reg [14:0] make_window;
reg rst;
wire window_fetched;
wire [16199:0]window;
reg clk;
reg padding_start;
wire padding_completed;
reg [7:0] dout1;
wire ren1;
wire wen1;
wire [16:0] addr1;
wire [7:0] din1;

img_window uut2(make_window, rst, window_fetched, window, clk);

initial begin
    clk <= 0;
    forever #1 clk <= ~clk;
end

initial begin
    make_window <= 0;     
    padding_start <= 0; #10;
    
    padding_start <= 1;
    #500000;
    
    make_window <= 1;
    #500000;
    
    $finish();
end

endmodule
