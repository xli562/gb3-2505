`default_nettype none
`timescale 1ns / 1ps

module morse_input_lut #(
    parameter A = 3'b000,
    parameter B = 3'b001,
    parameter C = 3'b010,
    parameter D = 3'b011,
    parameter E = 3'b100,
    parameter F = 3'b101,
    parameter G = 3'b110,
    parameter H = 3'b111
) (
    input  wire [2:0] parallel_i,
    output reg  [4:0] code_o,
    output reg  [2:0] len_o
);
    // Characters
    always @* begin
        case (parallel_i)
            A: begin
                code_o = 5'b00010;
                len_o  = 2-1;
            end
            B: begin
                code_o = 5'b00001;
                len_o  = 4-1;
            end
            C: begin
                code_o = 5'b00101;
                len_o  = 4-1;
            end
            D: begin
                code_o = 5'b00001;
                len_o  = 3-1;
            end
            E: begin
                code_o = 5'b00000;
                len_o  = 1-1;
            end
            F: begin
                code_o = 5'b00100;
                len_o  = 4-1;
            end
            G: begin
                code_o = 5'b00011;
                len_o  = 3-1;
            end
            H: begin
                code_o = 5'b00000;
                len_o  = 4-1;
            end
            default:;
        endcase
    end

endmodule
