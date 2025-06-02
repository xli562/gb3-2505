`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

module alu_control (
    input  wire [3:0] FuncCode,
    input  wire [6:0] Opcode,
    output reg  [9:0] ALUCtl,
    output reg  [6:0] BRUCtl,
);
    initial begin
        ALUCtl = 10'b0;
    end

    always @(*) begin
        case (Opcode)
            // LUI, U-Type
            `kRV32I_INSTRUCTION_OPCODE_LUI:
                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_AND;      // LUI, same kSAIL as AND
            // AUIPC, U-Type
            `kRV32I_INSTRUCTION_OPCODE_AUIPC:
                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_ADD;    // AUIPC, same kSAIL as ADD
            // JAL, UJ-Type
            `kRV32I_INSTRUCTION_OPCODE_JAL:
                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_ILLEGAL;
            // JALR, I-Type
            `kRV32I_INSTRUCTION_OPCODE_JALR:
                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_ILLEGAL;
            // Branch, SB-Type
            `kRV32I_INSTRUCTION_OPCODE_BRANCH:
                case (FuncCode[2:0])
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_BEQ:
                        BRUCtl = `kSAIL_MICROARCHITECTURE_BRUCTL_6to0_BEQ; //BEQ conditions
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_BNE:
                        BRUCtl = `kSAIL_MICROARCHITECTURE_BRUCTL_6to0_BNE; //BNE conditions
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_BLT:
                        BRUCtl = `kSAIL_MICROARCHITECTURE_BRUCTL_6to0_BLT; //BLT conditions
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_BGE:
                        BRUCtl = `kSAIL_MICROARCHITECTURE_BRUCTL_6to0_BGE; //BGE conditions
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_BLTU:
                        BRUCtl = `kSAIL_MICROARCHITECTURE_BRUCTL_6to0_BLTU; //BLTU conditions
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_BGEU:
                        BRUCtl = `kSAIL_MICROARCHITECTURE_BRUCTL_6to0_BGEU; //BGEU conditions
                    default:
                        BRUCtl = `kSAIL_MICROARCHITECTURE_BRUCTL_6to0_ILLEGAL;
                endcase

            // Loads, I-Type
            `kRV32I_INSTRUCTION_OPCODE_LOAD:
                case (FuncCode[2:0])
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_LB:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_ADD; //LB, same kSAIL as ADD
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_LH:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_ADD; //LH, same kSAIL as ADD
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_LW:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_ADD; //LW, same kSAIL as ADD
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_LBU:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_ADD; //LBU, same kSAIL as ADD
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_LHU:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_ADD; //LHU, same kSAIL as ADD
                    default:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_ILLEGAL;
                endcase

            // Stores, S-Type
            `kRV32I_INSTRUCTION_OPCODE_STORE:
                case (FuncCode[2:0])
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_SB:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_ADD; //SB, same kSAIL as ADD
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_SH:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_ADD; //SH, same kSAIL as ADD
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_SW:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_ADD; //SW, same kSAIL as ADD
                    default:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_ILLEGAL;
                endcase

            // Immediate operations, I-Type
            `kRV32I_INSTRUCTION_OPCODE_IMMOP:
                case (FuncCode[2:0])
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_ADDI:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_ADD; //ADDI, same kSAIL as ADD
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_SLTI:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_SLT; //SLTI, same kSAIL as SLT
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_SLTIU:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_SLT; //SLTIU, same kSAIL as SLT
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_XORI:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_XOR; //XORI, same kSAIL as XOR
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_ORI:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_OR; //ORI, same kSAIL as OR
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_ANDI:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_AND; //ANDI, same kSAIL as AND
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_SLLI:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_SLL; //SLLI, same kSAIL as SLL
                    3'b101:
                        case (FuncCode[3])
                            1'b0:
                                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_SRL; //SRLI, same kSAIL as SRL
                            1'b1:
                                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_SRA; //SRAI, same kSAIL as SRA
                            default:
                                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_ILLEGAL;
                        endcase
                    default:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_ILLEGAL;
                endcase

            // ADD SUB & logic shifts, R-Type
            `kRV32I_INSTRUCTION_OPCODE_ALUOP:
                case (FuncCode[2:0])
                    3'b000:
                        case(FuncCode[3])
                            1'b0:
                                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_ADD; //ADD
                            1'b1:
                                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_SUB; //SUB
                            default:
                                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_ILLEGAL;
                        endcase
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_SLTU:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_SLTU;
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_SLT:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_SLT;
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_SLL:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_SLL;
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_XOR:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_XOR;
                    3'b101:
                        case(FuncCode[3])
                            1'b0:
                                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_SRL; //SRL
                            1'b1:
                                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_SRA; //SRA untested
                            default:
                                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_ILLEGAL;
                        endcase
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_OR:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_OR; //OR
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_AND:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_AND; //AND
                    default:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_ILLEGAL;
                endcase

            default:
                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_9to0_ILLEGAL;
        endcase
    end
endmodule
