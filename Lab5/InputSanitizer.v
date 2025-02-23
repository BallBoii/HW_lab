`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 01/26/2025 11:55:02 PM
// Design Name: UARTLedSystem
// Module Name: InputSanitizer
// Project Name: UARTLedSystem
// Target Devices: Basys3
// Tool Versions: 2023.2
// Description: Debounce and Single Pulse Generator
//////////////////////////////////////////////////////////////////////////////////

// This module is already implemented
module InputSanitizer (
    input  wire Clk,
    input  wire Reset,
    input  wire DataIn,
    output wire DataOut
);
  reg        PreviousData = 0;
  reg [19:0] Counter = 0;
  reg        DataOutReg = 0;
  assign DataOut = DataOutReg;

  always @(posedge Clk) begin
    if (Reset) begin
      Counter <= 0;
      PreviousData <= 1'b0;
      DataOutReg <= 1'b0;
    end else begin
      if (Counter == 0) begin
        if (DataIn == 1'b1 && PreviousData == 1'b0) begin
          DataOutReg <= 1'b1;
        end
        PreviousData <= DataIn;
      end else begin
        DataOutReg <= 0;
      end
      Counter <= Counter + 1;
    end
  end
endmodule
