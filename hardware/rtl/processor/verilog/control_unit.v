`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

// Control unit, opcode decoder
module control_unit(
    input  [6:0] opcode,
    output       MemtoReg,
	output       RegWrite,
	output       MemWrite,
	output       MemRead,
	output       branch,
	output       ALUSrc,
	output       jump,
	output       Jalr,
	output       Lui,
	output       Auipc,
	output       Fence
);
    // All RV32I opcode end with 11

	// x000xx1
    assign MemtoReg = (~opcode[5]) & (~opcode[4]) & (~opcode[3]) & (opcode[0]);

	// xx1xxx1 or xxxx1x1 or x00xxx1
    assign RegWrite = ((~(opcode[4] | opcode[5])) | opcode[2] | opcode[4]) & opcode[0];

    // All store instructions (sb, sh, sw) have opcode 0100011
	// 010xxxx
    assign MemWrite = (~opcode[6]) & (opcode[5]) & (~opcode[4]);

    // All load instructions (lb, lh, lw, lbu, lhu) have opcode 0000011
	// x000x1x
    assign MemRead = (~opcode[5]) & (~opcode[4]) & (~opcode[3]) & (opcode[1]);

    // All branching instructions (beq, bne, blt, bge, bltu, bgeu) have opcode 1100011
	// 1x0x0xx
    assign branch = (opcode[6]) & (~opcode[4]) & (~opcode[2]);

	// x0xxxxx or 0x0xxxx
    assign ALUSrc = ~(opcode[6] | opcode[4]) | (~opcode[5]);

    // jal has opcode 1101111
	// 110x1xx
    assign jump = (opcode[6]) & (opcode[5]) & (~opcode[4]) & (opcode[2]);

    // jalr has opcode 1100111
	// 11001xx
    assign Jalr = (opcode[6]) & (opcode[5]) & (~opcode[4]) & (~opcode[3]) & (opcode[2]);

    // lui has opcode 0110111
	// 01101xx
    assign Lui = (~opcode[6]) & (opcode[5]) & (opcode[4]) & (~opcode[3]) & (opcode[2]);

    // auipc has opcode 0010111
	// 00101xx
    assign Auipc = (~opcode[6]) & (~opcode[5]) & (opcode[4]) & (~opcode[3]) & (opcode[2]);

    // fence and fence.i have opcode 0001111
	// x0x11xx
    assign Fence = (~opcode[5]) & opcode[3] & (opcode[2]);
endmodule
