`timescale 1ns / 1ps
module control_fsm_tb;
reg clk,pad_i_c,wf,hc,cdf_c,load,re,load_c;
wire load_i,pad_i,h_s,cdf_s,show_i,re_win;
wire [14:0]pixcel;


control_fsm  uut(clk,pad_i_c,wf,hc,cdf_c,re,load_c,load_i,pad_i,h_s,cdf_s,show_i,re_win,pixcel);

initial 
begin
clk=0;
forever #5 clk=~clk;
end

initial
begin
re=1;
load=1;
#10;
re=0;
load=0;
#10
load_c=1;
#10;
end
always
begin
#40;
load_c=0;
pad_i_c=1;
#10;
pad_i_c=0;
wf=1;
#10;
wf=0;
hc=1;
#10;
hc=0;
cdf_c=1;#10;
cdf_c=0;
if(control_fsm.pixcel==22500)
#30$finish;
end
endmodule