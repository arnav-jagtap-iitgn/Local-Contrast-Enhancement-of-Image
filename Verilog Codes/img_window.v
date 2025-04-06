`timescale 1ns / 1ps

module img_window(
    input [14:0] make_window, 
    input rst, 
    output reg window_fetched, 
    output reg [16199:0] window, 
    input clk,
    input [7:0] dout,
    output reg ren, 
    output reg wen,
    output reg [16:0] addr,
    output reg [7:0] din
);

// Image dimensions
parameter padded_width = 194;
parameter padded_height = 194;

reg [7:0] temp;
reg [8:0] row, col;
reg [2:0] state;
reg [11:0] i;

wire [14:0] window_index = make_window - 1;

// FSM states
parameter START = 3'b000, READ = 3'b001, IDLE1 = 3'b010, IDLE2 = 3'b011,
          WRITE = 3'b100, STOP = 3'b101;



always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= START;
    end else begin
        case (state)
            START: begin
                if (make_window != 0) state <= READ;
                else state <= START;
                addr <= 0;
                din <= 0;
                ren <= 0;
                wen <= 0;
                row <= window_index / 45;
                col <= window_index % 45;
                i <= 0;
                window_fetched <= 0;
            end

            READ: begin
                if (row < padded_height && col < padded_width) begin
                    ren <= 1;
                    wen <= 0;
                    addr <= 22500 + row * padded_width + col;
                    state <= IDLE1;
                end else begin
                    state <= WRITE; // Handle invalid addresses
                end
            end

            IDLE1: state <= IDLE2;
            
            IDLE2: begin
                ren <= 0;
                wen <= 0;
                state <= WRITE;
            end

            WRITE: begin
                wen <= 0;
                ren <= 0;
                temp <= dout;
                $display("Reading: Addr=%d, Data=%d", addr, dout);
                if (i < 2025) begin
                    window[(i * 8) +: 8] <= temp;  // Bit slicing, may need testing
                    i <= i + 1;
                    
                    if (col >= (window_index % 45) && col < (45 + (window_index % 45))) begin
                        col <= col + 1;
                        state <= READ;
                    end else begin
                        col <= window_index % 45;
                        if (row < (window_index / 45) + 45) begin
                            row <= row + 1;
                            state <= READ;
                        end else begin
                            state <= STOP;
                        end
                    end
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
