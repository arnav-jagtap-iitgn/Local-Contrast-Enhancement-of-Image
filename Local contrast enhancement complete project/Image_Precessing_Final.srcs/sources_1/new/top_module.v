`timescale 1ns / 1ps

module top_module (
    input wire fclk,
    input start,
    input wire re,
    input transfer,trans_re,
    output wire image_done,
    output TxD
);
    wire clk;
    freq_divider fd(fclk,clk);
    // Internal signals
    wire read_complete, padding_complete, hist_complete, cdf_complete;
    wire pad_i,window_fetched;
    wire hist_start, cdf_start, transmit;
    wire [8*2025-1:0] intensity_value;
    wire [11*256-1:0] histogram;
    wire [7:0] new_pixel;
    wire [14:0] pixel_index;
    wire win_re,load_i;
   
    reg ren,wen;
    wire wen_c;
    wire ren_p,wen_p;
    wire ren_w;
    wire wen_tx;
    
    
    
    reg [16:0] addr;
    reg [7:0]din;
    wire [7:0]dout;
    
//    wire [16:0] addr_i;
//    wire [7:0]din_i;
    
    wire[16:0] addr_p;
    wire [7:0]din_p;
    
    wire[16:0] addr_c;
    wire [7:0]din_c;
       
    wire [16:0] addr_w;
//    wire [7:0]din_w;
    
    wire [16:0] addr_tx;
    wire [7:0]din_tx;
 
 //    assign ren=ren_w|ren_p;
    //    assign wen=wen_c|wen_p;
   
    always@(transfer,ren_tx,ren_w,ren_c,ren_p,wen_c,wen_p,addr_p,din_p,addr_c,din_c,addr_w,addr_tx,din_tx,pad_i,cdf_start,win_re)
    begin
    if(transfer==1)
    begin
                    addr=addr_tx;
                            din=din_tx;
                           ren=ren_tx;
                         wen = 1'b0;
                               end
    else
    
    case({pad_i,cdf_start,win_re})
        4'b100:begin  addr=addr_p;
                       din=din_p;
                       ren=ren_p;
                       wen=wen_p;
                    end
        4'b010:begin addr=addr_c;
                      din=din_c;
                      wen=wen_c;
                      ren=ren_c;
                                end
        4'b001:begin    addr=addr_w;
                         ren=ren_w;
                          wen = 0;
                            din = 0;

                   end
        default:begin
                addr = 0;
            din = 0;
            ren = 0;
            wen = 0;
            end
          endcase
          end
    

     BRAM  inst1(.clk(clk), .en(1'b1), .ren(ren), .wen(wen), .addr(addr), .din(din), .dout(dout));

        // Controller FSM instance
    control_fsm fsm_inst (
        .clk(clk),
        .pad_i_c(padding_complete),
        .wf(window_fetched),
        .hc(hist_complete),
        .cdf_c(cdf_complete),
        .re(re),
        .load_c(start),
        .load_i(load_i),
        .pad_i(pad_i),
        .h_s(hist_start),
        .cdf_s(cdf_start),
        .show_i(image_done),
        .pixcel(pixel_index),
        .re_win(win_re)
    );
    
      // Image Padding instance
      img_padding padding_img(
          .padding_start(pad_i),
          .padding_completed(padding_complete),
          .clk(clk),
          .dout(dout), 
          .ren(ren_p), 
          .wen(wen_p),
          .addr(addr_p),
          .din(din_p)
      );
 wire ren1_w,wen1_w,ren1_h,wen1_h;
 wire [10:0] addr1_w,addr1_h ;
 wire [7:0] din1_w,din1_h,dout1;
 reg ren1,wen1;
 reg [7:0]din1;
 reg [10:0]addr1;
 
     always@(hist_start,win_re,ren1_w,wen1_w,din1_w,addr1_w,ren1_h,wen1_h,addr1_h,din1_h)
     begin
     if(win_re==1)begin
        ren1= ren1_w;
        wen1= wen1_w;
        addr1= addr1_w;
        din1= din1_w;
                end
     else if(hist_start==1) begin
        ren1= ren1_h;
        wen1= wen1_h;
        din1 = 1'b0;
        addr1 = addr1_h;
       end
        else
        begin
            ren1 = 0;
            wen1 = 0;
            din1 = 0;
            addr1 = 0;
            end
      end
   
 bram_window  inst2(.clk(clk), .en(1'b1), .ren(ren1), .wen(wen1), .addr(addr1), .din(din1), .dout(dout1));
wire wen_w;   
     img_window window_inst(
                    .make_window(pixel_index), 
                    .rst_window(win_re), 
                    .window_fetched(window_fetched),
                    .clk(clk),
                    .dout(dout),
                    .ren(ren_w), 
                    .wen(wen_w),
                    .addr(addr_w),
                    .ren1(ren1_w), 
                    .wen1(wen1_w),
                    .addr1(addr1_w),
                    .din1(din1_w)
                );
    
    
    // Histogram Calculation instance
    histogram_calculator hist_inst(
        .clk(clk),
        .hist_start(hist_start),
        .hist_completed(hist_complete),          
        .Count(histogram),
        .ren(ren1_h),
        .wen(wen1_h),
        .addr(addr1_h),
        .dout1(dout1)        
    );
    
    // CDF Calculation instance
    cdf_normalise cdf_inst (
        .clk(clk),
        .cdf_start(cdf_start),
        .histo(histogram),
        .cdf_completed(cdf_complete),
        .index(pixel_index),
        .ren(ren_c),
        .wen(wen_c),
        .addr(addr_c),
        .din(din_c),
        .dout(dout)
    );
    
    // UART Image Transfer instance
   img_transfer_uart uart(
        .clk(fclk), //UART input clock
        .reset(trans_re), // reset signal
        .transmit(transfer), //btn signal to trigger the UART communication
        .TxD(TxD), // Transmitter serial output. TxD will be held high during reset, or when no transmissions aretaking place 
        .ea_tx(ren_tx),
        .addr_tx(addr_tx),
        .din_tx(din_tx),
        .dout_tx(dout)
    );

endmodule