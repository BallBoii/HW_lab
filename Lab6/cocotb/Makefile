# Makefile

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# VERILOG_SOURCES += $(PWD)/../src/SingleCycleCPU.v $(PWD)/../src/Adder.v $(PWD)/../src/ALU.v $(PWD)/../src/ALUCtrl.v $(PWD)/../src/BranchComp.v $(PWD)/../src/Control.v $(PWD)/../src/DataMemory.v $(PWD)/../src/ImmGen.v $(PWD)/../src/Mux2to1.v $(PWD)/../src/Mux3to1.v $(PWD)/../src/PC.v $(PWD)/../src/Register.v
# VERILOG_SOURCES += $(PWD)/InstructionMemory.v
VERILOG_SOURCES += $(PWD)/../src/*.v
# use VHDL_SOURCES for VHDL files

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = SingleCycleCPU

# MODULE is the basename of the Python test file
MODULE = TB

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim