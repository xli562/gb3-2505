`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"


module mux2to1 #(
    parameter WIDTH = 32
) (
    input  wire [WIDTH-1:0] input0, 
    input  wire [WIDTH-1:0] input1,
    input  wire             select,
    output wire [WIDTH-1:0] out
);
    assign out = (select) ? input1 : input0;
endmodule
