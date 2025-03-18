module Control (
    input      [6:0] opcode,    // opcode field of instruction
    output reg       memRead,   // memory read signal
    output reg [1:0] memtoReg,  // memory to register signal
    output reg [2:0] ALUOp,     // ALU operation signal
    output reg       memWrite,  // memory write signal
    output reg       ALUSrc1,   // ALU source 1 signal (for MUX)
    output reg       ALUSrc2,   // ALU source 2 signal (for MUX)
    output reg       regWrite,  // register write signal
    output reg       PCSel      // PC select signal (for MUX PC)
);

    always @(*) begin
        case (opcode)
            7'b0110011: begin // R-type [OP_R]
                memRead  = 0;
                memtoReg = 2'b00;
                ALUOp    = 3'b000;
                memWrite = 0;
                PCSel    = 0;
                ALUSrc1  = 0;
                ALUSrc2  = 0;
                regWrite = 1;
            end
            7'b0010011: begin // I-type (ALU immediate) [OP_I]
                memRead  = 0;
                memtoReg = 2'b00;
                ALUOp    = 3'b001;
                memWrite = 0;
                PCSel    = 0;
                ALUSrc1  = 0;
                ALUSrc2  = 1;
                regWrite = 1;
            end
            7'b0000011: begin // Load [OP_LW]
                memRead  = 1;
                memtoReg = 2'b01;
                ALUOp    = 3'b010;
                memWrite = 0;
                PCSel    = 0;
                ALUSrc1  = 0;
                ALUSrc2  = 1;
                regWrite = 1;
            end
            7'b0100011: begin // Store [OP_SW]
                memRead  = 0;
                memtoReg = 2'b00;
                ALUOp    = 3'b011;
                memWrite = 1;
                PCSel    = 0;
                ALUSrc1  = 0;
                ALUSrc2  = 1;
                regWrite = 0;
            end
            7'b1100011: begin // Branch [OP_BRANCH]
                memRead  = 0;
                memtoReg = 2'b00;
                ALUOp    = 3'b100;
                memWrite = 0;
                PCSel    = 1;
                ALUSrc1  = 1;
                ALUSrc2  = 1;
                regWrite = 0;
            end
            7'b1101111: begin // JAL [OP_JAL]
                memRead  = 0;
                memtoReg = 2'b10;
                ALUOp    = 3'b101;
                memWrite = 0;
                PCSel    = 1;
                ALUSrc1  = 1;
                ALUSrc2  = 1;
                regWrite = 1;
            end
            7'b1100111 : begin // Default case
                memRead  = 0;
                memtoReg = 2'b10;
                ALUOp    = 3'b110;
                memWrite = 0;
                PCSel    = 1;
                ALUSrc1  = 0;
                ALUSrc2  = 1;
                regWrite = 1;
            end
        endcase
    end
endmodule