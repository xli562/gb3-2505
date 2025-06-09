`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

// Combinational logic for SB / SH / SW

module store_data_gen (
    input  wire [31:0] original_word_i,
    input  wire [31:0] w_data_i,
    input  wire [ 2:0] sign_mask_i,
    input  wire [ 1:0] byte_offset_i,
    output wire [31:0] new_word_o
);
    wire [7:0] byte_r0 = (byte_offset_i == 2'b00) ?
                         w_data_i[7:0] : original_word_i[ 7: 0];
    wire [7:0] byte_r1 = (byte_offset_i == 2'b01) ?
                         w_data_i[7:0] : original_word_i[15: 8];
    wire [7:0] byte_r2 = (byte_offset_i == 2'b10) ?
                         w_data_i[7:0] : original_word_i[23:16];
    wire [7:0] byte_r3 = (byte_offset_i == 2'b11) ?
                         w_data_i[7:0] : original_word_i[31:24];
    wire [15:0] halfword_r0 = byte_offset_i[1] ? {original_word_i[15: 8], original_word_i[ 7: 0]} : w_data_i[15:0];
    wire [15:0] halfword_r1 = byte_offset_i[1] ? w_data_i[15:0] : {original_word_i[31:24], original_word_i[23:16]};

    wire [31:0] write_out1 = (sign_mask_i[1:0] == 2'b01) ? 
                             {halfword_r1, halfword_r0} : 
                             {byte_r3, byte_r2, byte_r1, byte_r0};
    wire [31:0] write_out2 = (sign_mask_i[1:0] == 2'b01) ? 
                             32'b0 : w_data_i;
    assign new_word_o = sign_mask_i[1] ? write_out2 : write_out1;
endmodule
