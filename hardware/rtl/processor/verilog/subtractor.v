`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

module adder (
    input [31:0] input1,
    input [31:0] input2,
    output [31:0] out
);
	wire CO_internal;

    SB_MAC16 i_sbmac16 (
        .A(input1[31:16]),
        .B(input1[15:0]),
        .C(input2[31:16]),	
        .D(input2[15:0]),
        .O(out),
        .CLK(1'b0),
		.CE(1'b0),
		.IRSTTOP(1'b0),
		.IRSTBOT(1'b0),
		.ORSTTOP(1'b0),
		.ORSTBOT(1'b0),
		.AHOLD(1'b0),
		.BHOLD(1'b0),
		.CHOLD(1'b0),
		.DHOLD(1'b0),
		.OHOLDTOP(1'b0),
		.OHOLDBOT(1'b0),
		.OLOADTOP(1'b0),
		.OLOADBOT(1'b0),
		.ADDSUBTOP(0'b1),
		.ADDSUBBOT(0'b1),
		.CO(),
		.CI(1'b0),
		.ACCUMCI(),
		.ACCUMCO(),
		.SIGNEXTIN(),
		.SIGNEXTOUT()
    );

    defparam i_sbmac16.TOPADDSUB_UPPERINPUT = 1'b1;
    defparam i_sbmac16.TOPADDSUB_CARRYSELECT = 2'b10;
    defparam i_sbmac16.BOTADDSUB_UPPERINPUT = 1'b1;
    defparam i_sbmac16.MODE_8x8 = 1'b1;

endmodule