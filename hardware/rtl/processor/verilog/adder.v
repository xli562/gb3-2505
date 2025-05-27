`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

module adder (
    input [31:0] input1, input2, 
    input clk,
    output [31:0] out
);
	wire CO_internal;

    SB_MAC16 i_sbmac16 (
        .A(input1[31:16]),	// Assign adder inputs to 4 16 bit inputs
        .B(input1[15:0]),
        .C(input2[31:16]),	
        .D(input2[15:0]),
        .O(out),	
        .CLK(clk),
        .CE(1'b1),          // Always enable
        .CI(1'b0),          // No external carry-in
        .CO(CO_internal)    // Capture carry-out from bottom
    );

    defparam i_sbmac16.NEG_TRIGGER = 1'b0;
    defparam i_sbmac16.C_REG = 1'b1;
    defparam i_sbmac16.A_REG = 1'b1;
    defparam i_sbmac16.B_REG = 1'b1;
    defparam i_sbmac16.D_REG = 1'b1;
    defparam i_sbmac16.TOP_8x8_MULT_REG = 1'b0;
    defparam i_sbmac16.BOT_8x8_MULT_REG = 1'b0;
    defparam i_sbmac16.PIPELINE_16x16_MULT_REG1 = 1'b0;
    defparam i_sbmac16.PIPELINE_16x16_MULT_REG2 = 1'b0;
    defparam i_sbmac16.TOPOUTPUT_SELECT = 2'b01;
    defparam i_sbmac16.TOPADDSUB_LOWERINPUT = 2'b00;
    defparam i_sbmac16.TOPADDSUB_UPPERINPUT = 1'b1;
    defparam i_sbmac16.TOPADDSUB_CARRYSELECT = 2'b11;
    defparam i_sbmac16.BOTOUTPUT_SELECT = 2'b01;
    defparam i_sbmac16.BOTADDSUB_LOWERINPUT = 2'b00;
    defparam i_sbmac16.BOTADDSUB_UPPERINPUT = 1'b1;
    defparam i_sbmac16.BOTADDSUB_CARRYSELECT = 2'b00;
    defparam i_sbmac16.MODE_8x8 = 1'b0;
    defparam i_sbmac16.A_SIGNED = 1'b0;
    defparam i_sbmac16.B_SIGNED = 1'b0;

endmodule