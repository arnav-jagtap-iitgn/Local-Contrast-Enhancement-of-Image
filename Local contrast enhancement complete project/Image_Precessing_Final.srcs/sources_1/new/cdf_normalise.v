`timescale 1ns / 1ps
module cdf_normalise(
    input cdf_start,
    input [14:0] index,
    input clk,
    input [11*256-1:0] histo,
    output reg cdf_completed,
    output reg ren,
    output reg wen,
    output reg [16:0] addr,
    output reg [7:0] din,
    input [7:0] dout
);

reg [3:0] state = 0;
reg [7:0] intensity;
reg [14:0] temp1;
reg [11*256-1:0] cdf;
reg [10:0] cdf_min;
parameter n = 256;
reg [8:0] i = 0;

parameter START = 4'b0000, CDF = 4'b0001, NORMALISE = 4'b0010, READ = 4'b0011,
          IDLE1 = 4'b0100, IDLE2 = 4'b0101, COMP = 4'b0110, WRITE= 4'b0111,
          IDLE3=4'b1000,IDLE4=4'b1001,STOP=4'b1010;

always @(posedge clk) begin
    case (state)
        START: begin
            if (cdf_start) state <=CDF;
            else begin
            cdf_completed = 0;
            ren <= 0;
            wen <= 0;
            addr <= 0;
            din <= 0;
            temp1 <= index;
            state<=START;
            end
            cdf_completed = 0;
        end
        
        
        CDF:begin
                if (i == 0) begin
                    cdf[10:0] = histo[10:0];
                    cdf_min=cdf[10:0];
                    i = i + 1;
                end else if (i < n) begin
                    cdf[i*11 +: 11] = cdf[(i-1)*11 +: 11] + histo[i*11 +: 11];
                    i = i + 1;
                    if(!cdf_min) cdf_min=cdf[i*11 +: 11];
                end

                if (i == n) begin
                    i = 0;
                    state<=NORMALISE ;
                end
                else state<=CDF;
            end
            
        NORMALISE: begin
            if (i < n) begin
                if(cdf[255*11 +: 11] - cdf_min>0)begin
                cdf[i*11 +: 11] = (((cdf[i*11 +: 11] - cdf_min) * 255)+((cdf[255*11 +: 11] - cdf_min)/2)) / (cdf[255*11 +: 11] - cdf_min);
                end
                else cdf[i*11 +: 11]=0;
                i = i + 1;
            end
            if (i == n) begin
                i = 0;
                state <= READ;
            end
            else state<=NORMALISE;
        end
        
        
        READ: begin
            ren <= 1;
            wen <= 0;
            if(0<=index<=22500)addr <= index-1;
            else state<=WRITE;
            state <= IDLE1;
        end

        IDLE1: state <= IDLE2;
        
        IDLE2: begin
            state <= COMP;
        end
        COMP: begin
            intensity = cdf[dout*11 +: 11];
            ren <= 0;
//            $display(intensity);
            state <= WRITE;        
        end
        WRITE: begin
            wen <= 1;
            ren <= 0;
            addr <= 60135 + index;
            din <= intensity;
            state <= IDLE3;
        end

        IDLE3: state <= IDLE4;

        IDLE4: begin
            ren <= 0;
            wen <= 0;
            state <=STOP ;
        end

        STOP: begin
            if (temp1 != index)
                state = START;
            else state<=STOP;
            cdf_completed <= 1;
        end

        

        default: state <= START;
    endcase
end

endmodule