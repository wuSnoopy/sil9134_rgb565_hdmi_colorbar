//����video��ʾ��ͼ�����ص�
module  video_display(
    input                pixel_clk,
    input                sys_rst_n,
    
    input        [10:0]  pixel_xpos,  //���ص������
    input        [10:0]  pixel_ypos,  //���ص�������
    output  reg  [15:0]  pixel_data   //���ص�����
);

//parameter define
parameter  H_DISP = 11'd1280;                       //�ֱ��ʡ�����
parameter  V_DISP = 11'd720;                        //�ֱ��ʡ�����

localparam WHITE  = 16'hFFFF;  //RGB888 ��ɫ
localparam BLACK  = 16'h0000;  //RGB888 ��ɫ
localparam RED    = 16'hF800;  //RGB888 ��ɫ
localparam GREEN  = 16'h07E0;  //RGB888 ��ɫ
localparam BLUE   = 16'h001F;  //RGB888 ��ɫ

    
//*****************************************************
//**                    main code
//*****************************************************

//���ݵ�ǰ���ص�����ָ����ǰ���ص���ɫ���ݣ�����Ļ����ʾ����
always @(posedge pixel_clk ) begin
    if (!sys_rst_n)
        pixel_data <= 16'd0;
    else begin
        if((pixel_xpos >= 0) && (pixel_xpos < (H_DISP/5)*1))
            pixel_data <= WHITE;
        else if((pixel_xpos >= (H_DISP/5)*1) && (pixel_xpos < (H_DISP/5)*2))
            pixel_data <= BLACK;  
        else if((pixel_xpos >= (H_DISP/5)*2) && (pixel_xpos < (H_DISP/5)*3))
            pixel_data <= RED;  
        else if((pixel_xpos >= (H_DISP/5)*3) && (pixel_xpos < (H_DISP/5)*4))
            pixel_data <= GREEN;
        else 
            pixel_data <= BLUE;
    end
end

endmodule