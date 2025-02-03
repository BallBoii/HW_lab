`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 01/15/2025 09:47:52 PM
// Design Name: BinaryToDecimal
// Module Name: ROMUnit
// Project Name: BinaryToDecimal
// Target Devices: Basys3
// Tool Versions: 2023.2
// Description: The ROM Unit for the Binary to Decimal conversion Module.
//              This version implements a synchronous ROM that outputs a 16-bit
//              value. In this example, the ROM is preloaded with the ASCII codes
//              for the two-digit decimal representation of numbers 0-63.
//////////////////////////////////////////////////////////////////////////////////

module ROMUnit (
    input  wire [5:0] Address,  // Address selects one of 64 words
    input  wire       Clk,      // Synchronous clock
    input  wire       Reset,    // Active-high reset
    output wire [15:0] DataOut  // 16-bit output (e.g. two ASCII characters)
);
  reg [7:0] mem [63:0];
  integer i;
  initial begin
    for (i = 0; i < 64; i = i + 1) begin
      mem[i] = ( (i / 10) * 16 ) + (i % 10);  // Packed BCD
    end
  end

  reg [15:0] dataReg;
  assign DataOut = dataReg;

  always @(posedge Clk or posedge Reset) begin
    if (Reset)
      dataReg <= 8'h00;
    else
      dataReg <= mem[Address];
  end


`ifdef COCOTB_SIM
  // For simulation purposes, dump waveform data to a VCD file.
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, ROMUnit);
  end
`endif

endmodule
