`timescale 1ns / 1ns
//ͼ�������ģ��
//���ߣ�xx
//ʱ�䣺2024-4-1
 
module tb_top;
 
integer iBmpFileId;                 //����BMPͼƬ
integer oBmpFileId;                 //���BMPͼƬ
integer oTxtFileId;                 //����TXT�ı�
        
integer iIndex = 0;                 //���BMP��������
integer pixel_index = 0;            //��������������� 
        
integer iCode;      
integer iBmpSize;                   //����BMP �ֽ���
    
reg [ 7:0] rBmpData [0:2000000];    //�Ĵ�����BMPͼƬ�е��ֽ����ݣ�����54�ֽڵ��ļ�ͷ��
reg [ 7:0] Vip_BmpData [0:2000000]; //�Ĵ���Ƶͼ����֮���BMPͼƬ���� 
reg [ 7:0] rBmpWord;                //���BMPͼƬʱ���ڼĴ�����

reg clk;
reg rst_n;

reg [ 7:0] vip_pixel_data [0:921600];   //640x480x3

//����25MHzʱ��
always #20 clk = ~clk;

initial begin

    //�ֱ�� ����/���BMPͼƬ���Լ������Txt�ı�
	iBmpFileId = $fopen("eye_in.bmp","rb");
	oBmpFileId = $fopen("eye_out.bmp","wb+");
	oTxtFileId = $fopen("eye.txt","w+");

	// iBmpFileId = $fopen("ten.bmp","rb");
	// oBmpFileId = $fopen("ten_out.bmp","wb+");
	// oTxtFileId = $fopen("ten.txt","w+");

    //������BMPͼƬ���ص����飨rBmpData����
	iCode = $fread(rBmpData,iBmpFileId);
 
    //����BMPͼƬ�ļ�ͷ�ĸ�ʽ�����ͼƬ���ֽ���
	iBmpSize   = {rBmpData[ 5],rBmpData[ 4],rBmpData[ 3],rBmpData[ 2]};        //921654

    //�ر�����BMPͼƬ
	$fclose(iBmpFileId);
    
    //�������е�����д�����Txt�ı���
	$fwrite(oTxtFileId,"%p",rBmpData);
    //�ر�Txt�ı�
    $fclose(oTxtFileId);
        
    //�ӳ�20ms���ȴ���һ֡ͼƬ�������
    #18000000

    //����ͼ�����BMPͼƬ���ļ�ͷ����������
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		if(iIndex < 54)
            Vip_BmpData[iIndex] = rBmpData[iIndex];
        else
            Vip_BmpData[iIndex] = vip_pixel_data[iIndex-54];		//����
	end
    
    //�������е�����д�����BMPͼƬ��    
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		rBmpWord = Vip_BmpData[iIndex];
		$fwrite(oBmpFileId,"%c",rBmpWord);          //%c�����ַ�ģʽ
	end
    //�ر����BMPͼƬ
	$fclose(oBmpFileId);
    
end
 
//��ʼ��ʱ�Ӻ͸�λ�ź�
initial begin
    clk     = 1;
    rst_n   = 0;
    #110
    rst_n   = 1;
end 


//VGAʱ������
wire		cmos_vsync ;
reg			cmos_href  ;
wire        cmos_clken ;
reg	[23:0]	cmos_data  ;			 

reg [31:0]  cmos_index ;

parameter [10:0] IMG_HDISP = 11'd640;
parameter [10:0] IMG_VDISP = 11'd480;

localparam H_SYNC = 11'd96;		
localparam H_BACK = 11'd48;		
localparam H_DISP = IMG_HDISP;	
localparam H_FRONT = 11'd16;		
localparam H_TOTAL = H_SYNC + H_BACK + H_DISP + H_FRONT;	//640*480�� H_TOTAL=800

localparam V_SYNC = 11'd2;		
localparam V_BACK = 11'd33;		
localparam V_DISP = IMG_VDISP;	
localparam V_FRONT = 11'd10;		
localparam V_TOTAL = V_SYNC + V_BACK + V_DISP + V_FRONT;	//640*480�� V_TOTAL=525


//ˮƽ������ ��0-799֮��ѭ��
reg	[10:0]	hcnt;
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		hcnt <= 11'd0;
	else
		hcnt <= (hcnt < H_TOTAL - 1'b1) ? hcnt + 1'b1 : 11'd0;
end

//��ֱ������ ��0-524֮��ѭ��
reg	[10:0]	vcnt;
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		vcnt <= 11'd0;		
	else begin
		if(hcnt == H_TOTAL - 1'b1)
			vcnt <= (vcnt < V_TOTAL - 1'b1) ? vcnt + 1'b1 : 11'd0;
		else
			vcnt <= vcnt;
    end
end

//��ͬ��
reg	cmos_vsync_r; 
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cmos_vsync_r <= 1'b0;			
	else begin
		if(vcnt <= V_SYNC - 1'b1)		
			cmos_vsync_r <= 1'b0; 	
		else
			cmos_vsync_r <= 1'b1; 	     //�ߵ�ƽ��Ч
    end
end
assign	cmos_vsync	= cmos_vsync_r;

//frame_valid_ahead��ʾ������Ч�ź�
wire	frame_valid_ahead =  ( vcnt >= V_SYNC + V_BACK  && vcnt < V_SYNC + V_BACK + V_DISP
                            && hcnt >= H_SYNC + H_BACK  && hcnt < H_SYNC + H_BACK + H_DISP ) 
						? 1'b1 : 1'b0;
      
reg			cmos_href_r;   

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cmos_href_r <= 0;
	else begin
		if(frame_valid_ahead)		//������Ч�ź�Ϊ�ߣ���Ч��ʱ������Ч�ź�ҲΪ�ߣ���Ч��
			cmos_href_r <= 1;
		else
			cmos_href_r <= 0;
    end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cmos_href <= 0;
	else
        cmos_href <= cmos_href_r;
end

assign cmos_clken = cmos_href;

//������������Ƶ��ʽ�����������
wire [10:0] x_pos;			//ˮƽƫ����
wire [10:0] y_pos;			//��ֱƫ����
//����ˮƽ����ֱ����ƫ����
assign x_pos = frame_valid_ahead ? (hcnt - (H_SYNC + H_BACK )) : 0;
assign y_pos = frame_valid_ahead ? (vcnt - (V_SYNC + V_BACK )) : 0;


always@(posedge clk or negedge rst_n)begin
   if(!rst_n) begin
       cmos_index   <=  0;
       cmos_data    <=  24'd0;
   end
   else begin
       cmos_index   <=  y_pos * 1920  + x_pos*3 + 54;        //  3*(y*640 + x) + 54
       cmos_data    <=  {rBmpData[cmos_index], rBmpData[cmos_index+1] , rBmpData[cmos_index+2]};
   end
end
 

wire 		img_vs_in	    =	cmos_vsync ;		//��ͬ��
wire 		img_clken_in	=	cmos_href;			//��ͬ��
wire 		data_valid_in	=	cmos_clken;			//������Ч�ź�
wire [23:0]	img_data_in		=	cmos_data;	 

wire [23:0] out_data;
	            

 //ͼ�����㷨
 img_pro u_img_pro(
	.clk            (clk            ),
	.rst_n          (rst_n          ),

	.img_vs_in      (img_vs_in      ),
	.img_clken_in   (img_clken_in   ),
	.data_valid_in  (data_valid_in  ),
	.img_data_in    (img_data_in    ),

	.img_vs_out     (img_vs_out     ),
	.img_clken_out  (img_clken_out  ),
	.data_valid_out (data_valid_out ),
	.img_data_out   (out_data   )
 );




// mean_filter u_mean_filter(
// 	.clk        (clk        ),
// 	.rst_n      (rst_n      ),

// 	.pre_data   (img_data_in   ),
// 	.per_vsync  (img_vs_in  ),
// 	.per_href   (img_clken_in   ),
// 	.per_clken  (data_valid_in  ),

// 	.post_data  (out_data  ),
// 	.post_vsync (img_vs_out ),
// 	.post_href  (img_clken_out  ),
// 	.post_clken (data_valid_out )
// );

 

reg [31:0] vip_cnt;
 
reg         vip_vsync_r;    //�Ĵ�VIP����ĳ�ͬ�� 
reg         vip_out_en;     //�Ĵ�VIP����ͼ���ʹ���źţ���ά��һ֡��ʱ��

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) 
        vip_vsync_r   <=  1'b0;
   else 
        vip_vsync_r   <=  img_vs_out;
end

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) 
        vip_out_en    <=  1'b1;
   else if(vip_vsync_r & (!img_vs_out))  //��һ֡����֮��ʹ������
        vip_out_en    <=  1'b0;
end

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) begin
        vip_cnt <=  32'd0;
   end
   else if(vip_out_en) begin
        if(img_clken_out & data_valid_out) begin
            vip_cnt <=  vip_cnt + 3;
            vip_pixel_data[vip_cnt+0] <= out_data[23: 16];
            vip_pixel_data[vip_cnt+1] <= out_data[15 : 8];
            vip_pixel_data[vip_cnt+2] <= out_data[7 : 0];
        end
   end
end
 
endmodule 
