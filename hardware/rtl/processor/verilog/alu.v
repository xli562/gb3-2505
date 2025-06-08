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
    input  wire [ 6:0] sel_i,
    output reg  [31:0] result_o,
    output reg         branch_ena_o
);

	wire[31:0] alu_addition;
	wire[31:0] alu_subtraction;

	adder alu_adder(
			.input1(a_i),
			.input2(b_i),
			.out(alu_addition)
		);

	subtractor alu_subtractor(
			.input1(a_i),
			.input2(b_i),
			.out(alu_subtraction)
		);
    // Doesn't really need reset? Case statements below default to zero
    initial begin
        result_o = 32'b0;
        branch_ena_o = 1'b0;
    end

    always @(sel_i, a_i, b_i) begin
        case (sel_i[3:0])
            // AND (the fields also match ANDI and LUI)
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_AND:   result_o = a_i & b_i;

            // OR (the fields also match ORI)
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR:    result_o = a_i | b_i;

            // ADD (the fields also match AUIPC, all loads, all stores, and ADDI)
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ADD:   result_o = alu_addition;

            // SUBTRACT (the fields also matches all branches)
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SUB:   result_o = alu_subtraction;

            // SLT (the fields also matches all the other SLT variants)
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLT:   result_o = $signed(a_i) < $signed(b_i) ? 32'b1 : 32'b0;

            // SRL (the fields also matches the other SRL variants)
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRL:   result_o = a_i >> b_i[4:0];

            // SRA (the fields also matches the other SRA variants)
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRA:   result_o = $signed(a_i) >>> b_i[4:0];

            // SLL (the fields also match the other SLL variants)
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLL:   result_o = a_i << b_i[4:0];

            // XOR (the fields also match other XOR variants)
            `kSAIL_MICROARCHITECTURE_ALUCTL_3to0_XOR:   result_o = a_i ^ b_i;

            // Should never happen.
            default:                    				result_o = '0;
        endcase
    end

    always @(sel_i, result_o, a_i, b_i) begin
        case (sel_i[6:4])
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BEQ:  branch_ena_o = (result_o == 0);
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BNE:  branch_ena_o = !(result_o == 0);
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLT:  branch_ena_o = ($signed(a_i) < $signed(b_i));
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGE:  branch_ena_o = ($signed(a_i) >= $signed(b_i));
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLTU: branch_ena_o = ($unsigned(a_i) < $unsigned(b_i));
            `kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGEU: branch_ena_o = ($unsigned(a_i) >= $unsigned(b_i));
            default:                                   branch_ena_o = 1'b0;
        endcase
    end
endmodule
