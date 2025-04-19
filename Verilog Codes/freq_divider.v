`timescale 1ns / 1ps

module freq_divider(
    input clk,
    output sclk
);

    reg [2:0] count = 3'b000;  // Initialize counter

    always @(posedge clk) begin
        count <= count + 1;   // Use non-blocking assignment
    end

    assign sclk = count[2];   // Output divided clock (clk / 4)

endmodule