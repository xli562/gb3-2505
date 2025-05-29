`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

/*
 *  Bimodal (per-PC) 2-bit saturating-counter branch predictor.
 *  - TABLE_BITS: log2 of number of entries in the pattern table
 *  - Each entry is a 2-bit counter: 00/01 bias not-taken, 10/11 bias taken.
 */
module branch_predictor #(
    parameter TABLE_BITS = 1
) (
    input             clk,
    // actual outcome (from MEM stage)
    input             actual_branch_decision,
    // high in ID stage for any branch-decode
    input             branch_decode_sig,
    // high in MEM stage when a branch retires
    input             branch_mem_sig,
    // PC of the branch (from IF/ID) and its immediate
    input  [31:0]     in_addr,
    input  [31:0]     offset,
    // outputs: target address and 1='taken'
    output [31:0]     branch_addr,
    output            prediction
);

    localparam TABLE_SIZE = (1 << TABLE_BITS);

    // pattern-history table of 2-bit saturating counters
    reg [1:0] pattern_table [0:TABLE_SIZE-1];

    // save the index at decode so we know which entry to update later
    reg [TABLE_BITS-1:0] id_reg;

    // derive the table index from low bits of PC (word-aligned)
    wire [TABLE_BITS-1:0] id = in_addr[TABLE_BITS+1:2];

    wire       is_branch_back = offset[31];

    integer i;
    initial begin
        // initialize all counters to 'weakly not taken' (01)
        for (i = 0; i < TABLE_SIZE; i = i + 1)
            pattern_table[i] = 2'b01;
        id_reg = {TABLE_BITS{1'b0}};
    end

    // capture which entry to update whenever we decode a branch
    always @(negedge clk) begin
        if (branch_decode_sig) begin
            id_reg <= id;
        end
    end

    // when the branch actually retires, update that counter
    always @(posedge clk) begin
        if (branch_mem_sig & ~(is_branch_back)) begin
            case (pattern_table[id_reg])
                2'b00: pattern_table[id_reg] <= actual_branch_decision ? 2'b01 : 2'b00;
                2'b01: pattern_table[id_reg] <= actual_branch_decision ? 2'b10 : 2'b00;
                2'b10: pattern_table[id_reg] <= actual_branch_decision ? 2'b11 : 2'b01;
                2'b11: pattern_table[id_reg] <= actual_branch_decision ? 2'b11 : 2'b10;
            endcase
        end
    end

    // compute target and prediction
    assign branch_addr = in_addr + offset;
    // prediction = MSB of the counter, gated by 'this is a branch'
    assign prediction  = (pattern_table[id][1] | is_branch_back) & branch_decode_sig;

endmodule
