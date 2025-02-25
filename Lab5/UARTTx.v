`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 01/26/2025 11:54:27 PM
// Design Name: UARTLedSystem
// Module Name: UARTTx
// Project Name: UARTLedSystem
// Target Devices: Basys3
// Tool Versions: 2023.2
// Description: Tx module for UART communication. Reads data from the FIFO then sends
//              it to Host PC via UART interface.
//////////////////////////////////////////////////////////////////////////////////

module UARTTx (
    input  wire       Clk,
    input  wire       Reset,
    // UART interface
    output wire       Tx,
    // FIFO interface
    input  wire [7:0] DataIn,
    input  wire       Empty,
    output wire        ReadEnable,
    input  wire       DataValid
);

  // State encoding
  localparam IDLE      = 4'd0;
  localparam START_BIT = 4'd1;
  localparam DATA      = 4'd2;
  localparam STOP_BIT  = 4'd3;

  // Baud rate period: adjust BAUD_TICK to suit your baud rate requirements.
  localparam BAUD_TICK = 868;

  reg [3:0] state;
  reg [7:0] data_to_send;      // Data register for transmission
  reg tx_reg;                  // Register driving Tx output
  reg [9:0] baud_counter;      // Counter for baud period (10 bits wide is sufficient)
  reg [3:0] bit_index;         // 4-bit counter to index through the 8 data bits
   
  reg readReg;
  assign ReadEnable = readReg;
  assign Tx = tx_reg;

  always @(posedge Clk) begin
    if (Reset) begin
      state         <= IDLE;
      tx_reg        <= 1'b1;
      baud_counter  <= 0;
      bit_index     <= 0;
      readReg    <= 1'b0;
    end else begin
      case (state)
        IDLE: begin
          tx_reg      <= 1'b1;      // Idle line is high
          baud_counter<= 0;
          bit_index   <= 0;
          if (!Empty) begin
            readReg   <= 1'b1;
          end
          if (DataValid) begin
            data_to_send <= DataIn; // Latch the data from FIFO
            state        <= START_BIT;
            tx_reg <= 0;
            readReg <= 0;
          end 
        end

        START_BIT: begin
            if (baud_counter == 868) begin
                baud_counter <= 0;
                state <= DATA;
            end else baud_counter <= baud_counter + 1;
        end

        DATA: begin
            if (baud_counter == 868) begin
                baud_counter <= 0;
                if (bit_index==8) begin
                    state <= STOP_BIT;
                    tx_reg <= 1;
                end else begin
                    tx_reg <= data_to_send[bit_index];
                    bit_index <= bit_index + 1;
                end
            end else baud_counter <= baud_counter + 1;
        end

        STOP_BIT: begin
          if (baud_counter == 868) begin
            baud_counter <= 0;
            state <= IDLE;
          end else baud_counter <= baud_counter + 1;
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule
