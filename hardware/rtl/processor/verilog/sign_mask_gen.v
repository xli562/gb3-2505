`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

/*
 *	mask for loads/stores in data memory
 */
 
module sign_mask_gen(func3, sign_mask);
	input [2:0]	func3;
	output [2:0]	sign_mask;

	wire [1:0]	mask;

	/*
	 *	sign - for LBU and LHU the sign bit is 0, indicating read data should be zero extended, otherwise sign extended
	 *	mask - for determining if the load/store operation is on word, halfword or byte
	 *
	 *	DONE - a Karnaugh map should be able to describe the mask without case, the case is for reading convenience
	*/


	assign mask[1] = func3[1] & ~func3[0];
	assign mask[0] = func3[1] ^ func3[0];


	assign sign_mask = {(~func3[2]), mask};
endmodule
