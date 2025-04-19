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
            else begin
                addr <= 0;
                din <= 0;
                ren <= 0;
                wen <= 0;
                row <= 21;
                col <= 21;
                newrow <=0;
                newcol <=0;
                padding_completed <= 0;
                state <= START;
            end
        end

        READ: begin // Read pixel from original image
            ren <= 1;
            wen <= 0;
            if (row < img_height && col < img_width) 
                // 1st iteration 21*150 + 21 = 3171 
                addr <= row * img_width + col; 
            else 
                state <= WRITE;
            state <= IDLE1;
        end

        IDLE1: state <= IDLE2;
        
        IDLE2: begin
            state <= WRITE;
        end

        WRITE: begin // Applying symmetric padding and storing it to 1D BRAM
            wen <= 1;
            ren <= 0;
            // 1st iteration addr=0
            // 22500 + 0 +1 =22501
            addr <= 22500 + newrow * padded_width + newcol;
            din = dout;
            state <= IDLE3;
        end

        IDLE3: state <= IDLE4;
        
        IDLE4: begin
            ren <= 0;
            wen <= 0;
            
            if (newcol < padded_width - 1) begin
                newcol = newcol + 1;// 1st iter newcol = 1 
                state = READ;
        
                if (newcol < pad_size)
                    // 1st iteration col = 22 -1 -1 =20
                    col = pad_size - 1 - newcol;  // Left padding (20 to 0)
                else if (newcol < pad_size + img_width)
                    // 1st iteration col = 22-22 =0
                    col = newcol - pad_size;      // Original image (0 to 149)
                else 
                    // 1st iteration col = 150 -(172- (22+150))-1=149
                    col = img_width - (newcol - 172) - 1;  // Right padding (149 to 127)
            end
            else begin
                newcol <= 0;  // Reseting newcol only when a row completes
                
                if (newrow < padded_height - 1) begin
                    newrow = newrow + 1;
                    state = READ;
        
                    if (newrow < pad_size) 
                        // 1st iteration col = 22 -1 -1 =20
                        // last iteration col = 22-21-1 =0
                        row = pad_size - newrow - 1;  // Top padding (20 to 0)
                    else if (newrow < pad_size + img_height) 
                            row = newrow - pad_size;      // Original image (0 to 149)
                        else 
                            row = img_height - (newrow - 172) - 1; // Bottom padding (149 to 127)
                    end 
                    else begin
                        if ((newrow == padded_height - 1) && (newcol == padded_width - 1)) begin
                            state = STOP;
                            padding_completed = 1;
                    end 
                    else begin
                        state = READ;
                    end
                    end
                end
               
            end
        
 
        STOP: begin
            ren<=0;
            wen<=0;
            padding_completed <= 1;
            state <= STOP;
        end
        
        default: state <= START;
    endcase
end

endmodule
