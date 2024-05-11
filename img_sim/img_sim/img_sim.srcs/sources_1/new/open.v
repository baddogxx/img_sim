`timescale 1ns / 1ps
//�����㣨�ȸ�ʴ�����ͣ�
//���ߣ�xx
//ʱ�䣺2024-4-18


module open(
    input clk                   ,
    input rst_n                 ,

    input          in_vsync     ,
    input          in_href      ,
    input          in_valid     ,
    input  [7:0]   in_data      ,

    output         out_vsync    ,
    output         out_href     ,
    output         out_valid    ,
    output  [7:0]  out_data 
);

//��ʴ���
wire        erosion_vsync ;
wire        erosion_href  ;
wire        erosion_valid ;
wire [7:0]  erosion_data  ;

// //�������
// wire        dilation_vsync ;
// wire        dilation_href  ;
// wire        dilation_valid ;
// wire [7:0]  dilation_data  ;


//��ʴ����
erosion u_erosion(
    .clk       (clk       ),
    .rst_n     (rst_n     ),

    .in_vsync  (in_vsync  ),
    .in_clken  (in_href   ),
    .in_valid  (in_valid  ),
    .in_data   (in_data   ),
    
    .out_vsync (erosion_vsync),
    .out_clken (erosion_href ),
    .out_valid (erosion_valid),
    .out_data  (erosion_data )
);

//��������
dilation u_dilation(
    .clk       (clk       ),
    .rst_n     (rst_n     ),

    .in_vsync  (erosion_vsync),
    .in_clken  (erosion_href ),
    .in_valid  (erosion_valid),
    .in_data   (erosion_data ),

    .out_vsync (out_vsync),
    .out_clken (out_href ),
    .out_valid (out_valid),
    .out_data  (out_data )
);



endmodule
