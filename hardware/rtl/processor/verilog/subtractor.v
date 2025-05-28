`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

module subtractor (
    input [31:0] input1, input2,
    output [31:0] out
);
	wire CO_internal;

    SB_MAC16 i_sbmac16 (
        .A(input1[31:16]),	// Assign subtractor inputs to 4 16 bit inputs
        .B(input1[15:0]),
        .C(input2[31:16]),	
        .D(input2[15:0]),
        .O(out),
        .CE(1'b1),          // Always enable
        .CI(1'b0),          // No external carry-in
        .CO(CO_internal),    // Capture carry-out from bottom
        .ADDSUBBOT(1'b1),
        .ADDSUBTOP(1'b1)
    );

    defparam i_sbmac16.TOPOUTPUT_SELECT = 2'b01;
    defparam i_sbmac16.TOPADDSUB_UPPERINPUT = 1'b1;
    defparam i_sbmac16.TOPADDSUB_CARRYSELECT = 2'b11;
    defparam i_sbmac16.BOTOUTPUT_SELECT = 2'b01;
    defparam i_sbmac16.BOTADDSUB_UPPERINPUT = 1'b1;
    defparam i_sbmac16.BOTADDSUB_CARRYSELECT = 2'b00;
    
endmodule