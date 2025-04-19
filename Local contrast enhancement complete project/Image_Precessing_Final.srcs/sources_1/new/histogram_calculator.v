`timescale 1ns / 1ps

module histogram_calculator(   
    input  clk,                  
    input  hist_start,              
    output reg hist_completed,                                                     
    output reg [11*256-1 : 0] Count,
    output reg ren,
    output reg wen,
    output reg [10:0] addr,
//    output reg [7:0] din,
    input [7:0] dout1         
);   
    reg [11:0] pixel;                                                                           
//    parameter A=, B=2'b01, C=2'b10, D=3;   
    reg [2:0] state;      
    reg [7:0] intensity;     
    reg [10:0] i=0; 
//    reg [7:0] window;                          
    initial begin      
        hist_completed = 0;                         
        pixel = 0;                                    
    end 

    always @ (posedge clk) begin  
    if (hist_start==0) begin 
        state<=0;
        hist_completed=0; 
    end 
    else begin  
        case (state) 
             0: begin 
                if (hist_start ==1)begin
                    state<=1;
                    i=0;
                    pixel = 0;
                    Count = 0;                   
                end
                else begin
                    pixel = 0;
                    Count = 0;                   
                    state <= 0;
                    i=0; 
                end  
            end 

            1:begin
                ren=1;
                wen=0;
                if(i<2025)addr =i;
                i=i+1;
                state = 2;
            end
            2:state = 3;//idel state
            3:begin//idel state
                ren = 0;
                state = 4;
            end
            4:begin
                intensity=dout1;
                state = 5;
            end
            
            
            
            5: begin
                if (pixel < 2024) begin  
                    pixel = pixel + 1;                
                    Count[(intensity * 11) +: 11] = Count[(intensity * 11) +: 11] + 1;    
                    state=1; 
                end 
                else begin
                    state = 6;   
                end  
            end     

            6: begin      
                hist_completed <=1;
                state<=6;
            end    
        endcase 
      end 
    end
endmodule