
`timescale 1ns/1ps
//最大连通区域检测、坐标输出
//作者：xx
//时间：2024-4-1

module max_domain(
    input           clk,
    input           rst_n,

    wire        tem_vsync,
    wire        tem_href ,
    wire        tem_valid,
    wire [7:0]  tem_data ,

    input         in_vsync,  
    input         in_valid,  
    input         in_href,  
    input [7:0]   in_data ,  
    
    output              out_vsync, 
    output              out_valid, 
    output              out_href, 
    output reg [23:0]   out_data  , 
  
    output  reg [8:0]   center_x    ,    //中心坐标x输出
    output  reg [8:0]   center_y         //中心坐标y输出
);



//连通域检测模块输入

wire   [8:0]   in_up           ;    // 上边界输入
wire   [8:0]   in_dowm         ;    // 下边界输入
wire   [8:0]   in_left         ;    // 左边界输入
wire   [8:0]   in_right        ;    // 右边界输入
wire   [19:0]  pixel_num       ;    // 像素数量

//连通域检测模块
connect_domain_get u_connect_domain_get(
    .clk        (clk        ),
    .rst_n      (rst_n      ),

    .e_le       (in_left    ),
    .e_ri       (in_right   ),
    .e_upm      (in_up      ),
    .e_dw       (in_dowm    ),
    .e_num_gray (pixel_num  ),

    .fs         (tem_vsync ),
    .hs         (tem_href  ),
    .in_valid   (tem_valid ),
    .data       (tem_data  )

);


//判断当前像素在第几行 第几列
reg [10:0] row_counter = 0;     //行计数
reg [10:0] col_counter = 0;     //列计数
reg [9:0] hang_cnt ,lie_cnt ; 

// 内部状态，记录上一周期的同步信号状态
reg last_vsync, last_href;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // 复位时清零计数器和状态
        row_counter <= 0;
        col_counter <= 0;
        last_vsync <= 0;
        last_href <= 0;
        hang_cnt <= 0;
        lie_cnt  <= 0;
    end else begin
        // 更新状态记录
        last_vsync <= in_vsync;
        last_href <= in_href;

        if (in_vsync && !last_vsync) begin
            // 检测到场同步信号的上升沿
            row_counter <= 0;
            col_counter <= 0;
        end else if (in_href && !last_href) begin
            // 检测到行同步信号的上升沿
            col_counter <= 0;
            row_counter <= row_counter + 1;
        end else if (in_href) begin
            // 在没有同步信号的普通时钟周期，递增列计数器
            col_counter <= col_counter + 1;
        end
    end
    hang_cnt <= row_counter-1;
    lie_cnt  <= col_counter;
      
end


// 存储最大连通域及其对应的边界
reg [19:0] max_pixel_num;

reg [8:0]   out_up      ;
reg [8:0]   out_dowm    ;
reg [8:0]   out_left    ;
reg [8:0]   out_right   ;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_up          <= 0;
        out_dowm        <= 0;
        out_left        <= 0;
        out_right       <= 0;
        max_pixel_num   <= 0;
        center_x        <= 0;
        center_y        <= 0;
    end else begin
        if (pixel_num > max_pixel_num) begin
            // 更新最大像素数量
            max_pixel_num <= pixel_num;
            // 更新输出边界
            out_up      <= in_up;
            out_dowm    <= in_dowm;
            out_left    <= in_left;
            out_right   <= in_right;
            // 计算中心点坐标
            center_x <= (out_left + out_right) >> 1;  // 取x中心值
            center_y <= (out_up + out_dowm) >> 1;    // 取y中心值
        end
    end
end

// //叠加红色矩形
// always @(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//         out_data  <= 8'b0;
//     end 
//     else begin
//         if ((hang_cnt == out_up) || (hang_cnt == out_dowm)) begin
//             out_data <= 24'hFF0000;     //输出红色像素
//         end else if ((lie_cnt == out_left) || (lie_cnt == out_right)) begin
//             out_data <= 24'hFF0000;     //输出红色像素
//         end
//         else begin
//         out_data  <= {3{in_data}};
//         end
//     end 
// end

//叠加红色矩形
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_data  <= 8'b0;
    end 
    else begin
        if ((hang_cnt == 100) || (hang_cnt == 100)) begin
            out_data <= 24'hFF0000;     //输出红色像素
        end else if ((lie_cnt == 100) || (lie_cnt == 100)) begin
            out_data <= 24'hFF0000;     //输出红色像素
        end
        else begin
        out_data  <= {3{in_data}};
        end
    end 
end

//控制信号同步


endmodule

