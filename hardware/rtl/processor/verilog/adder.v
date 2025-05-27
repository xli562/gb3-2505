`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

module adder (
    input  wire [31:0] input1,
    input  wire [31:0] input2,
    output wire [31:0] out
);
    assign out = input1 + input2;
endmodule