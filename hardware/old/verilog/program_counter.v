`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"



/*
 *	Description:
 *
 *		This module implements the program counter
 */



module program_counter(inAddr, outAddr, clk);
	input			clk;
	input [31:0]		inAddr;
	output reg[31:0]	outAddr;

	/*
	 *	This uses Yosys's support for nonzero initial values:
	 *
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design.
	 */
	initial begin
		outAddr = 32'b0;
	end

	always @(posedge clk) begin
		outAddr <= inAddr;
	end
endmodule
