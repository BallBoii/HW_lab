`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 01/26/2025 11:55:41 PM
// Design Name: UARTLedSystem
// Module Name: LedController
// Project Name: UARTLedSystem
// Target Devices: Basys3
// Tool Versions: 2023.2
// Description: Read data from the FIFO then control the LEDs.
//////////////////////////////////////////////////////////////////////////////////


module LedController (
    input  wire       Clk,
    input  wire       Reset,
    // FIFO interface
    input  wire [7:0] DataIn,
    input  wire       empty,
    output wire       ReadEnable,
    input  wire       DataValid,
    // LED interface
    output wire [15:0] Led
);
  // Add your code here
    reg [15:0] LedReg = 0;
    assign ReadEnable = 1;
    assign Led = LedReg;
    always @(posedge Clk) begin
        if (Reset) begin
            LedReg <= 0;
        end else begin
            if (DataValid) begin
                case (DataIn)
                    8'h30: LedReg[0] <= ~LedReg[0] ;
                    8'h31: LedReg[1] <= ~LedReg[1] ;
                    8'h32: LedReg[2] <= ~LedReg[2] ;
                    8'h33: LedReg[3] <= ~LedReg[3] ;
                    8'h34: LedReg[4] <= ~LedReg[4] ;
                    8'h35: LedReg[5] <= ~LedReg[5] ;
                    8'h36: LedReg[6] <= ~LedReg[6] ;
                    8'h37: LedReg[7] <= ~LedReg[7] ;
                    8'h38: LedReg[8] <= ~LedReg[8] ;
                    8'h39: LedReg[9] <= ~LedReg[9] ;
                    8'h61: LedReg[10] <= ~LedReg[10] ;
                    8'h62: LedReg[11] <= ~LedReg[11] ;
                    8'h63: LedReg[12] <= ~LedReg[12] ;
                    8'h64: LedReg[13] <= ~LedReg[13] ;
                    8'h65: LedReg[14] <= ~LedReg[14] ;
                    8'h66: LedReg[15] <= ~LedReg[15] ;
                    default: LedReg <= LedReg;
                endcase
            end
        end
    end
  // End or your code
endmodule
