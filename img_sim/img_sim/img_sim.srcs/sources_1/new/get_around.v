`timescale 1ns / 1ps

module get_around(
        input                    clk          ,
        input                    rst_n        ,

        input                    fs           ,
        input                    hs           ,
        input  [7:0]             data         , 

        output [7:0]             middle       ,
        output [7:0]             left         ,
        output [7:0]             up_right1    ,
        output [7:0]             up_middle1   ,
        output [7:0]             up_left1     ,
        output                   fs_neg       ,
        output                   hs_neg
    );

    parameter   HANG_NUM      = 640;
    parameter   LIE_NUM       = 480;
    parameter   LIE_UNVALID   = 5;
    parameter   DATA_WIDH     = 8;
    parameter   THRES         = 135;

    reg [4:0] address_w;
    always @(posedge clk or negedge rst_n)
    begin
        if(rst_n==1'b0)
            address_w <= 0;
        else if(address_w < (LIE_NUM-1) )
        begin
            if((fs==1) && (hs==1))
                address_w <= address_w + 1;
            else
                address_w <= address_w;
        end
        else
            address_w <= 0;
    end

    wire wren =fs && hs;

    reg fs_delay[0:(LIE_NUM+LIE_UNVALID-3)];
    reg hs_delay[0:(LIE_NUM+LIE_UNVALID-3)];

    integer i;

    always @(posedge clk)
    begin
        fs_delay[0] <= fs;
        hs_delay[0] <= hs;
        for(i=0;i<(LIE_NUM+LIE_UNVALID-3);i=i+1)
        begin
            fs_delay[i+1] <= fs_delay[i];
            hs_delay[i+1] <= hs_delay[i];
        end
    end

    wire fs_delay_1hang = fs_delay[LIE_NUM+LIE_UNVALID-3];
    wire hs_delay_1hang = hs_delay[LIE_NUM+LIE_UNVALID-3];

    reg [4:0] address_r;

    always @(posedge clk or negedge rst_n)
    begin
        if(rst_n==1'b0)
            address_r <= 0;
        else if(address_r < (LIE_NUM-1) )
        begin
            if((fs_delay_1hang==1) && (hs_delay_1hang==1))
                address_r <= address_r + 1;
            else
                address_r <= address_r;
        end
        else
            address_r <= 0;
    end

    wire rden0 =fs_delay_1hang && hs_delay_1hang;
    reg rden1,rden2;

    always @(posedge clk )
    begin
        rden1 <= rden0;
        rden2 <= rden1;
    end

    wire rden = rden0 | rden1;
    wire [DATA_WIDH-1:00] data_delay_1hang;

    delay_1hang u_delay_1hang (
      .clka  ( clk                ),    //时钟
      .ena   ( wren               ),    //写入操作
      .wea   ( 1'b1               ),    //写使能
      .addra ( address_w          ),    //写地址端口
      .dina  ( data               ),    //写数据端口

      .clkb  ( clk                ),    //时钟，和上一个连一起了
      .enb   ( rden               ),    //读入操作
      .addrb (address_r           ),    //读地址端口
      .doutb ( data_delay_1hang   )     //读数据端口
    );

    wire [DATA_WIDH-1:00] up_middle1_temp = (rden2==1)?data_delay_1hang:0;

    wire [DATA_WIDH-1:00] middle_temp = data;


    reg [DATA_WIDH-1:00] left_temp,left_temp1,up_left1_temp,up_left1_temp1;
    always @(posedge clk )
    begin
        left_temp  <= middle_temp;
        left_temp1 <= left_temp;
        up_left1_temp <= up_middle1_temp;
        up_left1_temp1<= up_left1_temp;
    end

    assign middle =left_temp;
    assign left   = left_temp1;
    assign up_right1 =up_middle1_temp;
    assign up_middle1 =up_left1_temp;
    assign up_left1 =up_left1_temp1;

    assign hs_neg = (hs_delay[0] & ~hs);
    assign fs_neg = (fs_delay[0] & ~fs);

endmodule