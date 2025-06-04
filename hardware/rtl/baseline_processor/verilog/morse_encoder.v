`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

module morse_encoder #(
    parameter SPACE_TIME        = 1,
    parameter DOT_TIME          = 1,
    parameter DASH_TIME         = 3,

    // symbols
    parameter CODE_DOT          = 1'b0,
    parameter CODE_DASH         = 1'b1,

    // counter
    parameter TIMER_WIDTH       = 8,
    parameter TIMER_START_AT    = 3,
    parameter CLK_WIDTH         = `kCYCLE_COUNTER_WIDTH,
    // parameter HALF_CLK_FREQ     = 10
    parameter HALF_CLK_FREQ     = 800_000
) (
    input  wire        clk_i,
    input  wire        rstn_i,

    input  wire [`kCYCLE_COUNTER_WIDTH-1:0]  parallel_i,
    input  wire        send_i,

    output reg         serial_o
);

    // internal signals
    wire [`kCYCLE_COUNTER_WIDTH-1:0] code;
    wire [5:0]  len;
    wire [7:0]  set_time;
    wire       half_second;
    wire       timer_load;
    wire       timer_enable;
    wire       timer_empty;

    assign code = parallel_i;
    assign len  = `kCYCLE_COUNTER_WIDTH-1;
    assign timer_enable = half_second | timer_load;

    // instantiations
    morse_fsm #(
        .SPACE_TIME(SPACE_TIME),
        .DOT_TIME(DOT_TIME),
        .DASH_TIME(DASH_TIME),
        .CODE_DOT(CODE_DOT),
        .CODE_DASH(CODE_DASH)
    ) fsm_0 (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .code_i(code),
        .len_i(len),
        .send_i(send_i),
        .serial_o(serial_o),
        .set_time_o(set_time),
        .timer_load_o(timer_load),
        .timer_empty_i(timer_empty)
    );

    // half-second clock
    morse_counter #(
        .WIDTH(CLK_WIDTH),
        .START_AT(HALF_CLK_FREQ)
    ) counter_slow (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .load_i(timer_load),
        .enable_i(1'b1),
        .start_time_i(HALF_CLK_FREQ),
        .rollover_o(half_second)
    );

    // morse timer
    morse_counter #(
        .WIDTH(TIMER_WIDTH),
        .START_AT(TIMER_START_AT)
    ) counter_0 (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .load_i(timer_load),
        .enable_i(timer_enable),
        .start_time_i(set_time),
        .rollover_o(timer_empty)
    );



endmodule
