`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

// D-type flip-flops

// Prevent yosys from using BRAMs for this module
(* keep_hierarchy *)
module dff #(
    parameter WIDTH = 32
) (
    input  wire             clk_i,
    input  wire             reset_n_i,
    input  wire [WIDTH-1:0] data_i,
    output reg  [WIDTH-1:0] delayed_data_o
);
    always @(posedge clk_i) begin
        if (~reset_n_i) begin
            delayed_data_o <= 0;
        end else begin
            delayed_data_o <= data_i;
        end
    end
endmodule
