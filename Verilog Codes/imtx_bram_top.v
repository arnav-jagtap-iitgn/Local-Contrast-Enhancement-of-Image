`timescale 1ns / 1ps

module imtx_bram_top (
    input clk,          // System clock
    input reset,        // Reset signal
    input transmit,     // Start transmission
    output TxD,
    output reg show_i   // Signal to indicate image is ready to display
);

// Define BRAM interface signals
wire [7:0] dout_tx;     // Data output from BRAM
wire [14:0] addr_tx;    // Address to read from BRAM
wire ena_tx, wea_tx;    // BRAM enable and write enable signals
wire [7:0] din_tx;      // Data input (not used, as we only read)

// BRAM instantiation (for image storage)
blk_mem_gen_2  bram(
    .clka(clk),         // Clock input
    .ena(ena_tx),       // Enable signal
    .wea(wea_tx),       // Write enable (always 0 for reading)
    .addra(addr_tx),    // Address input
    .dina(din_tx),      // Data input (unused)
    .douta(dout_tx)     // Data output (pixel value)
);

// Image Transmitter (UART)
img_transfer_uart imtx(
    .clk(clk),
    .reset(reset),
    .transmit(transmit), 
    .TxD(TxD), 
    .ena_tx(ena_tx),
    .wea_tx(wea_tx),
    .addr_tx(addr_tx),
    .din_tx(din_tx),
    .dout_tx(dout_tx)  // Connect BRAM output to UART transmitter
);

// Completion Logic
always @(posedge clk) begin
    if (reset) 
        begin
        show_i <= 0;  // Reset show signal
//        addr_tx<=0;
        end
    else if (addr_tx >= 22499) 
        show_i <= 1;  // Set show_i when full image is transmitted
end

endmodule
