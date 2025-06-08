`define kCYCLE_COUNTER_WIDTH  42        // Enough for several hours @ 48MHz clk
`define kINST_MEM_SIZE        16'h1000  // Modify linker script to e.g. `. = {kINST_MEM_SIZE};`
`define kDATA_MEM_SIZE        16'h0400
`define kALU_OP_SEL_WIDTH     9
`define kALU_BRANCH_SEL_WIDTH 6

/*
 *    7-bit RISC-V opcode field
 */
`define kRV32I_OPCODE_LUI    7'b0110111
`define kRV32I_OPCODE_AUIPC  7'b0010111
`define kRV32I_OPCODE_JAL    7'b1101111
`define kRV32I_OPCODE_JALR   7'b1100111
`define kRV32I_OPCODE_BRANCH 7'b1100011
`define kRV32I_OPCODE_LOAD   7'b0000011
`define kRV32I_OPCODE_STORE  7'b0100011
`define kRV32I_OPCODE_IMMOP  7'b0010011
`define kRV32I_OPCODE_ALUOP  7'b0110011

// Branching
`define kSAIL_ALUCTL_BEQ       6'b000001
`define kSAIL_ALUCTL_BNE       6'b000010
`define kSAIL_ALUCTL_BLT       6'b000100
`define kSAIL_ALUCTL_BGE       6'b001000
`define kSAIL_ALUCTL_BLTU      6'b010000
`define kSAIL_ALUCTL_BGEU      6'b100000
`define kSAIL_ALUCTL_B_INVALID 6'b000000

// Arithmetic and logic
`define kSAIL_ALUCTL_ADD     9'b000000001    // Same as ADDI, AUIPC, all loads, all stores
`define kSAIL_ALUCTL_SUB     9'b000000010
`define kSAIL_ALUCTL_AND     9'b000000100    // Same as ANDI, LUI
`define kSAIL_ALUCTL_OR      9'b000001000    // Same as ORI
`define kSAIL_ALUCTL_XOR     9'b000010000    // Same as XORI
`define kSAIL_ALUCTL_SLL     9'b000100000    // Same for all SLL variants
`define kSAIL_ALUCTL_SRL     9'b001000000    // Same for all SRL variants
`define kSAIL_ALUCTL_SRA     9'b010000000    // Same for all SRA variants
`define kSAIL_ALUCTL_SLT     9'b100000000    // Same for all SLT variants
`define kSAIL_ALUCTL_BRANCH  9'b000000010    // Same as SUB
`define kSAIL_ALUCTL_INVALID 9'b000000000

/*
 *    Low-order three bits of the FuncCode microarchtectural 4-bit field
 *
 *    Relation to the funct7 and funct3 fields of RISC-V ISA: FuncCode is
 *    funct3 with bit 5 of the funct7 (the only bit that changes in the
 *    RV32I isa) added on as the MSB.
 */
`define kRV32I_FUNCCODE_2to0_BEQ   3'b000
`define kRV32I_FUNCCODE_2to0_BNE   3'b001
`define kRV32I_FUNCCODE_2to0_BLT   3'b100
`define kRV32I_FUNCCODE_2to0_BGE   3'b101
`define kRV32I_FUNCCODE_2to0_BLTU  3'b110
`define kRV32I_FUNCCODE_2to0_BGEU  3'b111
`define kRV32I_FUNCCODE_2to0_LB    3'b000
`define kRV32I_FUNCCODE_2to0_LH    3'b001
`define kRV32I_FUNCCODE_2to0_LW    3'b010
`define kRV32I_FUNCCODE_2to0_LBU   3'b100
`define kRV32I_FUNCCODE_2to0_LHU   3'b101
`define kRV32I_FUNCCODE_2to0_SB    3'b000
`define kRV32I_FUNCCODE_2to0_SH    3'b001
`define kRV32I_FUNCCODE_2to0_SW    3'b010
`define kRV32I_FUNCCODE_2to0_ADDI  3'b000
`define kRV32I_FUNCCODE_2to0_SLTI  3'b010
`define kRV32I_FUNCCODE_2to0_SLTIU 3'b011
`define kRV32I_FUNCCODE_2to0_XORI  3'b100
`define kRV32I_FUNCCODE_2to0_ORI   3'b110
`define kRV32I_FUNCCODE_2to0_ANDI  3'b111
`define kRV32I_FUNCCODE_2to0_SLLI  3'b001
`define kRV32I_FUNCCODE_2to0_SLL   3'b001
`define kRV32I_FUNCCODE_2to0_SLT   3'b010
`define kRV32I_FUNCCODE_2to0_SLTU  3'b011
`define kRV32I_FUNCCODE_2to0_XOR   3'b100
`define kRV32I_FUNCCODE_2to0_OR    3'b110
`define kRV32I_FUNCCODE_2to0_AND   3'b111
