`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

/*
 *    mask for loads/stores in data memory
 */

module sign_mask_gen(
    input  wire [2:0] funct3,
    output wire [2:0] sign_mask
);
    reg [1:0] mask;

    /*
     *    sign - for LBU and LHU the sign bit is 0, indicating read data should be zero extended, otherwise sign extended
     *    mask - for determining if the load/store operation is on word, halfword or byte
     *
    */

    // LB : funct3 = 000
    // LBU: funct3 = 100
    // LH : funct3 = 001
    // LHU: funct3 = 101
    // LW : funct3 = 010

    always @(*) begin
        case(funct3[1:0])
            2'b00:   mask = 2'b00;    // LB / LBU
            2'b01:   mask = 2'b01;    // LH / LHU
            2'b10:   mask = 2'b11;    // LW
            default: mask = 2'b00;  // should not happen for loads/stores
        endcase
    end

    assign sign_mask = {(~funct3[2]), mask};
endmodule
