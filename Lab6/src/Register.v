// For Student: 
// Do not modify this file!

module Register (
    input clk,                  // Clock
    input rst,                  // Active low reset
    input regWrite,             // Register write signal
    input [4:0] readReg1,       // Specify register to read (port 1)
    input [4:0] readReg2,       // Specify register to read (port 2)
    input [4:0] writeReg,       // Specify register to write
    input [31:0] writeData,     // Value to write to register
    output [31:0] readData1,    // Value of register at port 1
    output [31:0] readData2,    // Value of register at port 2
    output [31:0] reg5Data      // Value of register 5 (for seven-segment display)
);
    reg [31:0] regs [0:31];


    assign readData1 = regs[readReg1];
    assign readData2 = regs[readReg2];
    
    assign reg5Data = regs[5];
     
    always @(negedge clk, negedge rst) begin
        if(~rst) begin
            regs[0] <= 0; regs[1] <= 0; regs[2] <= 32'd128; regs[3] <= 0; 
            regs[4] <= 0; regs[5] <= 0; regs[6] <= 0; regs[7] <= 0; 
            regs[8] <= 0; regs[9] <= 0; regs[10] <= 0; regs[11] <= 0; 
            regs[12] <= 0; regs[13] <= 0; regs[14] <= 0; regs[15] <= 0; 
            regs[16] <= 0; regs[17] <= 0; regs[18] <= 0; regs[19] <= 0; 
            regs[20] <= 0; regs[21] <= 0; regs[22] <= 0; regs[23] <= 0; 
            regs[24] <= 0; regs[25] <= 0; regs[26] <= 0; regs[27] <= 0; 
            regs[28] <= 0; regs[29] <= 0; regs[30] <= 0; regs[31] <= 0;        
        end
        else if(regWrite)
            regs[writeReg] <= (writeReg == 0) ? 0 : writeData;
    end

endmodule

