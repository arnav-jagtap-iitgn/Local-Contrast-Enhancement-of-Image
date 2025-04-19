`timescale 1ns / 1ps

module tb_padding_img();

reg clk;
reg padding_start;
wire padding_completed;
integer i;

img_padding uut(padding_start, padding_completed, clk);

initial begin
    clk <= 0;
    forever #1 clk <= ~clk;
end

initial begin
    padding_start <= 0; #10;
    
    padding_start <= 1;
    #500000;
    

    $finish();
end

endmodule
