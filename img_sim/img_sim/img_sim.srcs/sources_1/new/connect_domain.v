`timescale 1ns/1ps

module connect_domain_get(
        input                        clk          ,
        input                        rst_n        ,

        input                        fs           ,
        input                        hs           ,
        input                        in_valid     ,
        input      [7:0]             data         ,

        output reg [9:0]             e_label      ,
        output reg [9:0]             e_le         ,
        output reg [9:0]             e_ri         ,
        output reg [8:0]             e_upm        ,
        output reg [8:0]             e_dw         ,
        output reg [31:0]            e_sum_gray   ,
        output reg [19:0]            e_num_gray
);

    parameter   HANG_NUM      = 480;
    parameter   LIE_NUM       = 640;
//    parameter   LIE_UNVALID   = 5;
    parameter   DATA_WIDH     = 8;
    parameter   THRES         = 135;

    reg [9:0] hang_cnt ,lie_cnt ; 
    reg valid; 
    integer i;
//    wire data_valid = (hang_cnt_out > 1) & (hang_cnt_out < HANG_NUM) & (lie_cnt_out > 1) & (lie_cnt_out < LIE_NUM);
/////////////
//判断当前像素在第几行 第几列
reg [10:0] row_counter = 0;     //行计数
reg [10:0] col_counter = 0;     //列计数
// 内部状态，记录上一周期的同步信号状态
reg last_fs, last_hs;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // 复位时清零计数器和状态
        row_counter <= 0;
        col_counter <= 0;
        last_fs <= 0;
        last_hs <= 0;
        hang_cnt <= 0;
        lie_cnt  <= 0;
    end else begin
        // 更新状态记录
        last_fs <= fs;
        last_hs <= hs;

        if (fs && !last_fs) begin
            // 检测到场同步信号的上升沿
            row_counter <= 0;
            col_counter <= 0;
        end else if (hs && !last_hs) begin
            // 检测到行同步信号的上升沿
            col_counter <= 0;
            row_counter <= row_counter + 1;
        end else if (hs) begin
            // 在没有同步信号的普通时钟周期，递增列计数器
            col_counter <= col_counter + 1;
        end
    end
    hang_cnt <= row_counter-1;
    lie_cnt  <= col_counter;
    valid <= in_valid;        
end
///////////////////////////////
    

    wire [7:0] middle    ;
    wire [7:0] left      ;
    wire [7:0] up_right1 ;
    wire [7:0] up_middle1;
    wire [7:0] up_left1  ; 
    wire fs_neg,hs_neg;

    get_around u_get_around(
        .clk         ( clk          ),
        .rst_n       ( rst_n        ),

        .fs          ( fs           ),
        .hs          ( hs           ),
        .data        ( data         ),

        .middle      ( middle       ),
        .left        ( left         ),
        .up_right1   ( up_right1    ),
        .up_middle1  ( up_middle1   ),
        .up_left1    ( up_left1     ),
        .fs_neg      ( fs_neg       ),
        .hs_neg      ( hs_neg       )
    );

    reg [9:0]  max_label; reg start;
    reg [9:0]  label[1023:0];
    reg [9:0]  le [1023:0];
    reg [9:0]  ri [1023:0];
    reg [8:0]  upm[1023:0];
    reg [8:0]  dw [1023:0];
    reg [31:0] sum_gray[1023:0];
    reg [19:0] num_gray[1023:0];
    reg [9:0]  pixel_last_label[1023:0];
    reg [9:0]  pixel_last_temp [1023:0];
    reg [9:0]  pixel_left_label;

    always @(posedge clk or negedge rst_n)
    begin
        if(rst_n==1'b0)
            start <= 0;
        else if(valid ==1)
        begin
            if(middle >= THRES)
                start <= 1;
            else
                start <= start;
        end
        else if(fs_neg==1)
            start <= 0;
        else
            start <= start;
    end


///////
    wire [9:0] combine1_l = (pixel_left_label < pixel_last_label[lie_cnt+1]) ? pixel_left_label : pixel_last_label[lie_cnt+1];
    wire [9:0] combine1_b = (pixel_left_label > pixel_last_label[lie_cnt+1]) ? pixel_left_label : pixel_last_label[lie_cnt+1];

    wire [9:0] combine2_l = (pixel_last_label[lie_cnt-1] < pixel_last_label[lie_cnt+1]) ? pixel_last_label[lie_cnt-1] : pixel_last_label[lie_cnt+1];
    wire [9:0] combine2_b = (pixel_last_label[lie_cnt-1] > pixel_last_label[lie_cnt+1]) ? pixel_last_label[lie_cnt-1] : pixel_last_label[lie_cnt+1];

    reg [9:0] cnt_write;
    wire export_valid = (cnt_write>=1) && (cnt_write<=1023);

        

    always @(posedge clk or negedge rst_n)
    begin
        if(rst_n==0)
        begin
            max_label <= 0;
            pixel_left_label <= 0;
            for(i=0;i<1024;i=i+1)
            begin
                label[i]    = 0;
                le[i]       = 0;
                ri[i]       = 0;
                upm[i]      = 0;
                dw[i]       = 0;
                sum_gray[i] = 0;
                num_gray[i] = 0;
                pixel_last_label[i]=0;
                pixel_last_temp[i]=0;
            end
        end
        else if(valid==1)
        begin
            if(start==0)
            begin
                if(middle >= THRES)
                begin
                    max_label <= 1;
                    label [max_label+1]  <= 1 ;

                    le  [max_label+1]  <= lie_cnt   ;
                    ri  [max_label+1]  <= lie_cnt   ;
                    upm [max_label+1]  <= hang_cnt   ;
                    dw  [max_label+1]  <= hang_cnt   ;

                    sum_gray [max_label+1]  <= middle   ;
                    num_gray [max_label+1]  <= 1   ;

                    pixel_left_label <= 1;
                    pixel_last_temp[lie_cnt] <= 1;
                end
            end
            else
            begin
                if(middle >= THRES)
                begin
                    if( (pixel_left_label!=pixel_last_label[lie_cnt+1]) &&(pixel_left_label!=0) && (pixel_last_label[lie_cnt+1]!=0) )
                    begin
                        le[combine1_l] <= (le[combine1_l] < le[combine1_b])?le[combine1_l]:le[combine1_b];
                        ri[combine1_l] <= (ri[combine1_l] > ri[combine1_b])?ri[combine1_l]:ri[combine1_b];
                        upm[combine1_l] <= (upm[combine1_l] < upm[combine1_b])?upm[combine1_l]:upm[combine1_b];
                        dw[combine1_l] <= hang_cnt;

                        sum_gray[combine1_l] <= sum_gray[combine1_l] + sum_gray[combine1_b] + middle;
                        num_gray[combine1_l] <= num_gray[combine1_l] + num_gray[combine1_b] + 1;
                        num_gray[combine1_b] <= 0;

                        for(i=0;i<LIE_NUM;i=i+1)
                        begin
                            if (pixel_last_label[i]==combine1_b)
                                pixel_last_label[i] <= combine1_l;
                            if (pixel_last_temp[i]==combine1_b)
                                pixel_last_temp[i] <= combine1_l;
                        end

                        pixel_left_label <= combine1_l;
                        pixel_last_temp[lie_cnt] <= combine1_l;
                    end
                    else if((pixel_last_label[lie_cnt-1]!=pixel_last_label[lie_cnt+1]) &&(pixel_last_label[lie_cnt-1]!=0) && (pixel_last_label[lie_cnt+1]!=0))
                    begin
                        le[combine2_l] <= (le[combine2_l] < le[combine2_b])?le[combine2_l]:le[combine2_b];
                        ri[combine2_l] <= (ri[combine2_l] > ri[combine2_b])?ri[combine2_l]:ri[combine2_b];
                        upm[combine2_l] <= (upm[combine2_l] < upm[combine2_b])?upm[combine2_l]:upm[combine2_b];
                        dw[combine2_l] <= hang_cnt;

                        sum_gray[combine2_l] <= sum_gray[combine2_l] + sum_gray[combine2_b] + middle;
                        num_gray[combine2_l] <= num_gray[combine2_l] + num_gray[combine2_b] + 1;
                        num_gray[combine2_b] <= 0;

                        for(i=0;i<LIE_NUM;i=i+1)
                        begin
                            if (pixel_last_label[i]==combine2_b)
                                pixel_last_label[i] <= combine2_l;
                            if (pixel_last_temp[i]==combine2_b)
                                pixel_last_temp[i] <= combine2_l;
                        end

                        pixel_left_label <= combine2_l;
                        pixel_last_temp[lie_cnt] <= combine2_l;
                    end


                    else if(pixel_left_label==0)
                    begin
                        if(pixel_last_label[lie_cnt-1]==0)
                        begin
                            if(pixel_last_label[lie_cnt]==0)
                            begin
                                if(pixel_last_label[lie_cnt+1]==0)
                                begin
                                    if(max_label < 1023)
                                        max_label <= max_label + 1;
                                    else
                                        max_label <= max_label;

                                    label [max_label+1]  <= max_label+1 ;

                                    le  [max_label+1]  <= lie_cnt   ;
                                    ri [max_label+1]  <= lie_cnt   ;
                                    upm    [max_label+1]  <= hang_cnt   ;
                                    dw  [max_label+1]  <= hang_cnt   ;

                                    sum_gray     [max_label+1]  <= middle   ;
                                    num_gray     [max_label+1]  <= 1   ;

                                    pixel_left_label <= max_label+1;
                                    pixel_last_temp[lie_cnt] <= max_label+1;
                                end
                                else
                                begin
                                    dw[pixel_last_label[lie_cnt+1]]  <= hang_cnt   ;
                                    le[pixel_last_label[lie_cnt+1]]  <= (lie_cnt < le[pixel_last_label[lie_cnt+1]])?lie_cnt:le[pixel_last_label[lie_cnt+1]];
                                    sum_gray[pixel_last_label[lie_cnt+1]]  <= sum_gray[pixel_last_label[lie_cnt+1]] + middle;
                                    num_gray[pixel_last_label[lie_cnt+1]]  <= num_gray[pixel_last_label[lie_cnt+1]] + 1;

                                    pixel_left_label <= pixel_last_label[lie_cnt+1];
                                    pixel_last_temp[lie_cnt] <= pixel_last_label[lie_cnt+1];
                                end
                            end
                            else
                            begin
                                dw[pixel_last_label[lie_cnt]]  <= hang_cnt   ;
                                sum_gray[pixel_last_label[lie_cnt]]  <= sum_gray[pixel_last_label[lie_cnt]] + middle;
                                num_gray[pixel_last_label[lie_cnt]]  <= num_gray[pixel_last_label[lie_cnt]] + 1;

                                pixel_left_label <= pixel_last_label[lie_cnt];
                                pixel_last_temp[lie_cnt] <= pixel_last_label[lie_cnt];
                            end
                        end
                        else
                        begin
                            dw[pixel_last_label[lie_cnt-1]]  <= hang_cnt   ;
                            ri[pixel_last_label[lie_cnt-1]]  <= (lie_cnt>ri[pixel_last_label[lie_cnt-1]])?lie_cnt:ri[pixel_last_label[lie_cnt-1]];
                            sum_gray[pixel_last_label[lie_cnt-1]]  <= sum_gray[pixel_last_label[lie_cnt-1]] + middle;
                            num_gray[pixel_last_label[lie_cnt-1]]  <= num_gray[pixel_last_label[lie_cnt-1]] + 1;

                            pixel_left_label <= pixel_last_label[lie_cnt-1];
                            pixel_last_temp[lie_cnt] <= pixel_last_label[lie_cnt-1];
                        end
                    end
                    else
                    begin
                        ri[pixel_left_label]  <= (lie_cnt>ri[pixel_left_label])?lie_cnt:ri[pixel_left_label];
                        sum_gray[pixel_left_label]  <= sum_gray[pixel_left_label] + middle;
                        num_gray[pixel_left_label]  <= num_gray[pixel_left_label] + 1;

                        pixel_left_label <= pixel_left_label;
                        pixel_last_temp[lie_cnt] <= pixel_left_label;
                    end
                end
                else
                begin
                    pixel_left_label <= 0;
                    pixel_last_temp[lie_cnt] <= 0;
                end
            end
        end
        else if(fs_neg==1)
        begin
            max_label <= 0;
        end
        else if(export_valid==1)
        begin
             label[cnt_write]     <= 0 ;
             le[cnt_write]        <= 0 ;
             ri[cnt_write]        <= 0 ;
             upm[cnt_write]       <= 0 ;
             dw[cnt_write]        <= 0 ;
             sum_gray[cnt_write]  <= 0 ;
             num_gray[cnt_write]  <= 0 ;
        end
        else
        begin
            max_label <= max_label;
        end
    end


    always @(posedge clk or negedge rst_n)
    begin
        if(rst_n==1'b0)
        begin
            for(i=0;i<LIE_NUM;i=i+1)
            begin
                pixel_last_label[i] <= 0;
            end
        end
        else if(hs_neg==1)
        begin
            for(i=0;i<LIE_NUM;i=i+1)
            begin
                pixel_last_label[i] <= pixel_last_temp[i];
            end
        end
    end



    always @(posedge clk or negedge rst_n)
    begin
        if(rst_n==1'b0)
            cnt_write <= 0;
        else if(fs_neg==1)
            cnt_write <= 1;
        else if(cnt_write >= 1)
            cnt_write <= cnt_write + 1;
        else
            cnt_write <= cnt_write ;
    end

  

    always @(posedge clk or negedge rst_n)
    begin
        if(rst_n==1'b0)
        begin
            e_label       <=   0;
            e_le          <=   0;
            e_ri          <=   0;
            e_upm         <=   0;
            e_dw          <=   0;
            e_sum_gray    <=   0;
            e_num_gray    <=   0;
        end
        else if(export_valid==1)
        begin
            e_label       <= label[cnt_write];
            e_le          <= le[cnt_write];
            e_ri          <= ri[cnt_write];
            e_upm         <= upm[cnt_write];
            e_dw          <= dw[cnt_write];
            e_sum_gray    <= sum_gray[cnt_write];
            e_num_gray    <= num_gray[cnt_write];
        end
        else
        begin
            e_label       <=   0;
            e_le          <=   0;
            e_ri          <=   0;
            e_upm         <=   0;
            e_dw          <=   0;
            e_sum_gray    <=   0;
            e_num_gray    <=   0;
        end
    end



endmodule

