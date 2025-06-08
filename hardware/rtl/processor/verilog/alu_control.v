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
    always @(*) begin
        alu_op_sel_o = `kSAIL_ALUCTL_6to0_ILLEGAL;
        alu_branch_sel_o = '0;
        if (~reset_n_i) begin
            alu_op_sel_o = '0;
            alu_branch_sel_o = '0;
        end else begin
            case (opcode_i)
                `kRV32I_OPCODE_LUI:
                    alu_op_sel_o = `kSAIL_ALUCTL_6to0_AND;
                `kRV32I_OPCODE_AUIPC:
                    alu_op_sel_o = `kSAIL_ALUCTL_6to0_ADD;
                `kRV32I_OPCODE_JAL:
                    alu_op_sel_o = `kSAIL_ALUCTL_6to0_ILLEGAL;
                `kRV32I_OPCODE_JALR:
                    alu_op_sel_o = `kSAIL_ALUCTL_6to0_ILLEGAL;
                `kRV32I_OPCODE_BRANCH: begin
                    alu_op_sel_o = `kSAIL_ALUCTL_6to0_BRANCH;
                    case (funct3_i)
                        `kRV32I_FUNCCODE_2to0_BEQ:
                            alu_branch_sel_o = `kSAIL_ALUCTL_6to0_BEQ;
                        `kRV32I_FUNCCODE_2to0_BNE:
                            alu_branch_sel_o = `kSAIL_ALUCTL_6to0_BNE;
                        `kRV32I_FUNCCODE_2to0_BLT:
                            alu_branch_sel_o = `kSAIL_ALUCTL_6to0_BLT;
                        `kRV32I_FUNCCODE_2to0_BGE:
                            alu_branch_sel_o = `kSAIL_ALUCTL_6to0_BGE;
                        `kRV32I_FUNCCODE_2to0_BLTU:
                            alu_branch_sel_o = `kSAIL_ALUCTL_6to0_BLTU;
                        `kRV32I_FUNCCODE_2to0_BGEU:
                            alu_branch_sel_o = `kSAIL_ALUCTL_6to0_BGEU;
                        default begin
                            alu_branch_sel_o = 3'b000;
                            alu_op_sel_o = `kSAIL_ALUCTL_6to0_ILLEGAL;
                        end
                    endcase
                end
                `kRV32I_OPCODE_LOAD:
                    case (funct3_i)
                        `kRV32I_FUNCCODE_2to0_LB:
                            alu_op_sel_o = `kSAIL_ALUCTL_6to0_ADD;
                        `kRV32I_FUNCCODE_2to0_LH:
                            alu_op_sel_o = `kSAIL_ALUCTL_6to0_ADD;
                        `kRV32I_FUNCCODE_2to0_LW:
                            alu_op_sel_o = `kSAIL_ALUCTL_6to0_ADD;
                        `kRV32I_FUNCCODE_2to0_LBU:
                            alu_op_sel_o = `kSAIL_ALUCTL_6to0_ADD;
                        `kRV32I_FUNCCODE_2to0_LHU:
                            alu_op_sel_o = `kSAIL_ALUCTL_6to0_ADD;
                        default:
                            alu_op_sel_o = `kSAIL_ALUCTL_6to0_ILLEGAL;
                    endcase

                `kRV32I_OPCODE_STORE:
                    case (funct3_i)
                        `kRV32I_FUNCCODE_2to0_SB:
                            alu_op_sel_o = `kSAIL_ALUCTL_6to0_ADD;
                        `kRV32I_FUNCCODE_2to0_SH:
                            alu_op_sel_o = `kSAIL_ALUCTL_6to0_ADD;
                        `kRV32I_FUNCCODE_2to0_SW:
                            alu_op_sel_o = `kSAIL_ALUCTL_6to0_ADD;
                        default:
                            alu_op_sel_o = `kSAIL_ALUCTL_6to0_ILLEGAL;
                    endcase

                `kRV32I_OPCODE_IMMOP:
                    case (funct3_i)
                        `kRV32I_FUNCCODE_2to0_ADDI:
                            alu_op_sel_o = `kSAIL_ALUCTL_6to0_ADD;
                        `kRV32I_FUNCCODE_2to0_SLTI:
                            alu_op_sel_o = `kSAIL_ALUCTL_6to0_SLT;
                        `kRV32I_FUNCCODE_2to0_SLTIU:
                            alu_op_sel_o = `kSAIL_ALUCTL_6to0_SLT;
                        `kRV32I_FUNCCODE_2to0_XORI:
                            alu_op_sel_o = `kSAIL_ALUCTL_6to0_XOR;
                        `kRV32I_FUNCCODE_2to0_ORI:
                            alu_op_sel_o = `kSAIL_ALUCTL_6to0_OR;
                        `kRV32I_FUNCCODE_2to0_ANDI:
                            alu_op_sel_o = `kSAIL_ALUCTL_6to0_AND;
                        `kRV32I_FUNCCODE_2to0_SLLI:
                            alu_op_sel_o = `kSAIL_ALUCTL_6to0_SLL;
                        3'b101:
                            case (funct7_bit5_i)
                                1'b0:
                                    alu_op_sel_o = `kSAIL_ALUCTL_6to0_SRL;
                                1'b1:
                                    alu_op_sel_o = `kSAIL_ALUCTL_6to0_SRA;
                                default:
                                    alu_op_sel_o = `kSAIL_ALUCTL_6to0_ILLEGAL;
                            endcase
                        default:
                            alu_op_sel_o = `kSAIL_ALUCTL_6to0_ILLEGAL;
                    endcase

                `kRV32I_OPCODE_ALUOP:
                    case (funct3_i)
                        3'b000:
                            case(funct7_bit5_i)
                                1'b0:
                                    alu_op_sel_o = `kSAIL_ALUCTL_6to0_ADD;
                                1'b1:
                                    alu_op_sel_o = `kSAIL_ALUCTL_6to0_SUB;
                                default:
                                    alu_op_sel_o = `kSAIL_ALUCTL_6to0_ILLEGAL;
                            endcase
                        `kRV32I_FUNCCODE_2to0_SLL:
                            alu_op_sel_o = `kSAIL_ALUCTL_6to0_SLL;
                        `kRV32I_FUNCCODE_2to0_SLT:
                            alu_op_sel_o = `kSAIL_ALUCTL_6to0_SLT;
                        `kRV32I_FUNCCODE_2to0_SLTU:
                            alu_op_sel_o = `kSAIL_ALUCTL_6to0_SLT;
                        `kRV32I_FUNCCODE_2to0_XOR:
                            alu_op_sel_o = `kSAIL_ALUCTL_6to0_XOR;
                        3'b101:
                            case(funct7_bit5_i)
                                1'b0:
                                    alu_op_sel_o = `kSAIL_ALUCTL_6to0_SRL;
                                1'b1:
                                    alu_op_sel_o = `kSAIL_ALUCTL_6to0_SRA; //SRA untested
                                default:
                                    alu_op_sel_o = `kSAIL_ALUCTL_6to0_ILLEGAL;
                            endcase
                        `kRV32I_FUNCCODE_2to0_OR:
                            alu_op_sel_o = `kSAIL_ALUCTL_6to0_OR;
                        `kRV32I_FUNCCODE_2to0_AND:
                            alu_op_sel_o = `kSAIL_ALUCTL_6to0_AND;
                        default:
                            alu_op_sel_o = `kSAIL_ALUCTL_6to0_ILLEGAL;
                    endcase

                default:
                    alu_op_sel_o = `kSAIL_ALUCTL_6to0_ILLEGAL;
            endcase
        end
    end
endmodule
