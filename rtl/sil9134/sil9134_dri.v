// -----------------------------------------------------------------------------
// Copyright (c) 2024-2025 All rights reserved
// -----------------------------------------------------------------------------
// Author : 1224024832@njupt.edu.cn
// Wechat : secret
// File   : sil9134_dri.v
// Create : 2025-03-27 12:54:41
// Revise : 2025-03-27 13:30:55
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
`timescale  1ns/1ps


module sil9134_dri(
    input   wire        clk             ,  //时钟
    input   wire        rst_n           ,  //复位信号,低电平有效

    /* 物理接口 */
	output  wire        hdmi_cfg_done        ,   //寄存器配置完成
    output  wire        hdmi_cfg_scl        ,   //SCL
    inout   wire        hdmi_cfg_sda           //SDA
	);

//parameter define

parameter BIT_CTRL   = 1'b0           ; //的字节地址为8位  0:8位 1:16位
parameter CLK_FREQ   = 27'd50_000_000 ; //i2c_dri模块的驱动时钟频率 
parameter I2C_FREQ   = 18'd250_000    ; //I2C的SCL时钟频率,不超过400KHz

//wire difine
wire        i2c_exec       ;  //I2C触发执行信号
wire [23:0] i2c_data       ;  //I2C要配置的地址与数据(高8位地址,低8位数据)          
wire        i2c_done       ;  //I2C寄存器配置完成信号
wire        i2c_dri_clk    ;  //I2C操作时钟

wire        i2c_rh_wl      ;  //I2C读写控制信号

i2c_dri #(
		.CLK_FREQ(CLK_FREQ        ),
		.I2C_FREQ(I2C_FREQ        )
	) inst_i2c_sil9134_dri (
		.clk        (clk         ),
		.rst_n      (rst_n       ),

		.i2c_exec   (i2c_exec    ),
		.bit_ctrl   (BIT_CTRL    ),
		.i2c_rh_wl  (i2c_rh_wl   ),
		.i2c_id_addr(i2c_data[23:16]),
		.i2c_addr   (i2c_data[15:8] ),
		.i2c_data_w (i2c_data[7:0]  ),
		.i2c_data_r (            ),
		.i2c_done   (i2c_done    ),
		.i2c_ack    (            ),
		.scl        (hdmi_cfg_scl),
		.sda        (hdmi_cfg_sda),
		.dri_clk    (i2c_dri_clk )
	);

i2c_sil9134_hdmi_cfg  inst_i2c_sil9134_hdmi_cfg(
	.clk       			(i2c_dri_clk  ),
	.rst_n     			(rst_n        ),
	.i2c_done  			(i2c_done     ),
	.i2c_exec  			(i2c_exec     ),
	.i2c_data  			(i2c_data     ),
	.i2c_rh_wl 			(i2c_rh_wl    ),
	.init_done 			(hdmi_cfg_done)
	);

endmodule