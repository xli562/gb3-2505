`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

/*
 * Implements branch resolution, located in MEM stage
 */

module branch_decide (
    input  wire Branch,  
    input  wire predicted,  
    input  wire branch_enable,  
    input  wire Jump,  
    output wire mispredict,  
    output wire decision,  
    output wire branch_jump_trigger
);
    assign branch_jump_trigger = ((!predicted) & (Branch & branch_enable)) | Jump;
    assign decision            = (Branch & branch_enable);
    assign mispredict          = (predicted & (!(Branch & branch_enable)));
endmodule
