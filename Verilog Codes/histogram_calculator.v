`timescale 1ns / 1ps

module histogram_calculator (
input wire clk,                                                                                               // Clock signal                                                                                            // Reset (active high)
input wire hist_start,                                                                                     // Start signal
input [8*2025-1:0] intensity_value,                                                             // 2025 intensity values, 8 bits each
output reg hist_completed,                                                                           // indication for completion
output reg [11*256-1 : 0] Count                                                                   // Single packed array (256 bins, 11-bit each)
);

integer i;
reg [7:0] intensity;                                                                                         // I am taking the 8-bit intensity value to store

always @(posedge clk) begin
    if (hist_start) begin
          for (i = 0; i < 2025; i = i + 1) begin                                                     // Iterates through every pixel upto 2045 times and extracts the 8 bits from every pixels
                 intensity = intensity_value[i*8 +: 8];                                           // [i*8 +: 8] this is the bit slicing method wich extracts 8 bits starting from i*8
                 Count[intensity*11 +: 11] <= Count[intensity*11 +: 11] + 1;     // Updates the coount of corresponding intensity
          end
    hist_completed <= 1;
    end
end
endmodule 
