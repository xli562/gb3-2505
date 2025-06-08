`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

/*
 * Not all instructions are fed to the ALU. As a result, the sel_i
 * field is only unique across the instructions that are actually
 * fed to the ALU.
 */
module alu(
    input  wire [31:0] a_i,
    input  wire [31:0] b_i,
    input  wire [`kALU_BRANCH_SEL_WIDTH-1:0] branch_sel_i,
    input  wire [`kALU_OP_SEL_WIDTH-1:0] op_sel_i,
    output reg  [31:0] result_o,
    output reg         branch_ena_o
);
    // Doesn't really need reset? Case statements below default to zero
    initial begin
        result_o = 32'b0;
        branch_ena_o = 1'b0;
    end

    always @(op_sel_i, a_i, b_i) begin
        case (op_sel_i)
            // ADD (the fields also match AUIPC, all loads, all stores, and ADDI)
            `kSAIL_ALUCTL_ADD:   result_o = a_i + b_i;
            // SUBTRACT (the fields also matches all branches)
            `kSAIL_ALUCTL_SUB:   result_o = a_i - b_i;
            // AND (the fields also match ANDI and LUI)
            `kSAIL_ALUCTL_AND:   result_o = a_i & b_i;
            // OR (the fields also match ORI)
            `kSAIL_ALUCTL_OR:    result_o = a_i | b_i;
            // XOR (the fields also match other XOR variants)
            `kSAIL_ALUCTL_XOR:   result_o = a_i ^ b_i;
            // SLL (the fields also match the other SLL variants)
            `kSAIL_ALUCTL_SLL:   result_o = a_i << b_i[4:0];
            // SRL (the fields also matches the other SRL variants)
            `kSAIL_ALUCTL_SRL:   result_o = a_i >> b_i[4:0];
            // SRA (the fields also matches the other SRA variants)
            `kSAIL_ALUCTL_SRA:   result_o = $signed(a_i) >>> b_i[4:0];
            // SLT (the fields also matches all the other SLT variants)
            `kSAIL_ALUCTL_SLT:   result_o = $signed(a_i) < $signed(b_i) ? 32'b1 : 32'b0;
            default:             result_o = '0;
        endcase
    end

    always @(branch_sel_i, result_o, a_i, b_i) begin
        case (branch_sel_i)
            `kSAIL_ALUCTL_BEQ:  branch_ena_o = (result_o == 0);
            `kSAIL_ALUCTL_BNE:  branch_ena_o = !(result_o == 0);
            `kSAIL_ALUCTL_BLT:  branch_ena_o = ($signed(a_i) < $signed(b_i));
            `kSAIL_ALUCTL_BGE:  branch_ena_o = ($signed(a_i) >= $signed(b_i));
            `kSAIL_ALUCTL_BLTU: branch_ena_o = ($unsigned(a_i) < $unsigned(b_i));
            `kSAIL_ALUCTL_BGEU: branch_ena_o = ($unsigned(a_i) >= $unsigned(b_i));
            default:                                   branch_ena_o = 1'b0;
        endcase
    end
endmodule
