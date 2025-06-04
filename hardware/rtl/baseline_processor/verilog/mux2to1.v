`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"


/*
 *	2 to 1 multiplexer
 */



module mux2to1(input0, input1, select, out);
	input [31:0]	input0, input1;
	input		select;
	output [31:0]	out;

	assign out = (select) ? input1 : input0;
endmodule
