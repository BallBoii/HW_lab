import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock

class CPU:
    def __init__(self):
        self.pc = 0
        self.registers = [0] * 32
        self.memory = [0] * 128
        self.instruction_memory = [0] * 128
        self.instruction_count = 0
        self.registers[2] = 128

    def load_instruction_memory(self, instruction_file_name, dut):
        with open(instruction_file_name, "r") as f:
            self.instruction_memory = [int(line.strip(), 2) for line in f.readlines()]
        for i in range(len(self.instruction_memory)):
            dut.m_InstMem.insts[i].value = self.instruction_memory[i]
        self.instruction_count = len(self.instruction_memory)

    def fetch_instruction(self):
        return (
            (self.instruction_memory[self.pc] << 24)
            | (self.instruction_memory[self.pc + 1] << 16)
            | (self.instruction_memory[self.pc + 2] << 8)
            | self.instruction_memory[self.pc + 3]
        )

    def convert_int_to_2scomplement(self, value):
        if value < 0:
            return (1 << 32) + value
        else:
            return value

    def convert_immediate_to_int(self, value, length):
        if (value >> (length - 1)) & 0x1:
            return value - (1 << length)
        else:
            return value

    def check_result(self, dut):
        # check registers value
        for i in range(32):
            # print(
            #     "debug register value",
            #     i,
            #     dut.m_Register.regs[i].value,
            #     self.registers[i],
            # )
            assert dut.m_Register.regs[i].value == self.convert_int_to_2scomplement(
                self.registers[i]
            )
        # check memory value
        for i in range(128):
            assert dut.m_DataMemory.data_memory[i].value == self.memory[i]

    def execute_one_instruction(self):

        if self.pc >= self.instruction_count:
            # end of program
            return False

        # fetch instruction
        instruction = self.fetch_instruction()

        # execute instruction
        opcode = instruction & 0x7F
        if opcode == 0x33:
            # R-type
            rd = (instruction >> 7) & 0x1F
            funct3 = (instruction >> 12) & 0x7
            rs1 = (instruction >> 15) & 0x1F
            rs2 = (instruction >> 20) & 0x1F
            funct7 = (instruction >> 25) & 0x7F
            if funct3 == 0x0 and funct7 == 0x00:
                # ADD Function
                self.registers[rd] = self.convert_immediate_to_int(
                    ((self.registers[rs1] + self.registers[rs2]) & 0xFFFFFFFF), 32
                )
            elif funct3 == 0x0 and funct7 == 0x20:
                # SUB Function
                self.registers[rd] = self.convert_immediate_to_int(
                    ((self.registers[rs1] - self.registers[rs2]) & 0xFFFFFFFF), 32
                )
            elif funct3 == 0x7 and funct7 == 0x00:
                # AND Function
                self.registers[rd] = self.registers[rs1] & self.registers[rs2]
            elif funct3 == 0x6 and funct7 == 0x00:
                # OR Function
                self.registers[rd] = self.registers[rs1] | self.registers[rs2]

            elif funct3 == 0x2 and funct7 == 0x00:
                # SLT Function
                if self.registers[rs1] < self.registers[rs2]:
                    self.registers[rd] = 1
                else:
                    self.registers[rd] = 0
            self.pc += 4
        elif opcode == 0x13:
            # I-type
            imm = instruction >> 20
            rd = (instruction >> 7) & 0x1F
            funct3 = (instruction >> 12) & 0x7
            rs1 = (instruction >> 15) & 0x1F
            if funct3 == 0x0:
                # ADDI Function
                self.registers[rd] = self.convert_immediate_to_int(
                    (
                        (self.registers[rs1] + self.convert_immediate_to_int(imm, 12))
                        & 0xFFFFFFFF
                    ),
                    32,
                )
            elif funct3 == 0x7:
                # ANDI Function
                self.registers[rd] = self.registers[
                    rs1
                ] & self.convert_immediate_to_int(imm, 12)

            elif funct3 == 0x6:
                # ORI Function
                self.registers[rd] = self.registers[
                    rs1
                ] | self.convert_immediate_to_int(imm, 12)
            elif funct3 == 0x2:
                # SLTI Function
                if self.registers[rs1] < self.convert_immediate_to_int(imm, 12):
                    self.registers[rd] = 1
                else:
                    self.registers[rd] = 0
            self.pc += 4
        elif opcode == 0x3:
            # I-type Load
            imm = instruction >> 20
            rd = (instruction >> 7) & 0x1F
            funct3 = (instruction >> 12) & 0x7
            rs1 = (instruction >> 15) & 0x1F
            # LW Function
            data_to_load = self.memory[
                self.registers[rs1] + self.convert_immediate_to_int(imm, 12)
            ]
            data_to_load |= (
                self.memory[
                    self.registers[rs1] + self.convert_immediate_to_int(imm, 12) + 1
                ]
                << 8
            )
            data_to_load |= (
                self.memory[
                    self.registers[rs1] + self.convert_immediate_to_int(imm, 12) + 2
                ]
                << 16
            )
            data_to_load |= (
                self.memory[
                    self.registers[rs1] + self.convert_immediate_to_int(imm, 12) + 3
                ]
                << 24
            )
            self.registers[rd] = self.convert_immediate_to_int(data_to_load, 32)
            self.pc += 4
        elif opcode == 0x23:
            # S-type Store
            offset = self.convert_immediate_to_int(
                (instruction >> 25) << 5 | (instruction >> 7) & 0x1F, 12
            )
            rs1 = (instruction >> 15) & 0x1F
            rs2 = (instruction >> 20) & 0x1F
            # SW Function
            data_to_store = self.convert_int_to_2scomplement(self.registers[rs2])
            self.memory[self.registers[rs1] + offset] = data_to_store & 0xFF
            self.memory[self.registers[rs1] + offset + 1] = (data_to_store >> 8) & 0xFF
            self.memory[self.registers[rs1] + offset + 2] = (data_to_store >> 16) & 0xFF
            self.memory[self.registers[rs1] + offset + 3] = (data_to_store >> 24) & 0xFF
            self.pc += 4
        elif opcode == 0x63:
            # B-type
            offset = (
                (instruction >> 31) << 12
                | ((instruction >> 25) & 0x3F) << 5
                | ((instruction >> 8) & 0xF) << 1
                | (((instruction >> 7) & 0x1) << 11)
            )
            rs1 = (instruction >> 15) & 0x1F
            rs2 = (instruction >> 20) & 0x1F
            funct3 = (instruction >> 12) & 0x7
            if funct3 == 0x0:
                # BEQ Function
                if self.registers[rs1] == self.registers[rs2]:
                    self.pc += self.convert_immediate_to_int(offset, 13)
                else:
                    self.pc += 4
            elif funct3 == 0x1:
                # BNE Function
                if self.registers[rs1] != self.registers[rs2]:
                    self.pc += self.convert_immediate_to_int(offset, 13)
                else:
                    self.pc += 4
            elif funct3 == 0x4:
                # BLT Function
                if self.registers[rs1] < self.registers[rs2]:
                    self.pc += self.convert_immediate_to_int(offset, 13)
                else:
                    self.pc += 4
            elif funct3 == 0x5:
                # BGE Function
                if self.registers[rs1] >= self.registers[rs2]:
                    self.pc += self.convert_immediate_to_int(offset, 13)
                else:
                    self.pc += 4
        elif opcode == 0x6F:
            # J-type
            imm = (
                (instruction >> 31) << 20
                | ((instruction >> 12) & 0xFF) << 12
                | ((instruction >> 20) & 0x1) << 11
                | ((instruction >> 21) & 0x3FF) << 1
            )
            rd = (instruction >> 7) & 0x1F
            # JAL Function
            self.registers[rd] = self.pc + 4
            self.pc += self.convert_immediate_to_int(imm, 21)
        elif opcode == 0x67:
            # I-type
            imm = instruction >> 20
            rd = (instruction >> 7) & 0x1F
            rs1 = (instruction >> 15) & 0x1F
            # JALR Function
            self.registers[rd] = self.pc + 4
            self.pc = (
                self.registers[rs1] + self.convert_immediate_to_int(imm, 12)
            ) & 0xFFFFFFFE
        elif instruction == 0x0:
            # NOP
            self.pc += 4
        self.registers[0] = 0
        return True

