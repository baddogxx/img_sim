
`timescale 1ns / 1ps

module mean_filter(
    input clk,
    input rst_n,

    input [23:0] pre_data,
    input per_vsync,
    input per_href,
    input per_clken,
    
    output [23:0] post_data,
    output post_vsync,
    output post_href,
    output post_clken
);

//-----------------------------
//generate 3×3 picture matrix
//-----------------------------
wire matrix_frame_clken;
wire matrix_frame_href;
wire matrix_frame_vsync;
wire [7:0] matrix_p11;
wire [7:0] matrix_p12;
wire [7:0] matrix_p13;
wire [7:0] matrix_p21;
wire [7:0] matrix_p22;
wire [7:0] matrix_p23;
wire [7:0] matrix_p31;
wire [7:0] matrix_p32;
wire [7:0] matrix_p33;

VIP_matrix_generate u_VIP_matrix_generate(
    .clk                ( clk                ),
    .rst_n              ( rst_n              ),
    .per_frame_vsync    ( per_vsync   	 	 ),
    .per_frame_href     ( per_href           ),
    .per_frame_clken    ( per_clken      	 ),
    .per_img_Y          ( pre_data[7:0]      ),
    .matrix_frame_vsync ( matrix_frame_vsync ),
    .matrix_frame_href  ( matrix_frame_href  ),
    .matrix_frame_clken ( matrix_frame_clken ),
    .matrix_p11         ( matrix_p11         ),
    .matrix_p12         ( matrix_p12         ),
    .matrix_p13         ( matrix_p13         ),
    .matrix_p21         ( matrix_p21         ),
    .matrix_p22         ( matrix_p22         ),
    .matrix_p23         ( matrix_p23         ),
    .matrix_p31         ( matrix_p31         ),
    .matrix_p32         ( matrix_p32         ),
    .matrix_p33         ( matrix_p33         )
);

//-----------------------------
//mean filter function
//-----------------------------
reg [11:0] add_p1;
reg [11:0] add_p2;
reg [11:0] add_p3;
reg [11:0] add_all;
//step1:add every href
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)begin
        add_p1<=12'd0;
        add_p2<=12'd0;
        add_p3<=12'd0;
    end
    else begin
      add_p1<=matrix_p11+matrix_p12+matrix_p13;
      add_p2<=matrix_p21+matrix_p23;
      add_p3<=matrix_p31+matrix_p32+matrix_p33;
    end
end
//step2:add all the data
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)begin
        add_all<=12'd0;
    end
    else begin
        add_all<=add_p1+add_p2+add_p3;
    end
end
//step3:shift to get mean filter data
assign post_data={3{add_all[10:3]}};

//-----------------------------
//clk signal synchronization
//-----------------------------
reg [1:0] post_clken_dy;
reg [1:0] post_href_dy;
reg [1:0] post_vsync_dy;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)begin
        post_clken_dy<=2'd0;
        post_href_dy<=2'd0;
        post_vsync_dy<=2'd0;
    end
    else begin
        post_clken_dy<={post_clken_dy[0],matrix_frame_clken};
        post_href_dy<={post_href_dy[0],matrix_frame_href};
        post_vsync_dy<={post_vsync_dy[0],matrix_frame_vsync};
    end
end
assign post_clken=post_clken_dy[1];
assign post_href=post_href_dy[1];
assign post_vsync=post_vsync_dy[1];

endmodule 

