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
// Last modified Date:     2025/02/24 20:49:51
// Last Version:           V1.0
// Descriptions:           
//----------------------------------------------------------------------------------------
// Created by:             Please Write You Name 
// Created date:           2025/02/24 20:49:51
// mail      :             Please Write mail 
// Version:                V1.0
// TEXT NAME:              FifioRead.v
// PATH:                   D:\HW_lab\lab\Lab5\FifioRead.v
// Descriptions:           
//                         
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module FifioRead(
    input wire Clk,
    input wire Reset,
    input wire empty,
    input wire [7:0] dout,
    output wire rd_en,
    input wire valid                    
);

localparam IDLE = 2'b00, READ = 2'b01, WAIT = 2'b10, PROCESS = 2'b11;

reg [1:0] state;

reg rd_en_reg = 0;
reg [7:0] data_from_fifo = 0;

assign rd_en = rd_en_reg;

always @(posedge Clk) begin
    if (Reset) begin
        state <= IDLE;
        rd_en_reg <= 0;
        data_from_fifo <= 0;
    end else begin
        case (state)
        
            IDLE : begin
                if (!empty) state <= READ;
            end

            READ : begin
                rd_en_reg <= 1;
                state <= WAIT;
            end

            WAIT : begin
                if (valid) begin
                    data_from_fifo <= dout;
                    state <= PROCESS;
                end
                rd_en_reg <= 0;
            end

            PROCESS : begin
                //process the data
                //do something with data
                state <= IDLE;
            end
        
        endcase
    end
end
                                                                   
                                                                   
endmodule