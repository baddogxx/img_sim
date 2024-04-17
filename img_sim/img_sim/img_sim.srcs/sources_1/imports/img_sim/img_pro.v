//图像处理顶层模块，目前包括模块：rgb转灰度、二值化
//Author:baddog
//Time:2024-3-23

//ip修改测试标志 终极版11

`timescale 1ns / 1ps

module img_pro(
    input        clk            ,       //时钟
    input        rst_n          ,       //复位
    //图像输入      
    input                   img_vs_in      ,       //场同步信号
    input                   img_clken_in   ,       //图像数据使能信号
    input                   data_valid_in  ,       //图像数据有效信号
    input [23:0]            img_data_in    ,       //图像数据输入
    //输出
    output   reg            img_vs_out    ,    //场同步信号
	output   reg            img_clken_out ,    //图像数据使能信号
	output   reg            data_valid_out,    //图像数据有效信号
    output   reg  [23:0]    img_data_out        //图像数据输出
);

//灰度输出
wire [7:0]  gray_data;
wire        yuv_vsync;
wire        yuv_clken;
wire        yuv_valid;

//二值化输出
wire [7:0]  bw_data;
wire        bw_vsync;
wire        bw_clken;
wire        bw_valid;

//膨胀输出
wire [7:0]  dilation_data;
wire        dilation_vsync;
wire        dilation_clken;
wire        dilation_valid;

//rgb转灰度
rgb2yuv ins_rgb2yuv(
    .clk        (clk)           ,
    .rst_n      (rst_n)         ,

    .rgb_vsync  (img_vs_in)     ,       
    .rgb_clken  (img_clken_in)  ,       
    .rgb_valid  (data_valid_in) ,       
    .rgb_data   (img_data_in  ) ,       

    .gray_data  (gray_data)     ,
    .yuv_vsync  (yuv_vsync)     ,
    .yuv_clken  (yuv_clken)     ,
    .yuv_valid  (yuv_valid)         
);
//二值化
im2bw ins_im2bw(
	.clk               (clk),
	.rst_n             (rst_n),
                   
	.yuv_vsync   (yuv_vsync),
	.yuv_clken   (yuv_clken),
	.yuv_valid   (yuv_valid),
	.gray_data   (gray_data),

    .bw_vsync      (bw_vsync),
	.bw_clken      (bw_clken),
	.bw_data_valid (bw_valid),
	.bw_data       (bw_data)
);
//膨胀
dilation ins_dilation(
    .clk               (clk),
	.rst_n             (rst_n),
                 
	.in_vsync         (bw_vsync),
	.in_clken         (bw_clken),
	.in_valid         (bw_valid),
	.in_data          (bw_data),



    .out_vsync        (dilation_vsync),
	.out_clken        (dilation_clken),
	.out_valid        (dilation_valid),
	.out_data         (dilation_data)
);

// 处理结果输出时序
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        img_data_out    <= 24'b0;
        data_valid_out  <= 1'b0;
    end
    else  begin        
        img_data_out    <= {3{gray_data}};
        data_valid_out  <=    yuv_valid;
        img_vs_out      <=    yuv_vsync;
        img_clken_out   <=    yuv_clken;
    end
     
end


endmodule   