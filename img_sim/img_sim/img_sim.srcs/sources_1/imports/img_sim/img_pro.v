//ͼ������ģ�飬Ŀǰ����ģ�飺rgbת�Ҷȡ���ֵ��
//Author:baddog
//Time:2024-3-23

//ip�޸Ĳ��Ա�־ �ռ���11

`timescale 1ns / 1ps

module img_pro(
    input        clk            ,       //ʱ��
    input        rst_n          ,       //��λ
    //ͼ������      
    input                   img_vs_in      ,       //��ͬ���ź�
    input                   img_clken_in   ,       //ͼ������ʹ���ź�
    input                   data_valid_in  ,       //ͼ��������Ч�ź�
    input [23:0]            img_data_in    ,       //ͼ����������
    //���
    output   reg            img_vs_out    ,    //��ͬ���ź�
	output   reg            img_clken_out ,    //ͼ������ʹ���ź�
	output   reg            data_valid_out,    //ͼ��������Ч�ź�
    output   reg  [23:0]    img_data_out        //ͼ���������
);

//�Ҷ����
wire [7:0]  gray_data;
wire        yuv_vsync;
wire        yuv_clken;
wire        yuv_valid;

//��ֵ�˲����
wire [7:0]  median_data ;
wire        median_vsync;
wire        median_clken;
wire        median_valid;

//��ֵ�����
wire [7:0]  bw_data;
wire        bw_vsync;
wire        bw_clken;
wire        bw_valid;


//������
wire        open_vsync;
wire        open_href ;
wire        open_valid;
wire [7:0]  open_data ;

//������
wire        close_vsync;
wire        close_href ;
wire        close_valid;
wire [7:0]  close_data ;

//rgbת�Ҷ�
rgb2yuv ins_rgb2yuv(
    .clk        (clk)           ,
    .rst_n      (rst_n)         ,

    .rgb_vsync  (img_vs_in)     ,       
    .rgb_clken  (img_clken_in)  ,       
    .rgb_valid  (data_valid_in) ,       
    .rgb_data   (img_data_in  ) ,       

    .gray_data  (gray_data)     ,
    .yuv_vsync  (yuv_vsync)     ,
    .yuv_clken  (yuv_clken)     ,
    .yuv_valid  (yuv_valid)         
);

//��ֵ�˲�
median_filter ins_median_filter(
    .clk            (clk            ),
    .rst_n          (rst_n          ),

    .pre_gray_vsync (yuv_vsync ),
    .pe_gray_valid  (yuv_valid ),
    .pe_gray_clken  (yuv_clken ),
    .pre_gray_data  (gray_data ),

    .pos_pixel_data (median_data  ),
    .pos_gray_vsync (median_vsync ),
    .pos_gray_clken (median_clken ),
    .pos_gray_valid (median_valid )    
);


//��ֵ��
im2bw ins_im2bw(
	.clk               (clk),
	.rst_n             (rst_n),
                   
	.yuv_vsync   (median_vsync),
	.yuv_clken   (median_clken),
	.yuv_valid   (median_valid),
	.gray_data   (median_data ),

    .bw_vsync      (bw_vsync),
	.bw_clken      (bw_clken),
	.bw_data_valid (bw_valid),
	.bw_data       (bw_data)
);

//�ȱպ�

//1��������
close ins_close(
    .clk       (clk       ),
    .rst_n     (rst_n     ),

    .in_vsync  (bw_vsync  ),
    .in_href   (bw_clken  ),
    .in_valid  (bw_valid  ),
    .in_data   (bw_data   ),

    .out_vsync (close_vsync ),
    .out_href  (close_href  ),
    .out_valid (close_valid ),
    .out_data  (close_data  )
);



//2��������
open ins_open(
    .clk       (clk       ),
    .rst_n     (rst_n     ),
    
    .in_vsync  (close_vsync  ),
    .in_href   (close_href  ),
    .in_valid  (close_valid  ),
    .in_data   (close_data   ),

    .out_vsync (open_vsync ),
    .out_href  (open_href  ),
    .out_valid (open_valid ),
    .out_data  (open_data  )
);

//��ͨ��
connect_domain_get u_connect_domain_get(
    .clk        (clk        ),
    .rst_n      (rst_n      ),

    .fs         (open_vsync ),
    .hs         (open_href  ),
    .in_valid   (open_valid ),
    .data       (open_data  ),

    .e_label    (e_label    ),
    .e_le       (e_le       ),
    .e_ri       (e_ri       ),
    .e_upm      (e_upm      ),
    .e_dw       (e_dw       ),
    .e_sum_gray (e_sum_gray ),
    .e_num_gray (e_num_gray )
);



// ���������ʱ��
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        img_data_out    <= 24'b0;
        data_valid_out  <= 1'b0;
    end
    else  begin        
        img_data_out    <= {3{open_data}};
        data_valid_out  <=    open_valid;
        img_vs_out      <=    open_vsync;
        img_clken_out   <=    open_href ;
    end
     
end


endmodule   