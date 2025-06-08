`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

/*
 *	RISC-V IMMEDIATE GENERATOR
 */

module imm_gen(inst, imm);

	input [28:0]		inst;
	output reg [31:0]	imm;

	initial begin
		imm = 32'b0;
	end

	always @(inst) begin
		case ({inst[3:0]})
			4'b0000: //I-type
				imm = { {21{inst[28]}}, inst[27:17] };
			4'b1101: //I-type JALR
				imm = { {21{inst[28]}}, inst[27:18], 1'b0 };
			4'b0100: //S-type
				imm = { {21{inst[28]}}, inst[27:22], inst[8:4] };
			4'b0101: //U-type
				imm = { inst[28:9], 12'b0 };
			4'b0001: //U-type
				imm = { inst[28:9], 12'b0 };
			4'b1111: //UJ-type
				imm = { {12{inst[28]}}, inst[16:9], inst[17], inst[27:18], 1'b0 };
			4'b1100: //SB-type
				imm = { {20{inst[28]}}, inst[4], inst[27:22], inst[8:5], 1'b0 };
			default : imm = { {21{inst[28]}}, inst[27:17] };
		endcase
	end
endmodule
