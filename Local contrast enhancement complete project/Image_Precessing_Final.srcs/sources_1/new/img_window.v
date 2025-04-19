`timescale 1ns / 1ps

module img_window(
    input [14:0] make_window, 
    input rst_window, 
    output reg window_fetched,
    input clk,
    input [7:0] dout,
    output reg ren, 
    output reg wen,
    output reg [16:0] addr,
    output reg [7:0] din,
    input [7:0] dout1,
    output reg ren1, 
    output reg wen1,
    output reg [10:0] addr1,
    output reg [7:0] din1
);

// Image dimensions
parameter padded_width = 194;
parameter padded_height = 194;
parameter window_size = 45; // 45x45 window

reg [8:0] row, col;
reg [2:0] state;
reg [11:0] i;

wire [14:0] window_index = make_window-1;

// FSM states
parameter START = 3'b000, READ = 3'b001, IDLE1 = 3'b010, IDLE2 = 3'b011,
          WRITE = 3'b100, IDLE3 = 3'b101, IDLE4 = 3'b110, STOP = 3'b111;

// Calculate window position
wire [7:0] window_col = window_index % 150;  // 150 windows per row (194-45+1)
wire [7:0] window_row = window_index / 150;  // 150 windows per column

always @(posedge clk) begin
    if (rst_window==0) begin
        state <= START;
        window_fetched <= 0;
    end else begin
        case (state)
            START: begin
                if (rst_window==1) state <= READ;
                else state <= START;
                addr <= 0;
                din <= 0;
                ren <= 0;
                wen <= 0;
                // Initialize row and col to top-left of window
                row <= window_row;
                col <= window_col;
                i <= 0;
                window_fetched <= 0;
                addr1 <= 0;
                din1 <= 0;
                ren1 <= 0;
                wen1 <= 0;
            end

            READ: begin
                if (row < padded_height && col < padded_width) begin
                    ren <= 1;
                    wen <= 0;
                    ren1 <= 0;
                    wen1 <= 0;
                    addr <= 22500 + row * padded_width + col;
                    state <= IDLE1;
                end else begin
                    state <= IDLE1; // Handle invalid addresses
                end
            end

            IDLE1: state <= IDLE2;
            
            IDLE2: begin              
                state <= WRITE;
            end

            WRITE: begin
                wen <= 0;
                ren <= 0;
                wen1 <= 1;
                ren1 <= 0;
                addr1 <= i;
                din1 <= dout;
                state <= IDLE3;
            end
            
            IDLE3: state <= IDLE4;
            
            IDLE4: begin
                ren1 <= 0;
                wen1 <= 0;
                
                if (i < 2024) begin  // 45*45-1 = 2024
                    i <= i + 1;
                    
                    // Move to next column in window
                    if (col < window_col + window_size - 1) begin
                        col <= col + 1;
                    end else begin
                        // Move to next row, first column in window
                        col <= window_col;
                        row <= row + 1;
                    end
                    state <= READ;
                end else begin
                    state <= STOP;
                end
             end

            STOP: begin
                window_fetched <= 1;
                state <= STOP;
            end
            
            default: state <= START;
        endcase
    end
end

endmodule