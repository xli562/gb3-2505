`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

module alu(
    input  wire [31:0] a_i,
    input  wire [31:0] b_i,
    input  wire [`kALU_BRANCH_SEL_WIDTH-1:0] branch_sel_i,
    input  wire [`kALU_OP_SEL_WIDTH-1:0] op_sel_i,
    output wire [31:0] result_o,
    output wire        branch_ena_o
);
    wire signed [31:0] signed_a_s = a_i;
    wire signed [31:0] signed_b_s = b_i;

    wire [4:0] sh = b_i[4:0];
    localparam [31:0] ALL_ONES = ~32'b0;
    wire [31:0] sign_mask = {32{a_i[31]}} & ~(ALL_ONES >> sh);

    wire [31:0] add_s = op_sel_i[0] ? a_i + b_i : 32'b0;
    wire [31:0] sub_s = op_sel_i[1] ? a_i - b_i : 32'b0; 
    wire [31:0] and_s = op_sel_i[2] ? a_i & b_i : 32'b0;
    wire [31:0] or_s  = op_sel_i[3] ? a_i | b_i : 32'b0;
    wire [31:0] xor_s = op_sel_i[4] ? a_i ^ b_i : 32'b0;
    wire [31:0] sll_s = op_sel_i[5] ? a_i << b_i[4:0] : 32'b0;
    wire [31:0] srl_s = op_sel_i[6] ? a_i >> b_i[4:0] : 32'b0;
    wire [31:0] sra_s = op_sel_i[7]
        ? ((a_i >> sh) | sign_mask)
        : 32'b0;
    wire [31:0] slt_s = op_sel_i[8] ? (signed_a_s < signed_b_s ? 32'b1 : 32'b0) : 32'b0;
    
    assign result_o = add_s | sub_s | and_s | or_s  |
                      xor_s | sll_s | srl_s | sra_s | slt_s;

    wire beq_s  = branch_sel_i[0] ? ( a_i ==  b_i) : 1'b0;
    wire bne_s  = branch_sel_i[1] ? ( a_i !=  b_i) : 1'b0;
    wire blt_s  = branch_sel_i[2] ? (signed_a_s <  signed_b_s) : 1'b0;
    wire bge_s  = branch_sel_i[3] ? (signed_a_s >=  signed_b_s) : 1'b0;
    wire bltu_s = branch_sel_i[4] ? ( a_i <  b_i) : 1'b0;
    wire bgeu_s = branch_sel_i[5] ? ( a_i >=  b_i) : 1'b0;
    assign branch_ena_o = beq_s | bne_s | blt_s | bge_s | bltu_s | bgeu_s;
endmodule



// `default_nettype none
// `timescale 1ns / 1ps
// `include "../include/rv32i-defines.v"

// module alu(
//     input  wire [31:0] a_i,
//     input  wire [31:0] b_i,
//     input  wire [`kALU_BRANCH_SEL_WIDTH-1:0] branch_sel_i,
//     input  wire [`kALU_OP_SEL_WIDTH-1:0] op_sel_i,
//     output reg  [31:0] result_o,
//     output reg         branch_ena_o
// );
//     // Doesn't really need reset? Case statements below default to zero
//     initial begin
//         result_o = 32'b0;
//         branch_ena_o = 1'b0;
//     end

//     always @(op_sel_i, a_i, b_i) begin
//         case (op_sel_i)
//             // ADD (the fields also match AUIPC, all loads, all stores, and ADDI)
//             `kSAIL_ALUCTL_ADD:   result_o = a_i + b_i;
//             // SUBTRACT (the fields also matches all branches)
//             `kSAIL_ALUCTL_SUB:   result_o = a_i - b_i;
//             // AND (the fields also match ANDI and LUI)
//             `kSAIL_ALUCTL_AND:   result_o = a_i & b_i;
//             // OR (the fields also match ORI)
//             `kSAIL_ALUCTL_OR:    result_o = a_i | b_i;
//             // XOR (the fields also match other XOR variants)
//             `kSAIL_ALUCTL_XOR:   result_o = a_i ^ b_i;
//             // SLL (the fields also match the other SLL variants)
//             `kSAIL_ALUCTL_SLL:   result_o = a_i << b_i[4:0];
//             // SRL (the fields also matches the other SRL variants)
//             `kSAIL_ALUCTL_SRL:   result_o = a_i >> b_i[4:0];
//             // SRA (the fields also matches the other SRA variants)
//             `kSAIL_ALUCTL_SRA:   result_o = $signed(a_i) >>> b_i[4:0];
//             // SLT (the fields also matches all the other SLT variants)
//             `kSAIL_ALUCTL_SLT:   result_o = $signed(a_i) < $signed(b_i) ? 32'b1 : 32'b0;
//             default:                                    result_o = '0;
//         endcase
//     end

//     always @(branch_sel_i, result_o, a_i, b_i) begin
//         case (branch_sel_i)
//             `kSAIL_ALUCTL_BEQ:  branch_ena_o = (result_o == 0);
//             `kSAIL_ALUCTL_BNE:  branch_ena_o = !(result_o == 0);
//             `kSAIL_ALUCTL_BLT:  branch_ena_o = ($signed(a_i) < $signed(b_i));
//             `kSAIL_ALUCTL_BGE:  branch_ena_o = ($signed(a_i) >= $signed(b_i));
//             `kSAIL_ALUCTL_BLTU: branch_ena_o = ($unsigned(a_i) < $unsigned(b_i));
//             `kSAIL_ALUCTL_BGEU: branch_ena_o = ($unsigned(a_i) >= $unsigned(b_i));
//             default:                                   branch_ena_o = 1'b0;
//         endcase
//     end
// endmodule
