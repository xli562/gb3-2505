`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

module alu_control (
    input  wire [3:0] FuncCode,
    input  wire [6:0] Opcode,
    output reg  [6:0] ALUCtl
);
    /*
     *    The `initial` statement below uses Yosys's support for nonzero
     *    initial values.
     *    Rather than using this simulation construct (`initial`),
     *    the design should instead use a reset signal going to
     *    modules in the design and to thereby set the values.
     */
    initial begin
        ALUCtl = 7'b0;
    end

    always @(*) begin
        case (Opcode)
            /*
             *    LUI, U-Type
             */
            `kRV32I_INSTRUCTION_OPCODE_LUI:
                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_LUI;

            /*
             *    AUIPC, U-Type
             */
            `kRV32I_INSTRUCTION_OPCODE_AUIPC:
                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_AUIPC;

            /*
             *    JAL, UJ-Type
             */
            `kRV32I_INSTRUCTION_OPCODE_JAL:
                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;

            /*
             *    JALR, I-Type
             */
            `kRV32I_INSTRUCTION_OPCODE_JALR:
                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;

            /*
             *    Branch, SB-Type
             */
            `kRV32I_INSTRUCTION_OPCODE_BRANCH:
                case (FuncCode[2:0])
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_BEQ:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_BEQ; //BEQ conditions
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_BNE:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_BNE; //BNE conditions
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_BLT:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_BLT; //BLT conditions
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_BGE:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_BGE; //BGE conditions
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_BLTU:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_BLTU; //BLTU conditions
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_BGEU:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_BGEU; //BGEU conditions
                    default:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
                endcase

            /*
             *    Loads, I-Type
             */
            `kRV32I_INSTRUCTION_OPCODE_LOAD:
                case (FuncCode[2:0])
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_LB:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_LB; //LB
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_LH:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_LH; //LH
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_LW:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_LW; //LW
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_LBU:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_LBU; //LBU
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_LHU:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_LHU; //LHU
                    default:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
                endcase

            /*
             *    Stores, S-Type
             */
            `kRV32I_INSTRUCTION_OPCODE_STORE:
                case (FuncCode[2:0])
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_SB:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SB; //SB
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_SH:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SH; //SH
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_SW:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SW; //SW
                    default:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
                endcase

            /*
             *    Immediate operations, I-Type
             */
            `kRV32I_INSTRUCTION_OPCODE_IMMOP:
                case (FuncCode[2:0])
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_ADDI:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ADDI; //ADDI
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_SLTI:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SLTI; //SLTI
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_SLTIU:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SLTIU; //SLTIU
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_XORI:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_XORI; //XORI
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_ORI:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ORI; //ORI
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_ANDI:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ANDI; //ANDI
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_SLLI:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SLLI; //SLLI
                    3'b101:
                        case (FuncCode[3])
                            1'b0:
                                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SRLI; //SRLI
                            1'b1:
                                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SRAI; //SRAI
                            default:
                                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
                        endcase
                    default:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
                endcase

            /*
             *    ADD SUB & logic shifts, R-Type
             */
            `kRV32I_INSTRUCTION_OPCODE_ALUOP:
                case (FuncCode[2:0])
                    3'b000:
                        case(FuncCode[3])
                            1'b0:
                                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ADD; //ADD
                            1'b1:
                                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SUB; //SUB
                            default:
                                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
                        endcase
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_SLL:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SLL; //SLL
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_SLT:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SLT; //SLT
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_SLTU:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SLTU; //SLTU
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_XOR:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_XOR; //XOR
                    3'b101:
                        case(FuncCode[3])
                            1'b0:
                                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SRL; //SRL
                            1'b1:
                                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_SRA; //SRA untested
                            default:
                                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
                        endcase
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_OR:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_OR; //OR
                    `kRV32I_INSTRUCTION_FUNCCODE_2to0_AND:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_AND; //AND
                    default:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
                endcase

            `kRV32I_INSTRUCTION_OPCODE_CSRR:
                case (FuncCode[1:0]) //use lower 2 bits of FuncCode to determine operation
                    `kRV32I_INSTRUCTION_FUNCCODE_1to0_CSRRW:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_CSRRW; //CSRRW
                    `kRV32I_INSTRUCTION_FUNCCODE_1to0_CSRRS:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_CSRRS; //CSRRS
                    `kRV32I_INSTRUCTION_FUNCCODE_1to0_CSRRC:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_CSRRC; //CSRRC
                    default:
                        ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
                endcase

            default:
                ALUCtl = `kSAIL_MICROARCHITECTURE_ALUCTL_6to0_ILLEGAL;
        endcase
    end
endmodule
