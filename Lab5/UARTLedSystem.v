`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 01/26/2025 11:53:46 PM
// Design Name: UARTLedSystem
// Module Name: UARTLedSystem
// Project Name: UARTLedSystem
// Target Devices: Basys3
// Tool Versions: 2023.2
// Description: The top level module for the UARTLedSystem project.
//////////////////////////////////////////////////////////////////////////////////


module UARTLedSystem (
    input  wire        Clk,
    input  wire        Reset,
    input  wire        SentUartData,
    input  wire [ 7:0] Sw,
    output wire        UARTTx,
    input  wire        UARTRx,
    output wire [15:0] Led
);
  // Add your code here
  wire       CleanSentUartData;
  wire       TxFifoEmpty;
  wire [7:0] TxFifoDataOut;
  wire       TxFifoReadEnable;
  wire       TxFifoReadValid;
  InputSanitizer InputSanitizerInst (
      .Clk(Clk),
      .Reset(Reset),
      .DataIn(SentUartData),
      .DataOut(CleanSentUartData)
  );
  DataBuffer TxDataBufferInst (
      .clk  (Clk),
      .srst (Reset),
      // FIFO Write Interface
      .full (),
      .din  (Sw),
      .wr_en(CleanSentUartData),
      // FIFO Read Interface
      .empty(TxFifoEmpty),
      .dout (TxFifoDataOut),
      .rd_en(TxFifoReadEnable),
      .valid(TxFifoReadValid)
  );
  UARTTx UARTTxInst (
      .Clk       (Clk),
      .Reset     (Reset),
      .Tx        (UARTTx),
      .DataIn    (TxFifoDataOut),
      .Empty     (TxFifoEmpty),
      .ReadEnable(TxFifoReadEnable),
      .DataValid (TxFifoReadValid)
  );
  wire [7:0] RxFifoDataIn;
  wire       RxFifoWriteEnable;
  wire       RxFifoFull;
  wire       RxFifoEmpty;
  wire [7:0] RxFifoDataOut;
  wire       RxFifoReadEnable;
  wire       RxFifoReadValid;
  UARTRx UARTRxInst (
      .Clk        (Clk),
      .Reset      (Reset),
      .Rx         (UARTRx),
      .DataOut    (RxFifoDataIn),
      .WriteEnable(RxFifoWriteEnable),
      .Full       (RxFifoFull)
  );
  DataBuffer RxDataBufferInst (
      .clk  (Clk),
      .srst (Reset),
      // FIFO Write Interface
      .full (RxFifoFull),
      .din  (RxFifoDataIn),
      .wr_en(RxFifoWriteEnable),
      // FIFO Read Interface
      .empty(RxFifoEmpty),
      .dout (RxFifoDataOut),
      .rd_en(RxFifoReadEnable),
      .valid(RxFifoReadValid)
  );
  LedController LedControllerInst (
      .Clk       (Clk),
      .Reset     (Reset),
      .DataIn    (RxFifoDataOut),
      .empty     (RxFifoEmpty),
      .ReadEnable(RxFifoReadEnable),
      .DataValid (RxFifoReadValid),
      .Led       (Led)
  );
  // End or your code
endmodule
