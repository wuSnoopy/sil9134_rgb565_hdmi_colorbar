// -----------------------------------------------------------------------------
// Copyright (c) 2024-2025 All rights reserved
// -----------------------------------------------------------------------------
// Author : 1224024832@njupt.edu.cn
// Wechat : secret
// File   : hdmi_colorbar_top.v
// Create : 2025-03-03 16:30:42
// Revise : 2025-03-27 13:47:09
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
`timescale  1ns/1ps
//�и���

module  hdmi_colorbar_top(
    input   wire            sys_clk,
    input   wire            sys_rst_n,
    
    output  wire            ddc_scl     ,
    inout   wire            ddc_sda     ,
    output  wire            hdmi_out_clk,
    // output  wire            hdmi_out_rst_n      ,
    output  wire            hdmi_out_hsync      ,   //�����ͬ���ź�
    output  wire            hdmi_out_vsync      ,   //�����ͬ���ź�
    output  wire    [23:0]  hdmi_out_rgb        ,   //���������Ϣ
    output  wire            hdmi_out_de
);

//wire define

wire          clk_locked;
wire          rst_n   ;   //VGAģ�鸴λ�ź�

wire  [10:0]  pixel_xpos_w;
wire  [10:0]  pixel_ypos_w;
wire  [15:0]  pixel_data_w;


wire  [15:0]  video_rgb;
wire        clk_74m        ;

//*****************************************************
//**                    main code
//*****************************************************

assign  rst_n   = (sys_rst_n & clk_locked);
assign  hdmi_out_rgb   ={{video_rgb[15:11],3'd0},{video_rgb[10:5],2'b0},{video_rgb[4:0],3'b0}};


//����MMCM/PLL IP��

gen_clk clk_gen_inst (
    .areset       (~sys_rst_n  ) ,  //input areset
    .inclk0       (sys_clk     ) ,  //input inclk0

    .c0           (hdmi_out_clk) ,  //output c0
    .c1           (clk_74m     ),
    .locked       (clk_locked  )    //output locked
);


// hdmi_i2c hdmi_i2c_inst(
//  .sys_clk   (hdmi_out_clk   )   ,   //ϵͳʱ��
//  .sys_rst_n (sys_rst_n      )   ,   //��λ�ź�
//  .cfg_done  (               )   ,   //�Ĵ����������
//  .sccb_scl  (ddc_scl        )   ,   //SCL
//  .sccb_sda  (ddc_sda        )       //SDA

//     );

sil9134_dri inst_sil9134_dri (
	.clk           (clk_74m 	),
	.rst_n         (rst_n 		),
	.hdmi_cfg_done (			),
	.hdmi_cfg_scl  (ddc_scl 	),
	.hdmi_cfg_sda  (ddc_sda 	)
	);


//������Ƶ��ʾ����ģ��
video_driver  video_driver_inst(
    .pixel_clk      ( hdmi_out_clk ),
    .sys_rst_n      ( rst_n ),

    .video_hs       ( hdmi_out_hsync ),
    .video_vs       ( hdmi_out_vsync ),
    .video_de       ( hdmi_out_de ),
    .video_rgb      ( video_rgb ),
	.data_req		(),

    .pixel_xpos     ( pixel_xpos_w ),
    .pixel_ypos     ( pixel_ypos_w ),
	.pixel_data     ( pixel_data_w )
);

//������Ƶ��ʾģ��
video_display  video_display_inst(
    .pixel_clk      (hdmi_out_clk),
    .sys_rst_n      (rst_n),
    .pixel_xpos     (pixel_xpos_w),
    .pixel_ypos     (pixel_ypos_w),

    .pixel_data     (pixel_data_w)
    );



endmodule 