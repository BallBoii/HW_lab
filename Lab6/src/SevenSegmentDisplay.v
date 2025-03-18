`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 01/16/2025 01:46:16 AM
// Design Name: StackCircuit
// Module Name: SevenSegmentDisplay
// Project Name: StackCircuit
// Target Devices: Basys3
// Tool Versions: 2023.2
// Description: Handle displaying input data on the seven segment display
//////////////////////////////////////////////////////////////////////////////////

// This module is already implemented for you
module SevenSegmentDisplay (
    input  wire        Clk,
    input  wire        Reset,
    input  wire [15:0] DataIn,
    output wire [ 7:0] Segments,
    output wire [ 3:0] AN
);
  reg [19:0] Counter = 0;
  reg [ 3:0] CurrentData = 0;
  reg [ 3:0] ANReg = 4'b1111;
  reg [ 7:0] DataInToSevenSegment = 8'b11111111;
  assign AN = ANReg;

  always @(posedge Clk) begin
    if (Reset) begin
      Counter <= 0;
      CurrentData <= 0;
      ANReg <= 4'b1111;
    end else begin
      Counter <= Counter + 1;
      case (Counter[19:18])
        2'b00: begin
          CurrentData <= DataIn[3:0];
          ANReg <= 4'b1110;
        end
        2'b01: begin
          CurrentData <= DataIn[7:4];
          ANReg <= 4'b1101;
        end
        2'b10: begin
          CurrentData <= DataIn[11:8];
          ANReg <= 4'b1011;
        end
        2'b11: begin
          CurrentData <= DataIn[15:12];
          ANReg <= 4'b0111;
        end
      endcase
    end
  end

  assign Segments = DataInToSevenSegment;

  always @(*) begin
    case (CurrentData)
      4'b0000: DataInToSevenSegment = 8'b00000011;
      4'b0001: DataInToSevenSegment = 8'b10011111;
      4'b0010: DataInToSevenSegment = 8'b00100101;
      4'b0011: DataInToSevenSegment = 8'b00001101;
      4'b0100: DataInToSevenSegment = 8'b10011001;
      4'b0101: DataInToSevenSegment = 8'b01001001;
      4'b0110: DataInToSevenSegment = 8'b01000001;
      4'b0111: DataInToSevenSegment = 8'b00011111;
      4'b1000: DataInToSevenSegment = 8'b00000001;
      4'b1001: DataInToSevenSegment = 8'b00001001;
      4'b1010: DataInToSevenSegment = 8'b00010001;
      4'b1011: DataInToSevenSegment = 8'b11000001;
      4'b1100: DataInToSevenSegment = 8'b01100011;
      4'b1101: DataInToSevenSegment = 8'b10000101;
      4'b1110: DataInToSevenSegment = 8'b01100001;
      4'b1111: DataInToSevenSegment = 8'b01110001;
      default: DataInToSevenSegment = 8'b11111111;
    endcase
  end
endmodule
