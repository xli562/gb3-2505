`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

/*
 * Not all instructions are fed to the ALU. As a result, the ALUctl
 * field is only unique across the instructions that are actually
 * fed to the ALU.
 */
module alu(
    input  wire [6:0]  ALUctl,
    input  wire [31:0] A,
    input  wire [31:0] B,
    output reg  [31:0] ALUOut,
    output reg         branch_enable
);
    // Doesn't really need reset? Case statements below default to zero
    initial begin
        ALUOut = 32'b0;
        branch_enable = 1'b0;
    end

    always @(ALUctl, A, B) begin
        case (ALUctl[3:0])
            /*
             *    AND (the fields also match ANDI and LUI)
             */
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_AND:   ALUOut = A & B;

            /*
             *    OR (the fields also match ORI)
             */
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR:    ALUOut = A | B;

            /*
             *    ADD (the fields also match AUIPC, all loads, all stores, and ADDI)
             */
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ADD:   ALUOut = A + B;

            /*
             *    SUBTRACT (the fields also matches all branches)
             */
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SUB:   ALUOut = A - B;

            /*
             *    SLT (the fields also matches all the other SLT variants)
             */
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLT:   ALUOut = $signed(A) < $signed(B) ? 32'b1 : 32'b0;

            /*
             *    SRL (the fields also matches the other SRL variants)
             */
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRL:   ALUOut = A >> B[4:0];

            /*
             *    SRA (the fields also matches the other SRA variants)
             */
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRA:   ALUOut = $signed(A) >>> B[4:0];

            /*
             *    SLL (the fields also match the other SLL variants)
             */
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLL:   ALUOut = A << B[4:0];

            /*
             *    XOR (the fields also match other XOR variants)
             */
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_XOR:   ALUOut = A ^ B;

            /*
             *    Should never happen.
             */
            default:                    				ALUOut = '0;
        endcase
    end

    always @(ALUctl, ALUOut, A, B) begin
        case (ALUctl[6:4])
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BEQ:  branch_enable = (ALUOut == 0);
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BNE:  branch_enable = !(ALUOut == 0);
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLT:  branch_enable = ($signed(A) < $signed(B));
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGE:  branch_enable = ($signed(A) >= $signed(B));
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLTU: branch_enable = ($unsigned(A) < $unsigned(B));
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGEU: branch_enable = ($unsigned(A) >= $unsigned(B));
            default:                                   branch_enable = 1'b0;
        endcase
    end
endmodule
