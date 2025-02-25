`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 01/26/2025 11:54:43 PM
// Design Name: UARTLedSystem
// Module Name: UARTRx
// Project Name: UARTLedSystem
// Target Devices: Basys3
// Tool Versions: 2023.2
// Description: Rx module for UART communication. Read data from Host PC via UART interface then write it to the FIFO.
//////////////////////////////////////////////////////////////////////////////////


module UARTRx (
    input  wire       Clk,
    input  wire       Reset,
    // UART interface
    input  wire       Rx,
    // FIFO interface
    output wire [7:0] DataOut,
    output wire       WriteEnable,
    input  wire       Full
);
  localparam WAIT_CYCLE = 868;
  
  localparam IDLE = 0;
  localparam CAPTURE = 1;
  reg state = IDLE;
  
  reg[9:0] counter = 0;
  reg[9:0] captured = 0;
  reg[3:0] dataIndex = 0;
  
  reg WriteEnableReg = 0;
  assign WriteEnable = WriteEnableReg;
  
  assign DataOut = captured[8:1];
  
  always @(posedge Clk)begin
    if(Reset)begin
        state <= IDLE;
        counter <= 0;
        captured <= 0;
        WriteEnableReg <= 0;
        dataIndex <= 0;
    end else begin
        case(state)
            IDLE: begin
                WriteEnableReg <= 0;
                if(Rx == 0)begin
                    dataIndex <= 0;
                    counter <= 0;
                    state <= CAPTURE;
                end
            end
            CAPTURE: begin
                if(counter == WAIT_CYCLE)begin
                    counter <= 0;
                    if(dataIndex == 10)begin
                        if(captured[0] == 0 && captured[9] == 1 && !Full)begin
                            WriteEnableReg <= 1;
                        end
                        state <= IDLE;
                    end else begin
                        dataIndex <= dataIndex + 1;
                    end
                end else begin
                    counter <= counter + 1;
                    if(counter == WAIT_CYCLE/2)begin
                        captured[dataIndex] <= Rx;
                    end
                end
            end
        endcase
    end
  end
endmodule
