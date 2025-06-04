`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"


/*
 *	Description:
 *
 *		This module implements the control and status registers (CSRs).
 */



module csr_file (clk, write, wrAddr_CSR, wrVal_CSR, rdAddr_CSR, rdVal_CSR);
	input clk;
	input write;
	input [11:0] wrAddr_CSR;
	input [31:0] wrVal_CSR;
	input [11:0] rdAddr_CSR;
	output reg[31:0] rdVal_CSR;

	reg [31:0] csr_file [0:2**10-1];

	always @(posedge clk) begin
		if (write) begin
			csr_file[wrAddr_CSR] <= wrVal_CSR;
		end
		rdVal_CSR <= csr_file[rdAddr_CSR];
	end

endmodule
