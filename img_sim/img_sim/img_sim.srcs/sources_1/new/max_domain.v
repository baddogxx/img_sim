
`timescale 1ns/1ps
//�����ͨ�����⡢�������
//���ߣ�xx
//ʱ�䣺2024-4-1

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
  
    output  reg [8:0]   center_x    ,    //��������x���
    output  reg [8:0]   center_y         //��������y���
);



//��ͨ����ģ������

wire   [8:0]   in_up           ;    // �ϱ߽�����
wire   [8:0]   in_dowm         ;    // �±߽�����
wire   [8:0]   in_left         ;    // ��߽�����
wire   [8:0]   in_right        ;    // �ұ߽�����
wire   [19:0]  pixel_num       ;    // ��������

//��ͨ����ģ��
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
        last_vsync <= 0;
        last_href <= 0;
        hang_cnt <= 0;
        lie_cnt  <= 0;
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
    hang_cnt <= row_counter-1;
    lie_cnt  <= col_counter;
      
end


// �洢�����ͨ�����Ӧ�ı߽�
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
            // ���������������
            max_pixel_num <= pixel_num;
            // ��������߽�
            out_up      <= in_up;
            out_dowm    <= in_dowm;
            out_left    <= in_left;
            out_right   <= in_right;
            // �������ĵ�����
            center_x <= (out_left + out_right) >> 1;  // ȡx����ֵ
            center_y <= (out_up + out_dowm) >> 1;    // ȡy����ֵ
        end
    end
end

// //���Ӻ�ɫ����
// always @(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//         out_data  <= 8'b0;
//     end 
//     else begin
//         if ((hang_cnt == out_up) || (hang_cnt == out_dowm)) begin
//             out_data <= 24'hFF0000;     //�����ɫ����
//         end else if ((lie_cnt == out_left) || (lie_cnt == out_right)) begin
//             out_data <= 24'hFF0000;     //�����ɫ����
//         end
//         else begin
//         out_data  <= {3{in_data}};
//         end
//     end 
// end

//���Ӻ�ɫ����
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_data  <= 8'b0;
    end 
    else begin
        if ((hang_cnt == 100) || (hang_cnt == 100)) begin
            out_data <= 24'hFF0000;     //�����ɫ����
        end else if ((lie_cnt == 100) || (lie_cnt == 100)) begin
            out_data <= 24'hFF0000;     //�����ɫ����
        end
        else begin
        out_data  <= {3{in_data}};
        end
    end 
end

//�����ź�ͬ��


endmodule

