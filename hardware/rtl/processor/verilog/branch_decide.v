`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

/*
 *	Description:
 *
 *		This module implements the branch resolution, located in MEM stage
 */

module branch_decide (Branch, Predicted, Branch_Enable, Jump, Mispredict, Decision, Branch_Jump_Trigger);
	input	Branch;
	input	Predicted;
	input	Branch_Enable;
	input	Jump;
	output	Mispredict;
	output	Decision;
	output	Branch_Jump_Trigger;

	assign	Branch_Jump_Trigger	= ((!Predicted) & (Branch & Branch_Enable)) | Jump;
	assign	Decision		= (Branch & Branch_Enable);
	assign	Mispredict		= (Predicted & (!(Branch & Branch_Enable)));
endmodule
