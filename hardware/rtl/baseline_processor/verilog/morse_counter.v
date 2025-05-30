/* BCD counter */

`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

module morse_counter #(
    parameter WIDTH    = 8,
    parameter START_AT = 10
) (
    input  wire                 clk_i,
    input  wire                 rstn_i,

    input  wire                 load_i,
    input  wire                 enable_i,

    input  wire  [WIDTH-1:0]    start_time_i,
    output wire                 rollover_o
);
    // Internal signals
    reg [WIDTH-1:0] count_s;

    always @(posedge clk_i or negedge rstn_i) begin
        if (~rstn_i) begin
            count_s <= '0;
        end else begin
            if (load_i == 1) begin
                count_s <= start_time_i;
            end else if (enable_i) begin
                if (count_s == 0) begin
                    count_s <= START_AT-1;
                end else begin
                    count_s <= count_s - 1;
                end
            end
        end
    end

    assign rollover_o = (count_s == '0);

endmodule
