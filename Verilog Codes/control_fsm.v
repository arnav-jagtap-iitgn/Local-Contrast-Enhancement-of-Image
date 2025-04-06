`timescale 1ns / 1ps
module control_fsm(
input clk,pad_i_c,wf,hc,cdf_c,load,re,load_c,
output reg load_i,pad_i,h_s,cdf_s,show_i,
output reg [14:0]pixcel,
output reg re_win);

parameter   s0=0,//load
            s1=1,//padding image
            s2=2,//window fetch
            s3=3,//histogram
            s4=4,//cdf calculate
            s5=5;//show
reg [2:0]state;   
//integer i;         
always@(posedge clk)
begin
    if(re==1 | load==1)
        begin
        load_i=0;
        pad_i=0;
        pixcel=0;
        h_s=0;
        cdf_s=0;
        show_i=0;
        state=s0;
        re_win=0;
//        i=0;
        end
    else
        begin
        case(state)
        s0:begin
            if(load_c==1)
            state=s1;
            else
            state=s0;
            end
        s1:begin
                if(pad_i_c==1)
                state=s2;
                else
                state=s1;
            end
        s2:begin
                if(pixcel==22500)
                state=s5;
                else if(wf==1)
                state=s3;
                else
                state=s2;
            end
        s3:begin
                if(hc==1)
                state=s4;
                else
                state=s3;
           end
        s4:begin
                if(cdf_c==1)
                begin
//                 if(pixcel==2025)
//                               state=s5;
//                 else              
                               state=s2;
               end
                else
                state=s4;
           end
                     
        endcase
        end        
end


always@(posedge clk)
begin
case(state)
s0:load_i=1;

s1:begin
    load_i=0;
    pad_i=1;
    re_win=1;
   end

s2:begin
    pad_i=0;
    cdf_s=0;
    pixcel=pixcel+1;
    re_win=0;
    end

s3:begin
    h_s=1;
    re_win=0;
    end
    
s4:begin
    cdf_s=1;
    re_win=1;
   end
   
s5:begin
    cdf_s=0;
    show_i=1;
   end
   
endcase
end 

endmodule
