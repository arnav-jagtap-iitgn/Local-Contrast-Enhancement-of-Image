`timescale 1ns / 1ps
module tb_top_module();
reg clk,start,re,transf,trans_re;
wire image_done, TxD;

top_module uut(clk,start,re,transf,trans_re,image_done, TxD);
initial 
begin
clk=0;
forever #5 clk=~clk;
end
initial
begin
re=1;
#10 re=0;
#10 start=1;
#10000000;
if(image_done==1)
   begin trans_re=1;
   #10     trans_re=0;
   #10 transf=1;
          end
#5000;
$finish;
end
endmodule
