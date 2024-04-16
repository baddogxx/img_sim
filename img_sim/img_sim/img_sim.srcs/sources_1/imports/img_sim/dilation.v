`timescale 1ns / 1ps
//ͼ������
//���ߣ�xx
//ʱ�䣺2024-3-26

`timescale 1ns / 1ps
module dilation(    
    input   clk,
    input   rst_n,

    input          in_vsync,
    input          in_clken,
    input          in_valid,
    input  [7:0]   in_data,

    output         out_vsync     ,
    output         out_clken     ,
    output   reg   out_valid     ,
    output  [7:0]  out_data       
);

//ʹ�õ��������ݽ��д���
wire    in_data_1bit ;
assign  in_data_1bit = in_data[0];
reg     out_data_1bit;
assign  out_data = {8{out_data_1bit}};

wire    row1_data_r;      //��shift_ram���յĵ�һ�л���  
wire    row2_data_r;      //�ڶ���

wire    row1_data;   
wire    row2_data;
wire    row3_data;

//������������
assign  row1_data = row1_data_r;    //��һ�л��棨��shift_ram��ȡ��
assign  row2_data = row2_data_r;    //�ڶ��л��棨Ҳ��shift_ram��ȡ��
assign  row3_data = in_data;        //�ӵ�ǰ�����ȡ

//3*3����  1_1�����Ͻǵ�һ�����أ� 3_3�����½����һ�����ص�
reg  row1_1, row1_2, row1_3, row2_1, row2_2, row2_3, row3_1, row3_2, row3_3;

reg [1:0] vid;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
         vid <= 2'b0;
    else
        vid <= {vid[0],in_valid};
end
//��һ������ �������л���
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        row1_1 <= 1'b0; row1_2 <= 1'b0; row1_3 <= 1'b0;
        row2_1 <= 1'b0; row2_2 <= 1'b0; row2_3 <= 1'b0;
        row3_1 <= 1'b0; row3_2 <= 1'b0; row3_3 <= 1'b0;
    end
    else if (vid[0]) begin
        row1_1 <= row1_data;    row1_2 <= row1_1;   row1_3 <= row1_2; 
        row2_1 <= row2_data;    row2_2 <= row2_1;   row2_3 <= row2_2;    
        row3_1 <= row3_data;    row3_2 <= row3_1;   row3_3 <= row3_2;  
    end
end

reg mid_out;

//�ڶ������ڣ������
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_data_1bit <= 1'b0;
    end
    else if (vid[1]) begin
         out_data_1bit <= row1_1 | row1_2 | row1_3 | row2_1 | row2_2 | row2_3 | row3_1 | row3_2 | row3_3;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        out_valid <= 1'b0;
    else
        out_valid <= vid[1];
end

//�����ź���ʱ����ʱ������
reg [1:0] out_vsync_r;
reg [1:0] out_clken_r;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_vsync_r <= 2'b0;
        out_clken_r <= 2'b0;
    end
    else begin
        out_vsync_r <=  {out_vsync_r[0],in_vsync};
        out_clken_r <=  {out_clken_r[0],in_clken};
    end
end

assign out_vsync = out_vsync_r;
assign out_clken = out_clken_r;


//�л���ģ��
shift_RAM_3X3_1bit ins_shift_RAM_0 (
  .D(in_data_1bit),         // input wire  D
  .CLK(clk),                // input wire CLK
  .SCLR(~rst_n),            // input wire SCLR
  .Q(row2_data_r)           // output wire  Q
);

shift_RAM_3X3_1bit ins_shift_RAM_1(
  .D(row2_data_r),          // input wire  D
  .CLK(clk),                // input wire CLK
  .SCLR(~rst_n),            // input wire SCLR
  .Q(row1_data_r)           // output wire  Q
);

endmodule

