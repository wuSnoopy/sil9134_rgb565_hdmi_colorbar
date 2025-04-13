//����ʱ���źţ�����hdmi_video������x��y���꣬�Լ��г�ͬ���ź�
module video_driver(
    input           	pixel_clk	,
    input           	sys_rst_n	,
		
    //RGB�ӿ�	
    output          	video_hs	,     //��ͬ���ź�
    output          	video_vs	,     //��ͬ���ź�
    output          	video_de	,     //����ʹ��
    output  	[15:0]  video_rgb	,    //RGB565��ɫ����
    output	reg			data_req 	,
	
    input   	[15:0]  pixel_data	,   //���ص�����
    output  reg	[10:0]  pixel_xpos	,   //���ص������
    output  reg	[10:0]  pixel_ypos    //���ص�������
);

//parameter define

//1280*720 �ֱ���ʱ�����  ��Ҫ74.25MHzʱ��
parameter  H_SYNC   =  11'd40;   //��ͬ��
parameter  H_BACK   =  11'd220;  //����ʾ����
parameter  H_DISP   =  11'd1280; //����Ч����
parameter  H_FRONT  =  11'd110;  //����ʾǰ��
parameter  H_TOTAL  =  11'd1650; //��ɨ������

parameter  V_SYNC   =  11'd5;    //��ͬ��
parameter  V_BACK   =  11'd20;   //����ʾ����
parameter  V_DISP   =  11'd720;  //����Ч����
parameter  V_FRONT  =  11'd5;    //����ʾǰ��
parameter  V_TOTAL  =  11'd750;  //��ɨ������

//1920*1080�ֱ���ʱ����� ��Ҫ148.5MHzʱ��
//parameter  H_SYNC   =  12'd44;   //��ͬ��
//parameter  H_BACK   =  12'd148;  //����ʾ����
//parameter  H_DISP   =  12'd1920; //����Ч����
//parameter  H_FRONT  =  12'd88;  //����ʾǰ��
//parameter  H_TOTAL  =  12'd2200; //��ɨ������
//
//parameter  V_SYNC   =  12'd5;    //��ͬ��
//parameter  V_BACK   =  12'd36;   //����ʾ����
//parameter  V_DISP   =  12'd1080;  //����Ч����
//parameter  V_FRONT  =  12'd4;    //����ʾǰ��
//parameter  V_TOTAL  =  12'd1125;  //��ɨ������

//reg define
reg  [11:0] cnt_h;
reg  [11:0] cnt_v;
reg       	video_en;

//*****************************************************
//**                    main code
//*****************************************************

assign video_de  = video_en;
assign video_hs  = ( cnt_h < H_SYNC ) ? 1'b0 : 1'b1;  //��ͬ���źŸ�ֵ
assign video_vs  = ( cnt_v < V_SYNC ) ? 1'b0 : 1'b1;  //��ͬ���źŸ�ֵ

//ʹ��RGB�������
always @(posedge pixel_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)
		video_en <= 1'b0;
	else
		video_en <= data_req;
end

//RGB888�������
assign video_rgb = video_de ? pixel_data : 24'd0;

//�������ص���ɫ��������
always @(posedge pixel_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)
		data_req <= 1'b0;
	else if(((cnt_h >= H_SYNC + H_BACK - 2'd2) && (cnt_h < H_SYNC + H_BACK + H_DISP - 2'd2))
                  && ((cnt_v >= V_SYNC + V_BACK) && (cnt_v < V_SYNC + V_BACK+V_DISP)))
		data_req <= 1'b1;
	else
		data_req <= 1'b0;
end

//���ص�x����
always@ (posedge pixel_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        pixel_xpos <= 11'd0;
    else if(data_req)
        pixel_xpos <= cnt_h + 2'd2 - H_SYNC - H_BACK ;
    else 
        pixel_xpos <= 11'd0;
end
    
//���ص�y����	
always@ (posedge pixel_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        pixel_ypos <= 11'd0;
    else if((cnt_v >= (V_SYNC + V_BACK)) && (cnt_v < (V_SYNC + V_BACK + V_DISP)))
        pixel_ypos <= cnt_v + 1'b1 - (V_SYNC + V_BACK) ;
    else 
        pixel_ypos <= 11'd0;
end

//�м�����������ʱ�Ӽ���
always @(posedge pixel_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        cnt_h <= 11'd0;
    else begin
        if(cnt_h < H_TOTAL - 1'b1)
            cnt_h <= cnt_h + 1'b1;
        else 
            cnt_h <= 11'd0;
    end
end

//�����������м���
always @(posedge pixel_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        cnt_v <= 11'd0;
    else if(cnt_h == H_TOTAL - 1'b1) begin
        if(cnt_v < V_TOTAL - 1'b1)
            cnt_v <= cnt_v + 1'b1;
        else 
            cnt_v <= 11'd0;
    end
end

endmodule