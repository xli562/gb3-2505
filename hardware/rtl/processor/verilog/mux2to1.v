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

module mux2to1_five_bit(input0, input1, select, out);
	input [4:0]	input0, input1;
	input		select;
	output [4:0]	out;

	assign out = (select) ? input1 : input0;
endmodule

module mux2to1_nine_bit(input0, input1, select, out);
	input [8:0]	input0, input1;
	input		select;
	output [8:0]	out;

	assign out = (select) ? input1 : input0;
endmodule


module mux2to1_eleven_bit(input0, input1, select, out);
	input [10:0]	input0, input1;
	input		select;
	output [10:0]	out;

	assign out = (select) ? input1 : input0;
endmodule
