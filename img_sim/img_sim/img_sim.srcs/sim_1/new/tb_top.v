`timescale 1ns / 1ns
//图像处理仿真模块
//作者：xx
//时间：2024-4-1
 
module tb_top;
 
integer iBmpFileId;                 //输入BMP图片
integer oBmpFileId;                 //输出BMP图片
integer oTxtFileId;                 //输入TXT文本
        
integer iIndex = 0;                 //输出BMP数据索引
integer pixel_index = 0;            //输出像素数据索引 
        
integer iCode;      
integer iBmpSize;                   //输入BMP 字节数
    
reg [ 7:0] rBmpData [0:2000000];    //寄存输入BMP图片中的字节数据（包括54字节的文件头）
reg [ 7:0] Vip_BmpData [0:2000000]; //寄存视频图像处理之后的BMP图片数据 
reg [ 7:0] rBmpWord;                //输出BMP图片时用于寄存数据

reg clk;
reg rst_n;

reg [ 7:0] vip_pixel_data [0:921600];   //640x480x3

//产生25MHz时钟
always #20 clk = ~clk;

initial begin

    //分别打开 输入/输出BMP图片，以及输出的Txt文本
	iBmpFileId = $fopen("eye_in.bmp","rb");
	oBmpFileId = $fopen("eye_out.bmp","wb+");
	oTxtFileId = $fopen("eye.txt","w+");

	// iBmpFileId = $fopen("ten.bmp","rb");
	// oBmpFileId = $fopen("ten_out.bmp","wb+");
	// oTxtFileId = $fopen("ten.txt","w+");

    //将输入BMP图片加载到数组（rBmpData）中
	iCode = $fread(rBmpData,iBmpFileId);
 
    //根据BMP图片文件头的格式计算出图片的字节数
	iBmpSize   = {rBmpData[ 5],rBmpData[ 4],rBmpData[ 3],rBmpData[ 2]};        //921654

    //关闭输入BMP图片
	$fclose(iBmpFileId);
    
    //将数组中的数据写到输出Txt文本中
	$fwrite(oTxtFileId,"%p",rBmpData);
    //关闭Txt文本
    $fclose(oTxtFileId);
        
    //延迟20ms，等待第一帧图片处理结束
    #18000000

    //加载图像处理后，BMP图片的文件头和像素数据
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		if(iIndex < 54)
            Vip_BmpData[iIndex] = rBmpData[iIndex];
        else
            Vip_BmpData[iIndex] = vip_pixel_data[iIndex-54];		//连接
	end
    
    //将数组中的数据写到输出BMP图片中    
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		rBmpWord = Vip_BmpData[iIndex];
		$fwrite(oBmpFileId,"%c",rBmpWord);          //%c代表单字符模式
	end
    //关闭输出BMP图片
	$fclose(oBmpFileId);
    
end
 
//初始化时钟和复位信号
initial begin
    clk     = 1;
    rst_n   = 0;
    #110
    rst_n   = 1;
end 


//VGA时序生成
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
localparam H_TOTAL = H_SYNC + H_BACK + H_DISP + H_FRONT;	//640*480下 H_TOTAL=800

localparam V_SYNC = 11'd2;		
localparam V_BACK = 11'd33;		
localparam V_DISP = IMG_VDISP;	
localparam V_FRONT = 11'd10;		
localparam V_TOTAL = V_SYNC + V_BACK + V_DISP + V_FRONT;	//640*480下 V_TOTAL=525


//水平计数器 在0-799之间循环
reg	[10:0]	hcnt;
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		hcnt <= 11'd0;
	else
		hcnt <= (hcnt < H_TOTAL - 1'b1) ? hcnt + 1'b1 : 11'd0;
end

//竖直计数器 在0-524之间循环
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

//场同步
reg	cmos_vsync_r; 
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cmos_vsync_r <= 1'b0;			
	else begin
		if(vcnt <= V_SYNC - 1'b1)		
			cmos_vsync_r <= 1'b0; 	
		else
			cmos_vsync_r <= 1'b1; 	     //高电平有效
    end
end
assign	cmos_vsync	= cmos_vsync_r;

//frame_valid_ahead表示数据有效信号
wire	frame_valid_ahead =  ( vcnt >= V_SYNC + V_BACK  && vcnt < V_SYNC + V_BACK + V_DISP
                            && hcnt >= H_SYNC + H_BACK  && hcnt < H_SYNC + H_BACK + H_DISP ) 
						? 1'b1 : 1'b0;
      
reg			cmos_href_r;   

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cmos_href_r <= 0;
	else begin
		if(frame_valid_ahead)		//数据有效信号为高（有效）时，行有效信号也为高（有效）
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

//从数组中以视频格式输出像素数据
wire [10:0] x_pos;			//水平偏移量
wire [10:0] y_pos;			//竖直偏移量
//定义水平与竖直方向偏移量
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
 

wire 		img_vs_in	    =	cmos_vsync ;		//场同步
wire 		img_clken_in	=	cmos_href;			//行同步
wire 		data_valid_in	=	cmos_clken;			//像素有效信号
wire [23:0]	img_data_in		=	cmos_data;	 

wire [23:0] out_data;
	            

 //图像处理算法
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
 
reg         vip_vsync_r;    //寄存VIP输出的场同步 
reg         vip_out_en;     //寄存VIP处理图像的使能信号，仅维持一帧的时间

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) 
        vip_vsync_r   <=  1'b0;
   else 
        vip_vsync_r   <=  img_vs_out;
end

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) 
        vip_out_en    <=  1'b1;
   else if(vip_vsync_r & (!img_vs_out))  //第一帧结束之后，使能拉低
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
