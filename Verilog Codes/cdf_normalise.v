`timescale 1ns / 1ps
module cdf_normalise(
    input cdf_start,
    input [14:0] index,
    input clk,
    input [11*256-1:0] histo,  // Single packed vector (2048 bits)
    output reg [11*256-1:0] cdf, // Single packed vector (2048 bits)
    output reg cdf_completed,
    output reg  ren,
    output reg wen,
    output reg [16:0] addr,
    output reg [7:0] din,
    input [7:0] dout
);
reg [3:0]state=0;
reg [7:0] intensity;//to access intensity value from bram
reg [14:0] temp1;


parameter n = 256;
integer k;
integer cdf_min=0; // Minimum CDF value for normalization
integer cdf_255=0; // Store cdf[255] for normalization
integer temp_cdf=0; // Temporary variable for carry-aware addition
integer ddout=0;
//BRAM inst1(.clk(clk), .en(1), .ren(ren), .wen(wen), .addr(addr), .din(din), .dout(dout));

always @(posedge clk) begin
case(state)
0:
begin
    if(cdf_start)begin
    state<=1;
    ///////////////////////
    cdf[10:0] = histo[10:0]; // Initialize CDF
    cdf_min = cdf[10:0];

    for (k = 1; k < n; k = k + 1) begin
        // Perform 8-bit addition using a wider integer
        temp_cdf = cdf[(k-1)*11 +: 11] + histo[k*11 +: 11];  
        cdf[k*11 +: 11] = temp_cdf[10:0]; // Store only lower 8 bits

        if (cdf[k*11 +: 11] < cdf_min) 
            cdf_min = cdf[k*11 +: 11]; // Track minimum CDF value
    end
    
        cdf_255 = cdf[255*11 +: 11]; // Store cdf[255] for normalization
        
    // Normalization process
    for (k = 0; k < n; k = k + 1) begin
        if (cdf_255 > cdf_min) begin
            temp_cdf = ((cdf[k*11 +: 11] - cdf_min) * 255) / (cdf_255 - cdf_min);
            cdf[k*11 +: 11] = temp_cdf[10:0]; // Store only the lower 8 bits
        end else begin
            cdf[k*11 +: 11] = 0; // Avoid division by zero
        end
    end
    end //start end
    ///////////////////////
    else 
    begin
    state<=0;
    cdf_completed<=0;
    end
    cdf_completed<=0;
    ren<=0;
    wen<=0;
    addr<=0;
    din <= 0;   
    temp1<=index;                                                                                                                                                                                
end//0
1:
begin
    ren<=1;
    wen<=0;
    addr<=index;
    state<=2;       
end
2://idel state-1
begin
    state<=3;
end
3://idel state-2
begin
    ren<=0;
    state<=4;
end
4: // Output state
begin
//    if (histo[dout] < 256) // Prevent out-of-bounds access
//        intensity <= cdf[ddout*11-1:ddout*11-11];
        intensity = 0; // Default value
    for (ddout = 0; ddout < 256; ddout= ddout+ 1) begin
        if (ddout == dout) begin
            intensity = cdf[ddout*11 +: 11]; // Extract 11-bit segment
        end
    end
//    else 
//        intensity <= 0; // Assign a default value
    
    state <= 5; // Ensure FSM progresses
    //bram simulation
//    xx<=dout;
end


5: // write state
begin
    din <= intensity;
    $display(intensity);
    wen <= 1;
    ren <= 0;
    addr <= (60136+index);//first addrs
    state <= 6;
end 
        
6: // idle3 state
begin
    state <= 7;
end 
        
7: // idle4 state 
begin
    ren <= 0;
    wen <= 0;
    state <= 8;
end
8:
begin
//    state<=0;
    if(temp1!=index) begin
    state<=0;
    end
    cdf_completed<=1;
//    xx<=dout;
end
default: state <= 0;

endcase

end//always

endmodule