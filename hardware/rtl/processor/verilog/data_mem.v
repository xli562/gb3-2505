`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

module data_mem (
    input  wire        clk_i,
    input  wire [31:0] addr_i,
    input  wire [31:0] w_data_i,
    input  wire        w_ena_i,
    input  wire        r_ena_i,
    input  wire [ 2:0] sign_mask_i,
    output reg  [31:0] r_data_o,
    output wire [ 7:0] led_o,
    output reg         clk_stall_o  //Sets CPU's clock high
);
    // State
    integer state = 0;
    parameter IDLE = 0;
    parameter READ_BUFFER = 1;
    parameter READ = 2;
    parameter WRITE = 3;

    reg  [31:0] word_buf;  // Line buffer
    wire [31:0] read_buf;  // Read buffer
    reg  [31:0] led_s;
    reg         r_ena_buf;
    reg         w_ena_buf;
    reg  [31:0] w_data_buf;
    reg  [31:0] addr_buf;
    reg  [ 2:0] sign_mask_buf;
    reg  [31:0] data_block [0:1023];
    wire [ 9:0] addr_buf_block_addr_s;
    wire [31:0] replacement_word_s;
    assign addr_buf_block_addr_s  = addr_buf[11:2];
    assign led_o = led_s;

    initial begin
        `ifdef SYNTHESIS
        $readmemh("processor/verilog/data.hex", data_block);
        `elsif SIMULATION
        $readmemh("verilog/data.hex", data_block);
        `else
        $error("You must define SYNTHESIS or SIMULATION");
        `endif
        clk_stall_o = 0;
    end

    always @(posedge clk_i) begin
        if (w_ena_i == 1'b1 && {addr_i[31], addr_i[13]} == 2'b01) begin
            led_s <= w_data_i;
        end
    end

    // State machine
    always @(posedge clk_i) begin
        case (state)
            IDLE: begin
                clk_stall_o   <= 1'b0;
                r_ena_buf     <= r_ena_i;
                w_ena_buf     <= w_ena_i;
                w_data_buf    <= w_data_i;
                addr_buf      <= addr_i;
                sign_mask_buf <= sign_mask_i;

                if (w_ena_i | r_ena_i) begin
                    state <= READ_BUFFER;
                    clk_stall_o <= 1'b1;
                end
            end

            READ_BUFFER: begin
                // Subtract out the size of the instruction memory.
                word_buf <= data_block[addr_buf_block_addr_s - 1024];

                if(r_ena_buf==1'b1) begin
                    state <= READ;
                end
                else if(w_ena_buf == 1'b1) begin
                    state <= WRITE;
                end
            end

            READ: begin
                clk_stall_o <= 0;
                r_data_o <= read_buf;
                state <= IDLE;
            end

            WRITE: begin
                clk_stall_o <= 0;

                // Subtract out the size of the instruction memory.
                data_block[addr_buf_block_addr_s - 1024] <= replacement_word_s;
                state <= IDLE;
            end
        endcase
    end

    store_data_gen store_data_gen_inst (
        .original_word_i(word_buf),
        .w_data_i(w_data_buf),
        .sign_mask_i(sign_mask_buf),
        .byte_offset_i(addr_buf[1:0]),
        .new_word_o(replacement_word_s)
    );

    load_data_gen load_data_gen_inst (
        .word_i(word_buf),
        .sign_mask_i(sign_mask_buf),
        .byte_offset_i(addr_buf[1:0]),
        .word_o(read_buf)
    );
endmodule
