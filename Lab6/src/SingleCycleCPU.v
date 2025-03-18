module SingleCycleCPU (
    input   wire        clk,
    input   wire        start,
    output  wire [7:0]  segments,
    output  wire [3:0]  an
);

// When input start is zero, cpu should reset
// When input start is high, cpu start running

// TODO: Connect wires to realize SingleCycleCPU and instantiate all modules related to seven-segment displays
// The following provides simple template,

wire signed [31:0] MuxToPC,PCOut,PCAdderOut,ICOut,muxToReg,reg1Out,reg2Out,reg5Out,ALUOut,DMOut,ImmgenOut,MuxALU1Out,MuxALU2Out,ALUControlOut,BrLtOut,BrEqOut;

wire memRead,memWrite,ALUSrc1,ALUSrc2,regWrite,PCSel;
wire [2:0] ALUOp;
wire [1:0] memtoReg;

PC m_PC(
    .clk(clk),
    .rst(start),
    .pc_i(MuxToPC),
    .pc_o(PCOut)
);

Adder m_Adder_1(
    .a(PCOut),
    .b(32'd4),
    .sum(PCAdderOut)
);

InstructionMemory m_InstMem(
    .readAddr(PCOut),
    .inst(ICOut)
);

Control m_Control(
    .opcode(ICOut[6:0]),
    .memRead(memRead),
    .memtoReg(memtoReg),
    .ALUOp(ALUOp),
    .memWrite(memWrite),
    .ALUSrc1(ALUSrc1),
    .ALUSrc2(ALUSrc2),
    .regWrite(regWrite),
    .PCSel(PCSel)
);

// ------------------------------------------
// For Student:
// Do not change the modules' instance names and I/O port names!!
// Or you will fail validation.
// By the way, you still have to wire up these modules

Register m_Register(
    .clk(clk),
    .rst(start),
    .regWrite(regWrite),
    .readReg1(ICOut[19:15]),
    .readReg2(ICOut[24:20]),
    .writeReg(ICOut[11:7]),
    .writeData(muxToReg),
    .readData1(reg1Out),
    .readData2(reg2Out),
    .reg5Data(reg5Out)
);

DataMemory m_DataMemory(
    .rst(start),
    .clk(clk),
    .memWrite(memWrite),
    .memRead(memRead),
    .address(ALUOut),
    .writeData(reg2Out),
    .readData(DMOut)
);

// ------------------------------------------

ImmGen m_ImmGen(
    .inst(ICOut),
    .imm(ImmgenOut)
);

Mux2to1 #(.size(32)) m_Mux_PC(
    .sel(PCSel),
    .s0(PCAdderOut),
    .s1(ALUOut),
    .out(MuxToPC)
);

Mux2to1 #(.size(32)) m_Mux_ALU_1(
    .sel(ALUSrc1),
    .s0(reg1Out),
    .s1(PCOut),
    .out(MuxALU1Out)
);

Mux2to1 #(.size(32)) m_Mux_ALU_2(
    .sel(ALUSrc2),
    .s0(reg2Out),
    .s1(ImmgenOut),
    .out(MuxALU2Out)
);

ALUCtrl m_ALUCtrl(
    .ALUOp(ALUOp),
    .funct7(ICOut[30]),
    .funct3(ICOut[14:12]),
    .ALUCtl(ALUControlOut)
);

ALU m_ALU(
    .ALUctl(ALUControlOut),
    .brLt(BrLtOut),
    .brEq(BrEqOut),
    .A(MuxALU1Out),
    .B(MuxALU2Out),
    .ALUOut(ALUOut)
);

Mux3to1 #(.size(32)) m_Mux_WriteData(
    .sel(memtoReg),
    .s0(ALUOut),
    .s1(DMOut),
    .s2(PCAdderOut),
    .out(muxToReg)
);

SevenSegmentDisplay sevenSegmentInst(
    .Clk(clk),
    .Reset(start),
    .DataIn(reg5Out),
    .Segments(segments),
    .AN(an)
);

BranchComp m_BranchComp(
    .rs1(reg1Out),
    .rs2(reg2Out),
    .brLt(BrLtOut),
    .brEq(BrEqOut)
);

endmodule
