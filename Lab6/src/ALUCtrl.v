module ALUCtrl (
    input      [2:0] ALUOp,   // ALU operation
    input            funct7,  // funct7 field of instruction (only 30th bit of instruction)
    input      [2:0] funct3,  // funct3 field of instruction
    output reg [3:0] ALUCtl   // ALU control signal
);

    // TODO: implement your ALU control here
    // For testbench verifying, Do not modify input and output pin
    // For funct7, we care only 30th bit of instruction. Why?
    // See all R-type instructions in the lab and observe.

    // Hint: using ALUOp, funct7, funct3 to select exact operation
    localparam ADD = 4'b0000;
    localparam SUB = 4'b0001;
    localparam AND = 4'b0010;
    localparam OR = 4'b0011;
    localparam LESS = 4'b0100;
    localparam BEQ = 4'b0101;
    localparam BNE = 4'b0110;
    localparam BLT = 4'b0111;
    localparam BGE = 4'b1000;
    localparam JMP = 4'b1001;
    localparam IDK = 4'bxxxx;


    always @(*) begin
        case (ALUOp)
            3'b000:
            case (funct3)
                3'b000: if (funct7) ALUCtl = SUB;
 else ALUCtl = ADD;
                3'b111: ALUCtl = AND;
                3'b110: ALUCtl = OR;
                3'b010: ALUCtl = LESS;
            endcase
            3'b001:
            case (funct3)
                3'b000: ALUCtl = ADD;
                3'b111: ALUCtl = AND;
                3'b110: ALUCtl = OR;
                3'b010: ALUCtl = LESS;
            endcase
            3'b010: ALUCtl = ADD;
            3'b011: ALUCtl = ADD;
            3'b100:
            case (funct3)
                3'b000: ALUCtl = BEQ;
                3'b001: ALUCtl = BNE;
                3'b100: ALUCtl = BLT;
                3'b101: ALUCtl = BGE;
            endcase
            3'b101: ALUCtl = JMP;
            3'b110: ALUCtl = JMP;
        endcase
    end


endmodule

