`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

module alu_control (
    input  wire       reset_n_i,
    input  wire       funct7_bit5_i,
    input  wire [2:0] funct3_i,
    input  wire [6:0] opcode_i,
    output reg  [`kALU_OP_SEL_WIDTH-1:0] alu_op_sel_o,
    output reg  [`kALU_BRANCH_SEL_WIDTH-1:0] alu_branch_sel_o
);
    reg [6:0] ALUCtl;
    always @(*) begin
        if (~reset_n_i) begin
            ALUCtl = 0;
        end else begin
            case (opcode_i)
                `kRV32I_INSTRUCTION_OPCODE_LUI:
                    ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_LUI;
                `kRV32I_INSTRUCTION_OPCODE_AUIPC:
                    ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_AUIPC;
                `kRV32I_INSTRUCTION_OPCODE_JAL:
                    ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
                `kRV32I_INSTRUCTION_OPCODE_JALR:
                    ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
                `kRV32I_INSTRUCTION_OPCODE_BRANCH:
                    case (funct3_i)
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_BEQ:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_BEQ;
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_BNE:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_BNE;
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_BLT:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_BLT;
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_BGE:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_BGE;
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_BLTU:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_BLTU;
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_BGEU:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_BGEU;
                        default:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
                    endcase

                `kRV32I_INSTRUCTION_OPCODE_LOAD:
                    case (funct3_i)
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_LB:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_LB;
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_LH:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_LH;
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_LW:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_LW;
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_LBU:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_LBU;
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_LHU:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_LHU;
                        default:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
                    endcase

                `kRV32I_INSTRUCTION_OPCODE_STORE:
                    case (funct3_i)
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_SB:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SB;
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_SH:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SH;
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_SW:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SW;
                        default:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
                    endcase

                `kRV32I_INSTRUCTION_OPCODE_IMMOP:
                    case (funct3_i)
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_ADDI:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ADDI;
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_SLTI:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SLTI;
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_SLTIU:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SLTIU;
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_XORI:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_XORI;
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_ORI:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ORI;
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_ANDI:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ANDI;
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_SLLI:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SLLI;
                        3'b101:
                            case (funct7_bit5_i)
                                1'b0:
                                    ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SRLI;
                                1'b1:
                                    ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SRAI;
                                default:
                                    ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
                            endcase
                        default:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
                    endcase

                `kRV32I_INSTRUCTION_OPCODE_ALUOP:
                    case (funct3_i)
                        3'b000:
                            case(funct7_bit5_i)
                                1'b0:
                                    ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ADD;
                                1'b1:
                                    ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SUB;
                                default:
                                    ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
                            endcase
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_SLL:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SLL;
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_SLT:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SLT;
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_SLTU:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SLTU;
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_XOR:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_XOR;
                        3'b101:
                            case(funct7_bit5_i)
                                1'b0:
                                    ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SRL;
                                1'b1:
                                    ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SRA; //SRA untested
                                default:
                                    ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
                            endcase
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_OR:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_OR;
                        `kRV32I_INSTRUCTION_FUNCCODE_2to0_AND:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_AND;
                        default:
                            ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
                    endcase

                default:
                    ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
            endcase
        end
    end
    assign {alu_branch_sel_o, alu_op_sel_o} = ALUCtl;
endmodule
