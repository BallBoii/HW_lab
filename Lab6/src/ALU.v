module ALU (
    input             [ 3:0] ALUctl,  // ALU operation selector
    input                    brLt,    // Branch Less Than
    input                    brEq,    // Branch Equal
    input  signed     [31:0] A, B,    // Operands
    output reg signed [31:0] ALUOut   // ALU Output
);

    always @(*) begin
        case (ALUctl)
            4'b0000: ALUOut = $signed(A) + $signed(B);  // ADD
            4'b0001: ALUOut = $signed(A) - $signed(B);  // SUB
            4'b0010: ALUOut = A & B;  // AND
            4'b0011: ALUOut = A | B;  // OR
            4'b0100: ALUOut = ($signed(A) < $signed(B)) ? 1 : 0;  // LESS THAN
            4'b0101: ALUOut = brEq ? (A + B) : (A + 4);  // BEQ
            4'b0110: ALUOut = !brEq ? (A + B) : (A + 4); // BNE
            4'b0111: ALUOut = brLt ? (A + B) : (A + 4);  // BLT
            4'b1000: ALUOut = !brLt ? (A + B) : (A + 4); // BGE
            4'b1001: ALUOut = A + B;  // JMP
            default: ALUOut = 0;  // Default case
        endcase
    end

endmodule
