`default_nettype none
`timescale 1ns/1ps
`include "../include/rv32i-defines.v"

// -----------------------------------------------------------------------------
// 4-kB (1024-word) single-port RAM with
//   • 1-cycle synchronous read latency
//   • single-entry store buffer → RAW forwarding (load-after-store)
//   • LED-mapped I/O (same decode as the old design)
// No clk_stall_o : the core never stops.
// -----------------------------------------------------------------------------
module data_mem #(
    parameter DEPTH_WORDS = 1024        // 4 kB
) (
    input  wire        clk_i,
    input  wire [31:0] addr_i,
    input  wire [31:0] w_data_i,
    input  wire        w_ena_i,         // 1 = store
    input  wire        r_ena_i,         // 1 = load
    input  wire [ 2:0] sign_mask_i,     // size / sign bits
    output reg  [31:0] r_data_o,        // valid one cycle after r_ena_i
    output wire [ 7:0] led_o            // debug LEDs
);

    // -------------------------------------------------------------------------
    // 1. on-chip RAM (word-addressable)
    // -------------------------------------------------------------------------
    reg  [31:0] data_block [0:DEPTH_WORDS-1];
    wire [ 9:0] word_addr = addr_i[11:2];          // 4-byte aligned

    // -------------------------------------------------------------------------
    // 2. LED-mapped I/O (same decode as before)
    // -------------------------------------------------------------------------
    reg [31:0] led_q;
    assign led_o = led_q;

    // -------------------------------------------------------------------------
    // 3. store-buffer  (single entry → forwards immediately, commits next clk)
    // -------------------------------------------------------------------------
    reg        sb_full;
    reg [9:0]  sb_addr;
    reg [31:0] sb_word;                // fully masked word to be written

    // -------------------------------------------------------------------------
    // 4. helper wires  (mask / sign extension identical to old modules)
    // -------------------------------------------------------------------------
    wire [31:0] current_word   = data_block[word_addr];
    wire [31:0] store_new_word;
    reg [31:0] load_word_raw;
    wire [31:0] load_word_masked;
    reg [31:0] r_data_s;

    initial begin
        `ifdef SYNTHESIS
            $readmemh("processor/verilog/data.hex", data_block);
        `elsif SIMULATION
            $readmemh("verilog/data.hex", data_block);
        `else
            $error("Define SYNTHESIS or SIMULATION");
        `endif
    end

    // old generator blocks reused
    store_data_gen store_data_gen_i (
        .original_word_i (current_word),
        .w_data_i        (w_data_i),
        .sign_mask_i     (sign_mask_i),
        .byte_offset_i   (addr_i[1:0]),
        .new_word_o      (store_new_word)
    );

    load_data_gen  load_data_gen_i  (
        .word_i          (load_word_raw),
        .sign_mask_i     (sign_mask_i),
        .byte_offset_i   (addr_i[1:0]),
        .word_o          (load_word_masked)
    );

    // -------------------------------------------------------------------------
    // 5. sequential logic
    // -------------------------------------------------------------------------
    always @(posedge clk_i) begin
        // -----------------------------------------------------
        // commit previously-buffered store
        // -----------------------------------------------------
        if (sb_full) begin
            data_block[sb_addr] <= sb_word;
            sb_full      <= 1'b0;
        end
        
        if (w_ena_i) begin
            // capture into buffer (write happens on next clk edge)
            sb_full <= 1'b1;
            sb_addr <= word_addr;
            sb_word <= store_new_word;
        end
        r_data_o <= load_word_masked;
        if (w_ena_i == 1'b1 && {addr_i[31], addr_i[13]} == 2'b01) begin
            led_q <= w_data_i;
        end
    end

    always @(negedge clk_i) begin
        if (r_ena_i) begin
            // Resolve RAW hazard: If there is a buffered store hit, forward it
            if (sb_full && (sb_addr == word_addr))
                load_word_raw <= sb_word;
            else
                load_word_raw <= current_word;
        end
    end
endmodule
