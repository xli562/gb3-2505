`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

// Combinational logic for LB / LH / LW / LBU / LHU

module load_data_gen (
    input  wire [31:0] word_i,
    input  wire [ 2:0] sign_mask_i,
    input  wire [ 1:0] byte_offset_i,
    output wire [31:0] word_o
);  
    wire [7:0] buf0 = word_i[ 7: 0];
    wire [7:0] buf1 = word_i[15: 8];
    wire [7:0] buf2 = word_i[23:16];
    wire [7:0] buf3 = word_i[31:24];
    wire select0 = (~sign_mask_i[1] & ~sign_mask_i[0] & ~byte_offset_i[1] & byte_offset_i[0]) |
                   (~sign_mask_i[1] & byte_offset_i[1] & byte_offset_i[0]) |
                   (~sign_mask_i[1] & sign_mask_i[0] & byte_offset_i[1]);
    wire select1 = (~sign_mask_i[1] & ~sign_mask_i[0] & byte_offset_i[1]) |
                   (sign_mask_i[1] & sign_mask_i[0]);
    wire select2 = sign_mask_i[0];
    wire [31:0] out1 = select0 ? 
                  (sign_mask_i[2] ? {{24{buf1[7]}}, buf1} : {24'b0, buf1}) :
                  (sign_mask_i[2] ? {{24{buf0[7]}}, buf0} : {24'b0, buf0});
    wire [31:0] out2 = select0 ?
                  (sign_mask_i[2] ? {{24{buf3[7]}}, buf3} : {24'b0, buf3}) :
                  (sign_mask_i[2] ? {{24{buf2[7]}}, buf2} : {24'b0, buf2});
    wire [31:0] out3 = select0 ?
                  (sign_mask_i[2] ? {{16{buf3[7]}}, buf3, buf2} : {16'b0, buf3, buf2}) :
                  (sign_mask_i[2] ? {{16{buf1[7]}}, buf1, buf0} : {16'b0, buf1, buf0});
    wire [31:0] out4 = select0 ? 32'b0 : word_i;
    wire [31:0] out5 = select1 ? out2 : out1;   // Load byte
    wire [31:0] out6 = select1 ? out4 : out3;   // Load halfword / word
    assign word_o = select2 ? out6 : out5;
endmodule
