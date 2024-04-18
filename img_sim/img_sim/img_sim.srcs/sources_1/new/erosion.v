`timescale 1ns / 1ps
//图像腐蚀
//作者：xx
//时间：2024-4-18


module erosion(
    input clk                   ,
    input rst_n                 ,

    input          in_vsync     ,
    input          in_clken     ,
    input          in_valid     ,
    input  [7:0]   in_data      ,
    
    output         out_vsync    ,
    output         out_clken    ,
    output         out_valid    ,
    output  [7:0]  out_data 
);

//-----------------------------
//generate 3×3 picture matrix
//-----------------------------
wire matrix_frame_clken;
wire matrix_frame_href;
wire matrix_frame_vsync;
wire  row1_1;
wire  row1_2;
wire  row1_3;
wire  row2_1;
wire  row2_2;
wire  row2_3;
wire  row3_1;
wire  row3_2;
wire  row3_3;

matrix_generate3x3 u_matrix_generate3x3(
    .clk                ( clk                ),
    .rst_n              ( rst_n              ),

    .per_frame_vsync    ( in_vsync   	 	 ),
    .per_frame_href     ( in_clken          ),
    .per_frame_clken    ( in_valid      	 ),
    .per_img_Y          ( in_data          ),

    .matrix_frame_vsync ( matrix_frame_vsync ),
    .matrix_frame_href  ( matrix_frame_href  ),
    .matrix_frame_clken ( matrix_frame_clken ),

    .matrix_p11         ( row1_1         ),
    .matrix_p12         ( row1_2         ),
    .matrix_p13         ( row1_3         ),
    .matrix_p21         ( row2_1         ),
    .matrix_p22         ( row2_2         ),
    .matrix_p23         ( row2_3         ),
    .matrix_p31         ( row3_1         ),
    .matrix_p32         ( row3_2         ),
    .matrix_p33         ( row3_3         )
);

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

//信号同步
reg [1:0] post_clken_dy;
reg [1:0] post_href_dy;
reg [1:0] post_vsync_dy;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)begin
        post_clken_dy <=2'd0;
        post_href_dy  <=2'd0;
        post_vsync_dy <=2'd0;
    end
    else begin
        post_clken_dy<={post_clken_dy[0],matrix_frame_clken};
        post_href_dy<={post_href_dy[0],matrix_frame_href};
        post_vsync_dy<={post_vsync_dy[0],matrix_frame_vsync};
    end
end
assign out_valid = post_clken_dy[1];
assign out_clken  = post_href_dy[1];
assign out_vsync = post_vsync_dy[1];

endmodule 


