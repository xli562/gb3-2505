`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"


module mux2to1(
    input  wire [31:0] input0, 
    input  wire [31:0] input1,
    input  wire        select,
    output wire [31:0] out
);
    assign out = (select) ? input1 : input0;
endmodule
