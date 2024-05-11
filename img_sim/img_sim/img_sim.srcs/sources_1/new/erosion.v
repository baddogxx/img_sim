`timescale 1ns / 1ps
//图像腐蚀
//作者：xx
//时间：2024-4-18


module erosion(
    input        clk,  
    input        rst_n,

    input         in_vsync,  
    input         in_valid,  
    input         in_clken,  
    input [7:0]   in_data ,  
    
    output        out_vsync, 
    output        out_valid, 
    output        out_clken, 
    output [7:0]  out_data   
);

//wire define
wire        matrix_frame_vsync;
wire        matrix_frame_href;
wire        matrix_frame_clken;
wire [7:0]  row1_1; //3X3 矩阵数据
wire [7:0]  row1_2; 
wire [7:0]  row1_3;
wire [7:0]  row2_1; 
wire [7:0]  row2_2; 
wire [7:0]  row2_3;
wire [7:0]  row3_1; 
wire [7:0]  row3_2; 
wire [7:0]  row3_3;



//wire  row1_1, row1_2, row1_3, row2_1, row2_2, row2_3, row3_1, row3_2, row3_3;

 matrix_generate_3x3_8bit u_matrix_generate_3x3_8bit(
    .clk        (clk), 
    .rst_n      (rst_n),
    
    //预处理灰度数据
    .per_frame_vsync    (in_vsync),
    .per_frame_href     (in_valid), 
    .per_frame_clken    (in_clken),
    .per_img_Y          (in_data ),
    
    //输出3x3矩阵
    .matrix_frame_vsync (matrix_frame_vsync),
    .matrix_frame_href  (matrix_frame_href),
    .matrix_frame_clken (matrix_frame_clken),
    .matrix_p11         (row1_1),    
    .matrix_p12         (row1_2),    
    .matrix_p13         (row1_3),
    .matrix_p21         (row2_1),    
    .matrix_p22         (row2_2),    
    .matrix_p23         (row2_3),
    .matrix_p31         (row3_1),    
    .matrix_p32         (row3_2),    
    .matrix_p33         (row3_3)
);

//计算
reg mid;

//step1:add every href
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)begin
         mid <= 0;
    end
    else begin
        mid <= row1_1 && row1_2 && row1_3 && row2_1 && row2_2 && row2_3 && row3_1 && row3_2 && row3_3;
    end
end

//
assign out_data = {8{mid}};



//延时一个周期
reg post_clken_dy;
reg post_href_dy;
reg post_vsync_dy;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        // 重置为 0
        post_clken_dy <= 1'b0;
        post_href_dy <= 1'b0;
        post_vsync_dy <= 1'b0;
    end else begin
        // 延时一个时钟周期
        post_clken_dy <= matrix_frame_clken;
        post_href_dy <= matrix_frame_href;
        post_vsync_dy <= matrix_frame_vsync;
    end
end

// 直接从寄存器中输出延时后的信号
assign out_valid = post_href_dy;
assign out_clken = post_clken_dy;
assign out_vsync = post_vsync_dy;
endmodule 



