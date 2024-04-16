//图像二值化（自定义阈值）
//作者：xx
//时间：2024-3-23

module im2bw(
    input   clk,
    input   rst_n,

    input                yuv_vsync,
    input                yuv_clken,
    input                yuv_valid,
    input  [7:0]         gray_data,

    output              bw_vsync     ,
    output              bw_clken     ,
    output              bw_data_valid,
    output  [7:0]       bw_data       
);
//定义阈值
parameter THRESHOLD = 30;

reg    yuv_vsync_d;
reg    yuv_clken_d;
reg    yuv_valid_d;
reg    monoc;            

assign  bw_vsync        = yuv_vsync_d;
assign  bw_clken        = yuv_clken_d;
assign  bw_data_valid   = yuv_valid_d;
assign  bw_data         = {8{monoc}};  //将monoc复制8次

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        monoc <= 1'b0;
    else if(gray_data > THRESHOLD)  
        monoc <= 1'b1;
    else
        monoc <= 1'b0;
end

//延时1拍以同步时钟信号
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        yuv_vsync_d <= 1'd0;
        yuv_clken_d <= 1'd0;
        yuv_valid_d <= 1'd0;
    end
    else begin
        yuv_vsync_d <= yuv_vsync;
        yuv_clken_d <= yuv_clken;
        yuv_valid_d <= yuv_valid;
    end
end
endmodule