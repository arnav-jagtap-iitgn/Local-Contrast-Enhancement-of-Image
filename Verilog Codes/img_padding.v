`timescale 1ns / 1ps

module img_padding(
    input padding_start,
    output reg padding_completed,
    input clk,
    input [7:0]dout, 
    output reg ren, 
    output reg wen,
    output reg [16:0] addr,
    output reg [7:0] din
);

// for defining image dimensions
parameter img_width = 150;
parameter img_height = 150;
parameter pad_size = 22;
parameter padded_width = img_width + 2 * pad_size;
parameter padded_height = img_height + 2 * pad_size;
parameter tot_pixels = padded_width * padded_height;


reg [7:0] temp;
reg [8:0] row, col;
reg [8:0] newrow, newcol;
reg [2:0] state;
//reg ren, wen;
//reg [16:0] addr;
//reg [7:0] din;
//wire [7:0] dout;

//BRAM inst1(.clk(clk), .en(1), .ren(ren), .wen(wen), .addr(addr), .din(din), .dout(dout));


// FSM for padding the image 
parameter START = 3'b000, READ = 3'b001, IDLE1 = 3'b010, IDLE2 = 3'b011,
          WRITE = 3'b100, IDLE3 = 3'b101, IDLE4 = 3'b110, STOP = 3'b111;
          

always @(posedge clk) begin
    case (state)
        START: begin
            if (padding_start) state <= READ;
            else state <= START;
            addr <= 0;
            din <= 0;
            ren <= 0;
            wen <= 0;
            row <= 21;
            col <= 21;
            newrow <=0;
            newcol <=0;
            padding_completed <= 0;
        end

        READ: begin // Read pixel from original image
            ren <= 1;
            wen <= 0;
            if (row < img_height && col < img_width) 
                addr <= row * img_width + col;
            else 
                state <= WRITE;
            state <= IDLE1;
        end

        IDLE1: state <= IDLE2;
        
        IDLE2: begin
            ren <= 0;
            wen <= 0;
            state <= WRITE;
        end

        WRITE: begin // Applying symmetric padding and storing it to 1D BRAM
            //$display("Reading: Addr=%d, Data=%d", addr, dout);
            temp <= dout;
            wen <= 1;
            ren <= 0;
            addr <= 22500 + newrow * padded_width + newcol;
            din <= temp;
            state <= IDLE3;
        end

        IDLE3: state <= IDLE4;
        
        IDLE4: begin
            ren <= 0;
            wen <= 0;
            
            if (newcol < padded_width - 1) begin
                newcol <= newcol + 1;
                state <= READ;
        
                if (newcol < pad_size)
                    col <= pad_size - 2 - newcol;  // Left padding (20 to 0)
                else if (newcol < pad_size + img_width)
                    col <= newcol - pad_size;      // Original image (0 to 149)
                else 
                    col <= img_width - (newcol - (pad_size + img_width)) - 1;  // Right padding (149 to 127)
            end
            else begin
                newcol <= 0;  // Reset newcol only when a row completes
                
                if (newrow < padded_height - 1) begin
                    newrow <= newrow + 1;
                    state <= READ;
        
                    if (newrow < pad_size) 
                        row <= pad_size - newrow - 2;  // Top padding (20 to 0)
                    else if (newrow < pad_size + img_height) 
                            row <= newrow - pad_size;      // Original image (0 to 149)
                        else 
                            row <= img_height - (newrow - (pad_size + img_height)) - 1; // Bottom padding (149 to 127)
                    end 
                    else begin
                        if ((newrow == padded_height - 1) && (newcol == padded_width - 1)) begin
                            state <= STOP;
                            padding_completed <= 1;
                    end 
                    else begin
                        state <= READ;
                    end
                    end
                end
                $display(dout);
            end
        
 
        STOP: begin
            ren<=1;
            wen<=0;
            padding_completed <= 1;
            state <= STOP;
        end
        
        default: state <= START;
    endcase
end

endmodule
