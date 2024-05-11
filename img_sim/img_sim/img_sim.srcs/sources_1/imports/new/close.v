`timescale 1ns / 1ps
//闭运算（先膨胀后腐蚀）
//作者：xx
//时间：2024-4-18


module close(
    input clk                   ,
    input rst_n                 ,

    input          in_vsync     ,
    input          in_href      ,
    input          in_valid     ,
    input  [7:0]   in_data      ,
    
    output         out_vsync    ,
    output         out_href     ,
    output         out_valid    ,
    output  [7:0]  out_data 
);

//膨胀输出
wire        dilation_vsync ;
wire        dilation_href  ;
wire        dilation_valid ;
wire [7:0]  dilation_data  ;

//膨胀例化
dilation u_dilation(
    .clk       (clk       ),
    .rst_n     (rst_n     ),

    .in_vsync  (in_vsync),
    .in_clken  (in_href ),
    .in_valid  (in_valid),
    .in_data   (in_data ),

    .out_vsync (dilation_vsync),
    .out_clken (dilation_href ),
    .out_valid (dilation_valid),
    .out_data  (dilation_data )
);

//腐蚀例化
erosion u_erosion(
    .clk       (clk       ),
    .rst_n     (rst_n     ),

    .in_vsync  (dilation_vsync  ),
    .in_clken  (dilation_href   ),
    .in_valid  (dilation_valid  ),
    .in_data   (dilation_data   ),
    
    .out_vsync (out_vsync),
    .out_clken (out_href ),
    .out_valid (out_valid),
    .out_data  (out_data )
);



endmodule
