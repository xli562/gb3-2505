// Cycle counter
// Does not depend on state of 'start' once started

`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

module cycle_counter (
    input  wire                             clk_i,
    input  wire                             rstn_i,

    input  wire [`kCYCLE_COUNTER_WIDTH-1:0] cycles_i,
    input  wire                             start_i,
    input  wire                             enable_i,
    output reg  [`kCYCLE_COUNTER_WIDTH-1:0] readout_o
);
    localparam IDLE      = 1'b0,
               COUNTDOWN = 1'b1;
    // State names
    reg state;
    reg next_state;

    // Counter
    reg [`kCYCLE_COUNTER_WIDTH-1:0] counter;

    // Transition logic
    always @* begin : TransitionLogic
        // Default assignments
        next_state = state;
        
        case(state)
            IDLE: begin
                // readout_o = cycles_i;
                if (start_i && (cycles_i > 0))
                    next_state = COUNTDOWN;
            end
            COUNTDOWN: begin
                if (counter == 0) next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Action
    always @(posedge clk_i or negedge rstn_i) begin: Action
        if (!rstn_i) begin
            state       <= IDLE;
            counter     <= '0;
        end else begin
            state <= next_state;

            case (state)
                IDLE: begin
                    if (start_i && (cycles_i > 0)) begin
                        // Capture inputs
                        counter <= cycles_i + 1;
                    end
                end
                COUNTDOWN: begin
                    if ((counter != 0) && enable_i) begin
                        readout_o <= counter;
                        counter <= counter + 1;
                    end
                end
                default: begin
                    // Do nothing
                end
            endcase
        end
    end
endmodule
