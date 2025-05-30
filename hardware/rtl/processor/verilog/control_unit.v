`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

/*
 *	RISC-V CONTROL UNIT, opcode decoder.
 */
module control_unit(
		opcode,
		MemtoReg,
		RegWrite,
		MemWrite,
		MemRead,
		branch,
		ALUSrc,
		jump,
		Jalr,
		Lui,
		Auipc,
		Fence,
		CSRR
	);


	// All RV32I opcode end with 11
	input	[6:0] opcode;
	output	MemtoReg, RegWrite, MemWrite, MemRead, branch, ALUSrc, jump, Jalr, Lui, Auipc, Fence, CSRR;

	assign MemtoReg = (~opcode[5]) & (~opcode[4]) & (~opcode[3]) & (opcode[0]);

	assign RegWrite = ((~(opcode[4] | opcode[5])) | opcode[2] | opcode[4]) & opcode[0];

	// All store instructions (sb, sh, sw) have opcode 0100011
	assign MemWrite = (~opcode[6]) & (opcode[5]) & (~opcode[4]);

	// All load instructions (lb, lh, lw, lbu, lhu) have opcode 0000011
	assign MemRead = (~opcode[5]) & (~opcode[4]) & (~opcode[3]) & (opcode[1]);

	// All branching instructions (beq, bne, blt, bge, bltu, bgeu) have opcode 1100011
	assign branch = (opcode[6]) & (~opcode[4]) & (~opcode[2]);
	assign ALUSrc = ~(opcode[6] | opcode[4]) | (~opcode[5]);

	// jal has opcode 1101111
	assign jump = (opcode[6]) & (opcode[5]) & (~opcode[4]) & (opcode[2]);

	// jalr has opcode 1100111
	assign Jalr = (opcode[6]) & (opcode[5]) & (~opcode[4]) & (~opcode[3]) & (opcode[2]);

	// lui has opcode 0110111
	assign Lui = (~opcode[6]) & (opcode[5]) & (opcode[4]) & (~opcode[3]) & (opcode[2]);

	// auipc has opcode 0010111
	assign Auipc = (~opcode[6]) & (~opcode[5]) & (opcode[4]) & (~opcode[3]) & (opcode[2]);

	// fence and fence.i have opcode 0001111
	assign Fence = (~opcode[5]) & opcode[3] & (opcode[2]);
	assign CSRR = (opcode[6]) & (opcode[4]);
endmodule
