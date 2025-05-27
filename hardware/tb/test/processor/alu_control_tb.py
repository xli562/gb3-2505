import cocotb
from cocotb.clock import Timer
from cocotb.binary import BinaryValue
from cocotb.result import TestFailure

from utils.defines import *

@cocotb.test()
async def test_all_alu_control_cases(dut):
    """ Exhaustive test of alu_control """

    # helper to apply inputs and sample output
    async def apply(opcode, funccode, expected):
        dut.Opcode.value = BinaryValue(opcode, n_bits=7)
        dut.FuncCode.value = BinaryValue(funccode, n_bits=4)
        await Timer(1, units="ns")
        result = int(dut.ALUCtl.value)
        if result != expected:
            raise TestFailure(
                f"Mismatch for OPCODE=0b{opcode:07b} "
                f"FUNC=0b{funccode:04b}: got 0b{result:07b}, "
                f"expected 0b{expected:07b}"
            )

    # List all cases: (opcode, funccode, expected_aluctl)
    cases = [
        # U-type
        (kRV32I_INSTRUCTION_OPCODE_LUI,    0, kSAIL_MICROARCHITECTURE_ALUCTL_6to0_LUI),
        (kRV32I_INSTRUCTION_OPCODE_AUIPC,  0, kSAIL_MICROARCHITECTURE_ALUCTL_6to0_AUIPC),

        # Jumps
        (kRV32I_INSTRUCTION_OPCODE_JAL,    0, kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL),
        (kRV32I_INSTRUCTION_OPCODE_JALR,   0, kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL),

        # Branches
        *[
            (kRV32I_INSTRUCTION_OPCODE_BRANCH, cc, aluctl)
            for cc, aluctl in [
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_BEQ,  kSAIL_MICROARCHITECTURE_ALUCTL_6to0_BEQ),
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_BNE,  kSAIL_MICROARCHITECTURE_ALUCTL_6to0_BNE),
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_BLT,  kSAIL_MICROARCHITECTURE_ALUCTL_6to0_BLT),
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_BGE,  kSAIL_MICROARCHITECTURE_ALUCTL_6to0_BGE),
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_BLTU, kSAIL_MICROARCHITECTURE_ALUCTL_6to0_BLTU),
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_BGEU, kSAIL_MICROARCHITECTURE_ALUCTL_6to0_BGEU),
            ]
        ],

        # Loads
        *[
            (kRV32I_INSTRUCTION_OPCODE_LOAD, cc, aluctl)
            for cc, aluctl in [
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_LB,  kSAIL_MICROARCHITECTURE_ALUCTL_6to0_LB),
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_LH,  kSAIL_MICROARCHITECTURE_ALUCTL_6to0_LH),
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_LW,  kSAIL_MICROARCHITECTURE_ALUCTL_6to0_LW),
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_LBU, kSAIL_MICROARCHITECTURE_ALUCTL_6to0_LBU),
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_LHU, kSAIL_MICROARCHITECTURE_ALUCTL_6to0_LHU),
            ]
        ],

        # Stores
        *[
            (kRV32I_INSTRUCTION_OPCODE_STORE, cc, aluctl)
            for cc, aluctl in [
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_SB,  kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SB),
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_SH,  kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SH),
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_SW,  kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SW),
            ]
        ],

        # Immediate ops
        *[
            (kRV32I_INSTRUCTION_OPCODE_IMMOP, cc, aluctl)
            for cc, aluctl in [
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_ADDI, kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ADDI),
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_SLTI, kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SLTI),
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_SLTIU,kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SLTIU),
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_XORI, kSAIL_MICROARCHITECTURE_ALUCTL_6to0_XORI),
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_ORI,  kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ORI),
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_ANDI, kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ANDI),
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_SLLI, kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SLLI),
            ]
        ],

        # R-type ALU ops
        *[
            (kRV32I_INSTRUCTION_OPCODE_ALUOP, cc, aluctl)
            for cc, aluctl in [
                (0b000, kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ADD),  # ADD
                (0b100, kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SUB),  # SUB (funccode[3]=1)
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_SLL,  kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SLL),
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_SLT,  kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SLT),
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_SLTU, kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SLTU),
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_XOR,  kSAIL_MICROARCHITECTURE_ALUCTL_6to0_XOR),
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_OR,   kSAIL_MICROARCHITECTURE_ALUCTL_6to0_OR),
                (kRV32I_INSTRUCTION_FUNCCODE_2to0_AND,  kSAIL_MICROARCHITECTURE_ALUCTL_6to0_AND),
            ]
        ],

        # CSR ops
        *[
            (kRV32I_INSTRUCTION_OPCODE_CSRR, cc, aluctl)
            for cc, aluctl in [
                (kRV32I_INSTRUCTION_FUNCCODE_1to0_CSRRW, kSAIL_MICROARCHITECTURE_ALUCTL_6to0_CSRRW),
                (kRV32I_INSTRUCTION_FUNCCODE_1to0_CSRRS, kSAIL_MICROARCHITECTURE_ALUCTL_6to0_CSRRS),
                (kRV32I_INSTRUCTION_FUNCCODE_1to0_CSRRC, kSAIL_MICROARCHITECTURE_ALUCTL_6to0_CSRRC),
            ]
        ],
    ]

    # Run through every single case
    for opcode, func, expect in cases:
        await apply(opcode, func, expect)

    # And one random illegal catch-all
    await apply(0x7F, 0xF, kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL)
