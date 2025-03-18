module BranchComp (
    input  [31:0] rs1,   // First register value
    input  [31:0] rs2,   // Second register value
    output        brLt,  // Branch less-than condition
    output        brEq   // Branch equality condition
);

    // Compare rs1 and rs2 for equality (works regardless of sign)
    assign brEq = (rs1 == rs2);

    // For BLT, perform a signed comparison by casting inputs to signed values.
    assign brLt = ($signed(rs1) < $signed(rs2));

endmodule
