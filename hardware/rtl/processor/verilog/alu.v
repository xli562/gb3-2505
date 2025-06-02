`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

/*
 * Not all instructions are fed to the ALU. As a result, the ALUctl
 * field is only unique across the instructions that are actually
 * fed to the ALU.
 */
module alu(
    input  wire  [9:0] ALUctl,
    input  wire  [6:0] BRUctl,
    input  wire [31:0] A,
    input  wire [31:0] B,
    output reg  [31:0] ALUOut,
    output reg         branch_enable
);  
    // Give signed version of A and B
    wire signed [31:0] sA = A;
    wire signed [31:0] sB = B;
    wire        [31:0] srl = sA >>  B[4:0]; // SRL
    wire signed [31:0] sra = sA >>> B[4:0]; // SRA

    initial begin
        ALUOut = 32'b0;
        branch_enable = 1'b0;
    end

    wire        cmp = (ALUctl[0] & (A < B)) ^ (ALUctl[1] & (sA < sB)); // SLT, SLTU
    wire [31:0] add = ALUctl[3] ? (A - B) : ALUctl[2] ? (A + B) : 0;   // ADD, SUB
    wire [31:0] lgc = ALUctl[4] ? (A ^ B) : ALUctl[5] ? (A | B) : ALUctl[6] ? (A & B) : 0; // Bitwise logic, RCoreP also uses imm here
    wire [31:0] sf1 = ALUctl[7] ? (A << B[4:0]) : 0;
    wire [31:0] sf2 = ALUctl[8] ? srl           : 0;
    wire [31:0] sf3 = ALUctl[9] ? sra           : 0;

    assign ALUOut[0]    = cmp ^ (add[0] ^ lgc[0]) ^ (sf1[0] ^ ((ALUctl[9] | ALUctl[8]) & srl[0]));
    assign ALUOut[31:1] = add[31:1] ^ lgc[31:1] ^ (sf1[31:1] ^ sf2[31:1] ^ sf3[31:1]);

    wire beq  = BRUctl[0] & ( A ==  B);
    wire bne  = BRUctl[1] & ( A !=  B);
    wire blt  = BRUctl[2] & (sA <  sB);
    wire bge  = BRUctl[3] & (sA >  sB);
    wire bltu = BRUctl[4] & ( A <   B);
    wire bgeu = BRUctl[5] & ( A >   B);


    assign branch_enable = beq | bne | blt | bge | bltu | bgeu;
endmodule
