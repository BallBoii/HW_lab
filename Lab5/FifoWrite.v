`timescale 1ns / 1ps
//****************************************VSCODE PLUG-IN**********************************//
//----------------------------------------------------------------------------------------
// IDE :                   VSCODE     
// VSCODE plug-in version: Verilog-Hdl-Format-3.5.20250220
// VSCODE plug-in author : Jiang Percy
//----------------------------------------------------------------------------------------
//****************************************Copyright (c)***********************************//
// Copyright(C)            Please Write Company name
// All rights reserved     
// File name:              
// Last modified Date:     2025/02/24 20:43:00
// Last Version:           V1.0
// Descriptions:           
//----------------------------------------------------------------------------------------
// Created by:             Please Write You Name 
// Created date:           2025/02/24 20:43:00
// mail      :             Please Write mail 
// Version:                V1.0
// TEXT NAME:              FifoWrite.v
// PATH:                   D:\HW_lab\lab\Lab5\FifoWrite.v
// Descriptions:           
//                         
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module FifoWrite(
    input wire Clk,
    input wire Reset,
    output wire [7:0] din,
    output wire wr_en,
    input wire full,
    input wire [7:0] DataFromOutside                     
);

localparam IDLE = 1'b0, WRITE = 1'b1;

reg state;

reg [7:0] din_reg = 0;
reg [7:0] data_from_outside_reg = 0;
reg wr_en_reg = 0;

assign din = din_reg;
assign wr_en = wr_en_reg;

always @(posedge Clk) begin
    if (Reset) begin
        state <= IDLE;
        wr_en_reg <= 0;
        din_reg <= 0;
    end else begin
        case (state)
        
        IDLE : begin
            if (!full) begin
                data_from_outside_reg <= DataFromOutside;
                state <= WRITE;
            end
            wr_en_reg <= 0;
        end
        
        WRITE : begin
            wr_en_reg <= 1;
            din_reg <= data_from_outside_reg;

            state <= IDLE;
        end

        endcase
    end
end
                                                                   
                                                                   
endmodule