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


//叠加
wire         add_vsync;
wire         add_href ;
wire         add_valid;
wire [23:0]  add_data ;

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
	.gray_data   (gray_data ),

    .bw_vsync      (bw_vsync),
	.bw_clken      (bw_clken),
	.bw_data_valid (bw_valid),
	.bw_data       (bw_data)
);


 //最大连通域标记
 max_domain u_max_domain(
     .clk       (clk       ),
     .rst_n     (rst_n     ),

     .tem_vsync (bw_vsync ),       //开运算结果送入连通检测模块
     .tem_href  (bw_clken  ),       
     .tem_valid (bw_valid ),       
     .tem_data  (bw_data  ),       

     .in_vsync  (yuv_vsync ),        //待叠加的灰度图像输入
     .in_valid  (yuv_valid ),
     .in_href   (yuv_clken ),
     .in_data   (gray_data ),

     .out_vsync (add_vsync ),
     .out_valid (add_valid ),
     .out_href  (add_href  ),
     .out_data  (add_data  ),

     .center_x  (center_x  ),
     .center_y  (center_y  )
 );




// 处理结果输出时序
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        img_data_out    <= 24'b0;
        data_valid_out  <= 1'b0;
    end
    else  begin        
        img_vs_out      <=    add_vsync ;
        img_clken_out   <=    add_href  ;
        data_valid_out  <=    add_valid ;
        img_data_out    <=    add_data  ;

        // img_vs_out      <=    bw_vsync ;
        // img_clken_out   <=    bw_clken  ; 
        // data_valid_out  <=    bw_valid ;
        // img_data_out    <= {3{bw_data}};
    end
     
end


endmodule   