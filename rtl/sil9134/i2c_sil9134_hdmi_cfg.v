// -----------------------------------------------------------------------------
// Copyright (c) 2024-2025 All rights reserved
// -----------------------------------------------------------------------------
// Author : 1224024832@njupt.edu.cn
// Wechat : secret
// File   : i2c_sil9134_hdmi_cfg.v
// Create : 2025-03-27 10:50:28
// Revise : 2025-03-27 12:53:52
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
`timescale  1ns/1ps

module i2c_sil9134_hdmi_cfg(
    input  wire				clk      ,     //时钟信号
    input  wire             rst_n    ,     //复位信号，低电平有效
    
    input  wire				i2c_done ,     //I2C寄存器配置完成信号


    output  reg          	i2c_exec ,     //I2C触发执行信号   
    output  reg  [23:0]  	i2c_data ,     //I2C要配置的地址与数据(高8位ID地址，中间8位寄存器地址,低8位数据)
    output  reg          	i2c_rh_wl,     //I2C读写控制信号

    output  reg          	init_done      //初始化完成信号

	);

//parameter define
localparam   REG_NUM = 3'd4  ;       //总共需要配置的寄存器个数
localparam   CNT_WAIT_MAX = 10'd1023;   //寄存器配置等待计数最大值

//reg define
reg   [9:0]   start_init_cnt;        //等待延时计数器
reg   [2:0]   init_reg_cnt  ;        //寄存器配置个数计数器

//*****************************************************
//**                    main code
//*****************************************************


//clk时钟配置成250khz,周期为4us 5000*4us = 20ms
//start_init_cnt:上电到开始配置IIC至少等待20ms
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        start_init_cnt <= 13'b0;
    else if(start_init_cnt < CNT_WAIT_MAX) begin
        start_init_cnt <= start_init_cnt + 1'b1;                    
    end
end

//init_reg_cnt:寄存器配置个数计数    
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        init_reg_cnt <= 3'd0;
    else if(i2c_exec)   
        init_reg_cnt <= init_reg_cnt + 1'b1;
end

//i2c_exec:i2c触发执行信号   
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        i2c_exec <= 1'b0;
    else if(start_init_cnt == (CNT_WAIT_MAX - 1))
        i2c_exec <= 1'b1;
    else if(i2c_done && (init_reg_cnt < REG_NUM))
        i2c_exec <= 1'b1;
    else
        i2c_exec <= 1'b0;
end 

//i2c_rh_wl:配置I2C读写控制信号
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        i2c_rh_wl <= 1'b0;
    else begin
    	i2c_rh_wl <= 1'b0;
    end
    // else if(init_reg_cnt == 8'd2)  
    //     i2c_rh_wl <= 1'b0;  
end

//init_done:初始化完成信号
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        init_done <= 1'b0;
    else if((init_reg_cnt == REG_NUM) && i2c_done)  
        init_done <= 1'b1;  
end


//i2c_data:配置寄存器地址与数据
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        i2c_data <= 24'b0;
    else begin
        case(init_reg_cnt)
            3'd0  : i2c_data <= {8'h76,8'h08,8'h35};
            3'd1  : i2c_data <= {8'h76,8'h49,8'h00};
            3'd2  : i2c_data <= {8'h76,8'h4A,8'h00};
            3'd3  : i2c_data <= {8'h7e,8'h2F,8'h00};
            
            default : i2c_data <= {8'h76,8'h08,8'h35};
        endcase
    end
end

endmodule
