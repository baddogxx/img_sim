//rgb888转灰度
//作者：xx
//时间：2024-3-22

`timescale 1ns / 1ps
module rgb2yuv(
    input           clk,
    input           rst_n,

    input           rgb_vsync,      
    input           rgb_clken,      //图像使能信号
    input           rgb_valid,      //图像有效信号
    input   [23:0]  rgb_data,       

    output          yuv_vsync,
    output          yuv_clken,
    output          yuv_valid,
    output  [7:0]   gray_data
);



reg [15:0]  rgb_r0, rgb_r1, rgb_r2;
reg [15:0]  rgb_g0, rgb_g1, rgb_g2;
reg [15:0]  rgb_b0, rgb_b1, rgb_b2;
reg [15:0]  yuv_y0;
reg [15:0]  yuv_cb0;
reg [15:0]  yuv_cr0;
reg [7:0]  yuv_y1;
reg [7:0]  yuv_cb1;
reg [7:0]  yuv_cr1;
reg [2:0]  rgb_vsync_d;
reg [2:0]  rgb_clken_d;
reg [2:0]  rgb_valid_d;

wire [7:0]  rgb_r;
wire [7:0]  rgb_g;
wire [7:0]  rgb_b;
wire [7:0]  yuv_y;
wire [7:0]  yuv_cb;
wire [7:0]  yuv_cr;


//取出r g b各个分量
assign  rgb_r = rgb_data[23:16];
assign  rgb_g = rgb_data[15:8];
assign  rgb_b = rgb_data[7:0];
//同步三个信号
assign  yuv_vsync = rgb_vsync_d;
assign  yuv_clken = rgb_clken_d;
assign  yuv_valid = rgb_valid_d;
assign  yuv_y     = yuv_clken ? yuv_y1  : 8'd0;
assign  yuv_cb    = yuv_clken ? yuv_cb1 : 8'd0;
assign  yuv_cr    = yuv_clken ? yuv_cr1 : 8'd0;
assign  gray_data = yuv_y;

//第一个时钟周期，乘法计算
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
      rgb_r0 <= 16'd0;
      rgb_r1 <= 16'd0;
      rgb_r2 <= 16'd0;
      rgb_g0 <= 16'd0;
      rgb_g1 <= 16'd0;
      rgb_g2 <= 16'd0;
      rgb_b0 <= 16'd0;
      rgb_b1 <= 16'd0;
      rgb_b2 <= 16'd0;
    end
    else begin
      rgb_r0 <= rgb_r * 8'd77;
      rgb_r1 <= rgb_r * 8'd43;
      rgb_r2 <= rgb_r * 8'd128;
      rgb_g0 <= rgb_g * 8'd150;
      rgb_g1 <= rgb_g * 8'd85;
      rgb_g2 <= rgb_g * 8'd107;
      rgb_b0 <= rgb_b * 8'd29;
      rgb_b1 <= rgb_b * 8'd128;
      rgb_b2 <= rgb_b * 8'd21;
    end
end

//第二个时钟周期 加法运算
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
      yuv_y0  <= 16'd0;
      yuv_cb0 <= 16'd0;
      yuv_cr0 <= 16'd0;
    end
    else begin
      yuv_y0  <= rgb_r0 + rgb_g0 + rgb_b0;
      yuv_cb0 <= rgb_b1 - rgb_g1 - rgb_b1 + 16'd32768;
      yuv_cr0 <= rgb_r2 - rgb_g2 - rgb_b2 + 16'd32768;
    end
end

//第三个时钟周期 右移8位
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        yuv_y1  <= 8'd0;
        yuv_cb1 <= 8'd0;
        yuv_cr1 <= 8'd0;
    end
    else begin
        yuv_y1  <= yuv_y0  [15:8];
        yuv_cb1 <= yuv_cb0 [15:8];
        yuv_cr1 <= yuv_cr0 [15:8];
    end
end

//打三拍同步信号
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        rgb_vsync_d <= 3'd0;
        rgb_clken_d <= 3'd0;
        rgb_valid_d <= 3'd0;
    end
    else begin
        rgb_vsync_d <= {rgb_vsync_d [1:0],rgb_vsync};
        rgb_clken_d <= {rgb_clken_d [1:0],rgb_clken};
        rgb_valid_d <= {rgb_valid_d [1:0],rgb_valid};
    end
end


endmodule

