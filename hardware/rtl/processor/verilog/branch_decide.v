`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

/*
 * Implements branch resolution, located in MEM stage
 */

module branch_decide (
    input  wire branch,  
    input  wire predicted,  
    input  wire branch_enable,  
    input  wire jump,  
    output wire mispredict,  
    output wire decision,  
    output wire branch_jump_trigger
);
    assign branch_jump_trigger = ((!predicted) & (branch & branch_enable)) | jump;
    assign decision            = (branch & branch_enable);
    assign mispredict          = (predicted & (!(branch & branch_enable)));
endmodule