async def run_testcase(dut, testcase_filename):
    # set timeout in case of infinite loop
    program_running_limit = 10000
    """Try accessing the design."""
    # create the clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    # create the CPU
    virtual_cpu = CPU()
    # load instruction memory
    virtual_cpu.load_instruction_memory(testcase_filename, dut)
    dut._log.info("Running test from file: " + testcase_filename)
    # reset
    dut.start.value = 0
    await Timer(15, units="ns")
    dut.start.value = 1
    virtual_cpu.check_result(dut)
    dut._log.info("Reset Complete")
    await Timer(10, units="ns")
    while virtual_cpu.execute_one_instruction() and program_running_limit > 0:
        # check result
        virtual_cpu.check_result(dut)
        await Timer(10, units="ns")
        program_running_limit -= 1
    dut._log.info("Test Complete")

@cocotb.test()
async def Testcase01(dut):
    await run_testcase(dut, "./testcases/testcase_01.txt")

@cocotb.test()
async def Testcase02(dut):
    await run_testcase(dut, "./testcases/testcase_02.txt")

@cocotb.test()
async def Testcase03(dut):
    await run_testcase(dut, "./testcases/testcase_03.txt")

@cocotb.test()
async def Testcase04(dut):
    await run_testcase(dut, "./testcases/testcase_04.txt")

@cocotb.test()
async def Testcase05(dut):
    await run_testcase(dut, "./testcases/testcase_05.txt")

@cocotb.test()
async def Testcase06(dut):
    await run_testcase(dut, "./testcases/testcase_06.txt")

@cocotb.test()
async def Testcase07(dut):
    await run_testcase(dut, "./testcases/testcase_07.txt")

@cocotb.test()
async def Testcase08(dut):
    await run_testcase(dut, "./testcases/testcase_08.txt")