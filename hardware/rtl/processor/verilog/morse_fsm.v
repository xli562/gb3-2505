`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"


module morse_fsm #(
    parameter SPACE_TIME    = 1,
    parameter DOT_TIME      = 2,
    parameter DASH_TIME     = 15,

    parameter CODE_DOT      = 1'b0,
    parameter CODE_DASH     = 1'b1
) (
    input  wire         clk_i,
    input  wire         rstn_i,
    
    input  wire [`kCYCLE_COUNTER_WIDTH-1:0]  code_i,
    input  wire [5:0]  len_i,
    input  wire        send_i,
    output reg        serial_o,

    output reg [7:0]  set_time_o,
    output reg        timer_load_o,
    input  wire        timer_empty_i
);
    // State names
    localparam [2:0] IDLE    = 3'b000,
                     SPACE   = 3'b001,
                     DOT     = 3'b010,
                     DASH    = 3'b011,
                     FINISH  = 3'b100;
    reg [2:0] state, next_state;


    // Internal signals
    reg [5:0] ptr;
    reg       serial;
    reg [`kCYCLE_COUNTER_WIDTH-1:0] code_reg;
    reg [5:0] len_reg;
    wire sel_slice;
    assign sel_slice = code_reg[ptr];
    // Timer empty posedge detector
    reg prev_rollover;
    wire timer_empty_posedge;
    assign timer_empty_posedge = (prev_rollover != timer_empty_i) && (timer_empty_i == 1);

    always @* begin
        next_state = state;
        serial = 1;
        set_time_o = 0;
        timer_load_o = 0;

        case(state)
            IDLE: begin
                serial = 0;
                if (send_i == 1) begin
                    next_state = SPACE;
                end
            end
            SPACE: begin
                serial = 0;
                if (ptr == len_reg + 1) begin 
                    next_state = FINISH;
                end else if ((timer_empty_posedge)&&(sel_slice == CODE_DOT)) begin
                    next_state = DOT;
                    set_time_o = DOT_TIME;
                    timer_load_o = 1;
                end else if ((timer_empty_posedge)&&(sel_slice == CODE_DASH)) begin
                    next_state = DASH;
                    set_time_o = DASH_TIME;
                    timer_load_o = 1;
                end
            end
            DOT: begin
                serial = 1;
                set_time_o = DOT_TIME;
                if ((timer_empty_posedge)) begin
                    next_state = SPACE;
                    set_time_o = SPACE_TIME;
                    timer_load_o = 1;
                end
            end
            DASH: begin
                serial = 1;
                set_time_o = DASH_TIME;
                if ((timer_empty_posedge)) begin
                    next_state = SPACE;
                    set_time_o = SPACE_TIME;
                    timer_load_o = 1;
                end
            end
            FINISH: begin
                serial = 1'b0;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always @(posedge clk_i or negedge rstn_i) begin
        if (~rstn_i) begin
            state <= IDLE;
            prev_rollover <= 0;
        end else begin
            state <= next_state;
            serial_o <= serial;
            prev_rollover <= timer_empty_i;
        
            case(state)
                IDLE: begin
                    ptr <= 0;
                    if (next_state == SPACE) begin
                        code_reg <= code_i;
                        len_reg  <= len_i;
                    end
                end
                SPACE: begin

                end
                DOT: begin
                    if (next_state == SPACE) begin
                        ptr <= ptr + 1;
                    end
                end
                DASH: begin
                    if (next_state == SPACE) begin
                        ptr <= ptr + 1;
                    end
                end
                default: begin
                    // Do nothing
                end
            endcase
        end
    end
endmodule
