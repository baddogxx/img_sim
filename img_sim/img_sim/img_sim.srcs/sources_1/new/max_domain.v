
`timescale 1ns/1ps
//�����ͨ�����⡢�������
//���ߣ�xx
//ʱ�䣺2024-5-12

module max_domain(
    input           clk,
    input           rst_n,

    input        tem_vsync,
    input        tem_href ,
    input        tem_valid,
    input [7:0]  tem_data ,

    input         in_vsync,  
    input         in_valid,  
    input         in_href,  
    input [7:0]   in_data ,  
    
    output              out_vsync, 
    output              out_valid, 
    output              out_href, 
    output reg [23:0]   out_data  , 
  
    output  reg [9:0]   center_x    ,    //��������x�������ʾ�����У�
    output  reg [9:0]   center_y         //��������y�������ʾ�����У�
);



//��ͨ����ģ������

wire   [8:0]   in_up           ;    // �ϱ߽�����
wire   [8:0]   in_down         ;    // �±߽�����
wire   [9:0]   in_left         ;    // ��߽�����
wire   [9:0]   in_right        ;    // �ұ߽�����
wire   [19:0]  pixel_num       ;    // ��������
wire   [7:0]   label           ;

connect_domain_get u_connect_domain_get(
    .clk        (clk        ),
    .rst_n      (rst_n      ),

    .fs         (tem_vsync  ),
    .hs         (tem_href   ),
    .in_valid   (tem_valid  ),
    .data       (tem_data   ),

    .e_le       (in_left    ),
    .e_ri       (in_right   ),
    .e_upm      (in_up      ),
    .e_dw       (in_down    ),

    .e_label    (label      ),
    .e_num_gray (pixel_num  )
);

//�жϵ�ǰ�����ڵڼ��� �ڼ���
reg [10:0] row_counter = 0;     //�м���
reg [10:0] col_counter = 0;     //�м���
reg [9:0] hang_cnt ,lie_cnt ; 

// �ڲ�״̬����¼��һ���ڵ�ͬ���ź�״̬
reg last_vsync, last_href;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // ��λʱ�����������״̬
        row_counter <= 0;
        col_counter <= 0;
        last_vsync  <= 0;
        last_href   <= 0;
        hang_cnt    <= 0;
        lie_cnt     <= 0;
    end else begin
        // ����״̬��¼
        last_vsync <= in_vsync;
        last_href <= in_href;

        if (in_vsync && !last_vsync) begin
            // ��⵽��ͬ���źŵ�������
            row_counter <= 0;
            col_counter <= 0;
        end else if (in_href && !last_href) begin
            // ��⵽��ͬ���źŵ�������
            col_counter <= 0;
            row_counter <= row_counter + 1;
        end else if (in_href) begin
            // ��û��ͬ���źŵ���ͨʱ�����ڣ������м�����
            col_counter <= col_counter + 1;
        end
    end
    hang_cnt <= row_counter;
    lie_cnt  <= col_counter;     
end


// �洢�����ͨ�����Ӧ�ı߽�
reg [19:0] max_pixel_num;
reg [8:0]   out_up      ;
reg [8:0]   out_dowm    ;
reg [9:0]   out_left    ;
reg [9:0]   out_right   ;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_up          <= 0;
        out_dowm        <= 0;
        out_left        <= 0;
        out_right       <= 0;
        max_pixel_num   <= 0;
    end else begin
        if (pixel_num > max_pixel_num) begin
            // ���������������
            max_pixel_num <= pixel_num;
            // ��������߽�
            out_up      <= 480 - in_down;             //�м��������ˣ����ﷴ��һ��
            out_dowm    <= 480 - in_up;
            // out_up      <= in_up;             
            // out_dowm    <= in_down;
            out_left    <= in_left;
            out_right   <= in_right;
        end
    end
end

// �������ĵ�����
    // (0,0) _________________________>X(�� 0-639)
    //      |                      |
    //      |                      |
    //      |                      |
    //      |                      |
    //      |                      |
    //      |______________________|
    //      | Y���� 0-479��

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        center_x        <= 0;
        center_y        <= 0;
    end else begin
            center_x <= (out_left + out_right) >> 1;  // ȡx����ֵ
            center_y <= (out_up + out_dowm) >> 1;    // ȡy����ֵ
    end
end

//���Ӻ�ɫ����

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_data  <= 24'b0;
    end 

        // assign out_up    = 180 - 80;      //������
        // assign out_dowm  = 380 - 80;
        // assign out_left  = 341;
        // assign out_right = 540;

        // assign out_up    = 100;      //������
        // assign out_dowm  = 200;
        // assign out_left  = 100;
        // assign out_right = 200;

    // else if (out_valid)begin
        if ((hang_cnt == out_up) && (out_left <= lie_cnt) && (lie_cnt <= out_right)) begin
            out_data <= 24'h0000FF;     //�����ɫ����
        end 
        else if ((hang_cnt == out_dowm) && (out_left <= lie_cnt) && (lie_cnt <= out_right)) begin
            out_data <= 24'h0000FF;     //�����ɫ����
        end
        else 
        if ((lie_cnt == out_left) && (hang_cnt >= out_up) && (hang_cnt <= out_dowm)) begin
            out_data <= 24'h0000FF;     //�����ɫ����
        end
        else if ((lie_cnt == out_right) && (hang_cnt >= out_up) && (hang_cnt <= out_dowm)) begin
            out_data <= 24'h0000FF;     //�����ɫ����
        end

        else if ((lie_cnt == 440) && (hang_cnt == 200)) begin
            out_data <= 24'h0000FF;     //�����ɫ����
        end

        else begin
        out_data  <= {3{in_data}};
        end
    //end 
end

//��ʱ1����ͬ��ʱ���ź�
reg    out_vsync_d ;
reg    out_href_d  ;
reg    out_valid_d ;         

assign  out_vsync    = out_vsync_d ;
assign  out_href     = out_href_d  ;
assign  out_valid    = out_valid_d ;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_vsync_d <= 'd0;
        out_href_d  <= 'd0;
        out_valid_d <= 'd0;
    end
    else begin
        out_vsync_d <= in_vsync;
        out_href_d  <= in_href ;
        out_valid_d <= in_valid;
    end
end  

endmodule

