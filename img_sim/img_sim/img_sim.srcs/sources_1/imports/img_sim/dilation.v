`timescale 1ns / 1ps
//ͼ������
//���ߣ�xx
//ʱ�䣺2024-3-26


module dilation(
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
wire [7:0]  row1_1; //3X3 ��������
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
    
    //Ԥ����Ҷ�����
    .per_frame_vsync    (in_vsync),
    .per_frame_href     (in_clken), 
    .per_frame_clken    (in_valid),
    .per_img_Y          (in_data ),
    
    //���3x3����
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

//����
reg mid;

//step1:add every href
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)begin
         mid <= 0;
    end
    else begin
        mid <= row1_1 || row1_2 || row1_3 || row2_1 || row2_2 || row2_3 || row3_1 || row3_2 || row3_3;
    end
end

//
assign out_data = {8{mid}};

//�ź���ʱͬ��
// reg [1:0] post_clken_dy;
// reg [1:0] post_href_dy;
// reg [1:0] post_vsync_dy;
// always @(posedge clk or negedge rst_n) begin
//     if(~rst_n)begin
//         post_clken_dy <=2'd0;
//         post_href_dy  <=2'd0;
//         post_vsync_dy <=2'd0;
//     end
//     else begin
//         post_clken_dy<={post_clken_dy[0],matrix_frame_clken};
//         post_href_dy<={post_href_dy[0],matrix_frame_href};
//         post_vsync_dy<={post_vsync_dy[0],matrix_frame_vsync};
//     end
// end
// assign out_valid = post_clken_dy[1];
// assign out_clken  = post_href_dy[1];
// assign out_vsync = post_vsync_dy[1];

//��ʱһ������
reg post_clken_dy;
reg post_href_dy;
reg post_vsync_dy;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        // ����Ϊ 0
        post_clken_dy <= 1'b0;
        post_href_dy <= 1'b0;
        post_vsync_dy <= 1'b0;
    end else begin
        // ��ʱһ��ʱ������
        post_clken_dy <= matrix_frame_clken;
        post_href_dy  <= matrix_frame_href;
        post_vsync_dy <= matrix_frame_vsync;
    end
end

// ֱ�ӴӼĴ����������ʱ����ź�
assign out_valid = post_clken_dy;
assign out_clken = post_href_dy;
assign out_vsync = post_vsync_dy;
endmodule 










// module dilation(
//     input clk                   ,
//     input rst_n                 ,

//     input          in_vsync     ,
//     input          in_clken     ,
//     input          in_valid     ,
//     input  [7:0]   in_data      ,
//     output         out_vsync    ,
//     output         out_clken    ,
//     output         out_valid    ,
//     output  [7:0]  out_data 
// );

// //-----------------------------
// //generate 3��3 picture matrix
// //-----------------------------
// wire matrix_frame_clken;
// wire matrix_frame_href;
// wire matrix_frame_vsync;
// wire  row1_1;
// wire  row1_2;
// wire  row1_3;
// wire  row2_1;
// wire  row2_2;
// wire  row2_3;
// wire  row3_1;
// wire  row3_2;
// wire  row3_3;

// matrix_generate3x3 u_matrix_generate3x3(
//     .clk                ( clk                ),
//     .rst_n              ( rst_n              ),

//     .per_frame_vsync    ( in_vsync   	 	 ),
//     .per_frame_href     ( in_clken          ),
//     .per_frame_clken    ( in_valid      	 ),
//     .per_img_Y          ( in_data          ),

//     .matrix_frame_vsync ( matrix_frame_vsync ),
//     .matrix_frame_href  ( matrix_frame_href  ),
//     .matrix_frame_clken ( matrix_frame_clken ),

//     .matrix_p11         ( row1_1         ),
//     .matrix_p12         ( row1_2         ),
//     .matrix_p13         ( row1_3         ),
//     .matrix_p21         ( row2_1         ),
//     .matrix_p22         ( row2_2         ),
//     .matrix_p23         ( row2_3         ),
//     .matrix_p31         ( row3_1         ),
//     .matrix_p32         ( row3_2         ),
//     .matrix_p33         ( row3_3         )
// );

// // reg  row1_1, row1_2, row1_3, row2_1, row2_2, row2_3, row3_1, row3_2, row3_3;

// // assign row1_1 = matrix_p11;
// // assign row1_2 = matrix_p12;
// // assign row1_3 = matrix_p13;
// // assign row2_1 = matrix_p21;
// // assign row2_2 = matrix_p22;
// // assign row2_3 = matrix_p23;
// // assign row3_1 = matrix_p31;
// // assign row3_2 = matrix_p32;
// // assign row3_3 = matrix_p33;

// reg mid;

// //step1:add every href
// always @(posedge clk or negedge rst_n) begin
//     if(~rst_n)begin
//          mid <= 0;
//     end
//     else begin
//         mid <= row1_1 || row1_2 || row1_3 || row2_1 || row2_2 || row2_3 || row3_1 || row3_2 || row3_3;
//     end
// end

// //
// assign out_data = {8{mid}};

// //-----------------------------
// //clk signal synchronization
// //-----------------------------
// reg [1:0] post_clken_dy;
// reg [1:0] post_href_dy;
// reg [1:0] post_vsync_dy;
// always @(posedge clk or negedge rst_n) begin
//     if(~rst_n)begin
//         post_clken_dy <=2'd0;
//         post_href_dy  <=2'd0;
//         post_vsync_dy <=2'd0;
//     end
//     else begin
//         post_clken_dy<={post_clken_dy[0],matrix_frame_clken};
//         post_href_dy<={post_href_dy[0],matrix_frame_href};
//         post_vsync_dy<={post_vsync_dy[0],matrix_frame_vsync};
//     end
// end
// assign out_valid = post_clken_dy[1];
// assign out_clken  = post_href_dy[1];
// assign out_vsync = post_vsync_dy[1];

// endmodule 







// module dilation(
//  input               clk         ,
//  input               rst_n       ,

//     input          in_vsync     ,
//     input          in_clken     ,
//     input          in_valid      ,
//     input  [7:0]   in_data          ,

//     output         out_vsync    ,
//     output         out_clken    ,
//     output   reg   out_valid     ,
//     output  [7:0]  out_data  

// );


// wire    [7:0]   row1_data_r;     //��shift_ram���յĵ�һ�л��� ���ص�����
// wire    [7:0]   row2_data_r;

// wire    [7:0]   row1_data;      //3�л���
// wire    [7:0]   row2_data;
// wire    [7:0]   row3_data;

// //�������ݴ洢
// assign  row1_data = row1_data_r;
// assign  row2_data = row2_data_r;
// assign  row3_data = in_data;


// //3*3����
// reg  [7:0]   row1_1;
// reg  [7:0]   row1_2;
// reg  [7:0]   row1_3;
// reg  [7:0]   row2_1;
// reg  [7:0]   row2_2;
// reg  [7:0]   row2_3;
// reg  [7:0]   row3_1;
// reg  [7:0]   row3_2;
// reg  [7:0]   row3_3;


// reg     [2:0]   vld;    //��Чֵ  --��ʱ�����о���
// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n)
//       vld <= 3'b0;
//     else
//       vld <= {vld[1:0], in_valid};  //����
// end


// // 0����ˮ == ���л���
// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         row1_1 <= 1'b0; row1_2 <= 1'b0; row1_3 <= 1'b0;
//         row2_1 <= 1'b0; row2_2 <= 1'b0; row2_3 <= 1'b0;
//         row3_1 <= 1'b0; row3_2 <= 1'b0; row3_3 <= 1'b0;
//     end
//     else if(vld[0]) begin                   //��in_data��ʼ�ͽ�����ˮ�ߴ���û�еľͲ�0��ֱ��ĩβ��--> in_data == out_data
//         row1_1 <= row1_data;    row1_2 <= row1_1;   row1_3 <= row1_2; 
//         row2_1 <= row2_data;    row2_2 <= row2_1;   row2_3 <= row2_2;    
//         row3_1 <= row3_data;    row3_2 <= row3_1;   row3_3 <= row3_2;       
//     end
// end

// //=================================================================
// //                �����㷨���岿��
// //=================================================================

// // һ����ˮ === ���а�λ��

// reg [7:0] p_row1;
// reg [7:0] p_row2;
// reg [7:0] p_row3;

// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         p_row1 <= 8'd0;
//         p_row2 <= 8'd0;
//         p_row3 <= 8'd0;
//     end
//     else if(vld[1]) begin
//         p_row1 <= row1_1 | row1_2 | row1_3;
//         p_row2 <= row2_1 | row2_2 | row2_3;
//         p_row3 <= row3_1 | row3_2 | row3_3;
//     end
// end

// // ������ˮ === ��λ����
// reg [7:0]   p_mid_out;
// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n)
//         p_mid_out <= 8'd0;
//     else if(vld[2])
//         p_mid_out <= p_row1 | p_row2 | p_row3;
// end

// assign out_data = p_mid_out;

// // vld_out
// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n)
//         out_valid <= 1'b0;
//     else
//         out_valid <= vld[2];
// end


// //�����ź���ʱ����ʱ������
// reg [3:0] out_vsync_r;
// reg [3:0] out_clken_r;

// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         out_vsync_r <= 4'b0;
//         out_clken_r <= 4'b0;
//     end
//     else begin
//         out_vsync_r <=  {out_vsync_r[2:0],in_vsync};
//         out_clken_r <=  {out_clken_r[2:0],in_clken};
//     end
// end

// assign out_vsync = out_vsync_r[3];
// assign out_clken = out_clken_r[3];



// //�л���ģ��
// shift_RAM_3X3_8bit u_shift_RAM_0 (
//   .D(in_data),              // input wire [7 : 0] D
//   .CLK(clk),            // input wire CLK
//   .SCLR(~rst_n),        // input wire SCLR
//   .Q(row2_data_r)       // output wire [7 : 0] Q
// );

// shift_RAM_3X3_8bit u_shift_RAM_1(
//   .D(row2_data_r),      // input wire [7 : 0] D
//   .CLK(clk),            // input wire CLK
//   .SCLR(~rst_n),        // input wire SCLR
//   .Q(row1_data_r)       // output wire [7 : 0] Q
// );

// endmodule





// module dilation(    
//     input   clk,
//     input   rst_n,

//     input          in_vsync,
//     input          in_clken,
//     input          in_valid,
//     input  [7:0]   in_data,

//     output         out_vsync     ,
//     output         out_clken     ,
//     output   reg   out_valid     ,
//     output  [7:0]  out_data       
// );

// //ʹ�õ��������ݽ��д���
// wire    in_data_1bit ;
// assign  in_data_1bit = in_data[0];
// reg     out_data_1bit;
// assign  out_data = {8{out_data_1bit}};

// wire    row1_data_r;      //��shift_ram���յĵ�һ�л���  
// wire    row2_data_r;      //�ڶ��л���

// wire    row1_data;   
// wire    row2_data;
// wire    row3_data;

// //������������
// assign  row1_data = row1_data_r;         //��һ�л��棨��shift_ram1��ȡ��
// assign  row2_data = row2_data_r;         //�ڶ��л��棨Ҳ��shift_ram0��ȡ��
// assign  row3_data = in_data_1bit;        //�ӵ�ǰ�����ȡ

// //3*3����  1_1�����Ͻǵ�һ�����أ� 3_3�����½����һ�����ص�
// reg  row1_1, row1_2, row1_3, row2_1, row2_2, row2_3, row3_1, row3_2, row3_3;

// reg [1:0] vid;      //��Ч�ź�

// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n)
//          vid <= 2'b0;
//     else
//         vid <= {vid[0],in_valid};
// end
// //��һ������ �������л���
// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         row1_1 <= 1'b0; row1_2 <= 1'b0; row1_3 <= 1'b0;
//         row2_1 <= 1'b0; row2_2 <= 1'b0; row2_3 <= 1'b0;
//         row3_1 <= 1'b0; row3_2 <= 1'b0; row3_3 <= 1'b0;
//     end
//     else if (vid[0]) begin
//         row1_1 <= row1_data;    row1_2 <= row1_1;   row1_3 <= row1_2; 
//         row2_1 <= row2_data;    row2_2 <= row2_1;   row2_3 <= row2_2;    
//         row3_1 <= row3_data;    row3_2 <= row3_1;   row3_3 <= row3_2;  
//     end
// end

// reg mid_out;

// //�ڶ������ڣ������
// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         out_data_1bit <= 1'b0;
//     end
//     else if (vid[1]) begin
//          out_data_1bit <= row1_1 || row1_2 || row1_3 || row2_1 || row2_2 || row2_3 || row3_1 || row3_2 || row3_3;
//     end
// end

// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n)
//         out_valid <= 1'b0;
//     else
//         out_valid <= vid[1];
// end

// //�����ź���ʱ����ʱ������
// reg [2:0] out_vsync_r;
// reg [2:0] out_clken_r;

// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         out_vsync_r <= 3'b0;
//         out_clken_r <= 3'b0;
//     end
//     else begin
//         out_vsync_r <=  {out_vsync_r[1:0],in_vsync};
//         out_clken_r <=  {out_clken_r[1:0],in_clken};
//     end
// end

// assign out_vsync = out_vsync_r[2];
// assign out_clken = out_clken_r[2];

// //�����ź���ʱһ���������
// // reg out_vsync_r;
// // reg out_clken_r;

// // always @(posedge clk or negedge rst_n) begin
// //     if(!rst_n) begin
// //         out_vsync_r <= 1'b0;
// //         out_clken_r <= 1'b0;
// //     end
// //     else begin
// //         out_vsync_r <= in_vsync ;
// //         out_clken_r <= in_clken ;
// //     end
// // end

// // assign out_vsync = out_vsync_r;
// // assign out_clken = out_clken_r;

// //�л���ģ��
// shift_RAM_3X3_1bit ins_shift_RAM_0 (
//   .D(in_data_1bit),         // input wire  D
//   .CLK(clk),                // input wire CLK
//   .SCLR(~rst_n),            // input wire SCLR
//   .Q(row2_data_r)           // output wire  Q
// );

// shift_RAM_3X3_1bit ins_shift_RAM_1(
//   .D(row2_data_r),          // input wire  D
//   .CLK(clk),                // input wire CLK
//   .SCLR(~rst_n),            // input wire SCLR
//   .Q(row1_data_r)           // output wire  Q
// );

// endmodule

