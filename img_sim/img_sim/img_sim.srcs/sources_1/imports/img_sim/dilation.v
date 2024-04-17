`timescale 1ns / 1ps
//图像膨胀
//作者：xx
//时间：2024-3-26

module dilation(
 input               clk         ,
 input               rst_n       ,

    input          in_vsync     ,
    input          in_clken     ,
    input          in_valid      ,
    input  [7:0]   in_data          ,

    output         out_vsync    ,
    output         out_clken    ,
    output   reg   out_valid     ,
    output  [7:0]  out_data  

);


wire    [7:0]   row1_data_r;     //从shift_ram接收的第一行缓存 像素点数据
wire    [7:0]   row2_data_r;

wire    [7:0]   row1_data;      //3行缓存
wire    [7:0]   row2_data;
wire    [7:0]   row3_data;

//三行数据存储
assign  row1_data = row1_data_r;
assign  row2_data = row2_data_r;
assign  row3_data = in_data;


//3*3窗口
reg  [7:0]   row1_1;
reg  [7:0]   row1_2;
reg  [7:0]   row1_3;
reg  [7:0]   row2_1;
reg  [7:0]   row2_2;
reg  [7:0]   row2_3;
reg  [7:0]   row3_1;
reg  [7:0]   row3_2;
reg  [7:0]   row3_3;


reg     [2:0]   vld;    //有效值  --延时（待研究）
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
      vld <= 3'b0;
    else
      vld <= {vld[1:0], in_valid};  //左移
end


// 0级流水 == 三行缓存
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        row1_1 <= 1'b0; row1_2 <= 1'b0; row1_3 <= 1'b0;
        row2_1 <= 1'b0; row2_2 <= 1'b0; row2_3 <= 1'b0;
        row3_1 <= 1'b0; row3_2 <= 1'b0; row3_3 <= 1'b0;
    end
    else if(vld[0]) begin                   //从in_data开始就进行流水线处理，没有的就补0，直到末尾数--> in_data == out_data
        row1_1 <= row1_data;    row1_2 <= row1_1;   row1_3 <= row1_2; 
        row2_1 <= row2_data;    row2_2 <= row2_1;   row2_3 <= row2_2;    
        row3_1 <= row3_data;    row3_2 <= row3_1;   row3_3 <= row3_2;       
    end
end

//=================================================================
//                膨胀算法主体部分
//=================================================================

// 一级流水 === 各行按位或

reg [7:0] p_row1;
reg [7:0] p_row2;
reg [7:0] p_row3;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        p_row1 <= 8'd0;
        p_row2 <= 8'd0;
        p_row3 <= 8'd0;
    end
    else if(vld[1]) begin
        p_row1 <= row1_1 | row1_2 | row1_3;
        p_row2 <= row2_1 | row2_2 | row2_3;
        p_row3 <= row3_1 | row3_2 | row3_3;
    end
end

// 二级流水 === 按位或结果
reg [7:0]   p_mid_out;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        p_mid_out <= 8'd0;
    else if(vld[2])
        p_mid_out <= p_row1 | p_row2 | p_row3;
end

assign out_data = p_mid_out;

// vld_out
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        out_valid <= 1'b0;
    else
        out_valid <= vld[2];
end


//控制信号延时两个时钟周期
reg [3:0] out_vsync_r;
reg [3:0] out_clken_r;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_vsync_r <= 4'b0;
        out_clken_r <= 4'b0;
    end
    else begin
        out_vsync_r <=  {out_vsync_r[2:0],in_vsync};
        out_clken_r <=  {out_clken_r[2:0],in_clken};
    end
end

assign out_vsync = out_vsync_r[3];
assign out_clken = out_clken_r[3];



//行缓存模块
shift_RAM_3X3_8bit u_shift_RAM_0 (
  .D(in_data),              // input wire [7 : 0] D
  .CLK(clk),            // input wire CLK
  .SCLR(~rst_n),        // input wire SCLR
  .Q(row2_data_r)       // output wire [7 : 0] Q
);

shift_RAM_3X3_8bit u_shift_RAM_1(
  .D(row2_data_r),      // input wire [7 : 0] D
  .CLK(clk),            // input wire CLK
  .SCLR(~rst_n),        // input wire SCLR
  .Q(row1_data_r)       // output wire [7 : 0] Q
);

endmodule





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

// //使用单比特数据进行处理
// wire    in_data_1bit ;
// assign  in_data_1bit = in_data[0];
// reg     out_data_1bit;
// assign  out_data = {8{out_data_1bit}};

// wire    row1_data_r;      //从shift_ram接收的第一行缓存  
// wire    row2_data_r;      //第二行缓存

// wire    row1_data;   
// wire    row2_data;
// wire    row3_data;

// //三行数据连接
// assign  row1_data = row1_data_r;         //第一行缓存（从shift_ram1获取）
// assign  row2_data = row2_data_r;         //第二行缓存（也从shift_ram0获取）
// assign  row3_data = in_data_1bit;        //从当前输入获取

// //3*3窗口  1_1是左上角第一个像素， 3_3是右下角最后一个像素点
// reg  row1_1, row1_2, row1_3, row2_1, row2_2, row2_3, row3_1, row3_2, row3_3;

// reg [1:0] vid;      //有效信号

// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n)
//          vid <= 2'b0;
//     else
//         vid <= {vid[0],in_valid};
// end
// //第一个周期 构建三行缓存
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

// //第二个周期，与操作
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

// //控制信号延时两个时钟周期
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

// //控制信号延时一个周期输出
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

// //行缓存模块
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

