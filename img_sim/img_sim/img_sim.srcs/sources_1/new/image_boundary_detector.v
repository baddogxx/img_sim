`timescale 1ns / 1ps

module image_boundary_detector(
    input clk,
    input rst_n,
    input fs,
    input hs,
    input pixel_valid,
    input pixel_data, // 1 for white (foreground), 0 for black (background)

    output reg [8:0] top_bound,
    output reg [8:0] bottom_bound,
    output reg [9:0] left_bound,
    output reg [9:0] right_bound
);


    reg [8:0] current_top = 480; 
    reg [8:0] current_bottom = 0;
    reg [9:0] current_left = 640;
    reg [9:0] current_right = 0;


    reg [8:0] hang_cnt ;
    reg [9:0] lie_cnt ; 

//判断当前像素在第几行 第几�?
reg [8:0] row_counter = 0;     //行计�?
reg [9:0] col_counter = 0;     //列计�?
// 内部状�?�，记录上一周期的同步信号状�?
reg last_fs, last_hs;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // 复位时清零计数器和状�?
        row_counter <= 0;
        col_counter <= 0;
        last_fs <= 0;
        last_hs <= 0;
        hang_cnt <= 0;
        lie_cnt  <= 0;
    end else begin
        // 更新状�?�记�?
        last_fs <= fs;
        last_hs <= hs;

        if (fs && !last_fs) begin
            // �?测到场同步信号的上升�?
            row_counter <= 0;
            col_counter <= 0;
        end else if (hs && !last_hs) begin
            // �?测到行同步信号的上升�?
            col_counter <= 0;
            row_counter <= row_counter + 1;
        end else if (hs) begin
            // 在没有同步信号的普�?�时钟周期，递增列计数器
            col_counter <= col_counter + 1;
        end
    end
    hang_cnt <= row_counter;
    lie_cnt  <= col_counter;
end

always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            top_bound <= 480;
            bottom_bound <= 0;
            left_bound <= 640;
            right_bound <= 0;
            current_top <= 480;
            current_bottom <= 0;
            current_left <= 640;
            current_right <= 0;
        end 
        else if (pixel_valid && pixel_data) begin
                // Update current boundaries based on pixel data
                if (row_counter < current_top) current_top <= row_counter;
                if (row_counter > current_bottom) current_bottom <= row_counter;
                if (col_counter < current_left) current_left <= col_counter;
                if (col_counter > current_right) current_right <= col_counter;
            end
            
            // Update output registers at the end of a frame
            else if (!fs && last_fs) begin
                top_bound <= current_top;
                bottom_bound <= current_bottom;
                left_bound <= current_left;
                right_bound <= current_right;
            end
end
endmodule
