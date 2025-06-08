`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"


// Top level entity, linking cpu with data and instruction memory.
module toplevel (
    output [7:0] led_o
);
    `ifdef SIMULATION
        reg  clk_s;
    `else
        wire clk_s;
        reg  ENCLKHF        = 1'b1;
        reg  CLKHF_POWERUP    = 1'b1;
        // 0b00 = 48 MHz, 0b01 = 24 MHz, 0b10 = 12MHz, 0b11 = 6MHz 
        SB_HFOSC #(
            .CLKHF_DIV("0b11")
        ) OSCInst0 (
            .CLKHFEN(ENCLKHF),
            .CLKHFPU(CLKHF_POWERUP),
            .CLKHF(clk_s)
        );
    `endif
        
    wire        clk_proc_s;
    wire        data_clk_stall;
    reg         reset_n_s = 1'b0;
    reg  [ 4:0] reset_counter_s = 0;
    wire [31:0] inst_addr_s;
    wire [31:0] inst_s;
    wire [31:0] data_out;
    wire [31:0] data_addr_s;
    wire [31:0] w_data_s;
    wire        data_w_ena_s;
    wire        data_r_ena_s;
    wire [ 3:0] data_sign_mask_s;
    wire        debug_s;
    wire [ 7:0] led_s;

    always @(posedge clk_s) begin
        if (reset_counter_s == 5'b11111)
            reset_n_s <= 1'b1;
        else
            reset_counter_s <= reset_counter_s + 1;
    end

    cpu processor(
        .clk_i               (clk_proc_s),
        .reset_n_i           (reset_n_s),
        .inst_mem_addr_o     (inst_addr_s),
        .inst_i              (inst_s),
        .data_mem_data_i     (data_out),
        .data_mem_addr_o     (data_addr_s),
        .data_mem_data_o     (w_data_s),
        .data_mem_w_ena_o    (data_w_ena_s),
        .data_mem_r_ena_o    (data_r_ena_s),
        .data_mem_sign_mask_o(data_sign_mask_s),
        .debug_o             (debug_s)
    );

    instruction_memory inst_mem( 
        .addr(inst_addr_s), 
        .out(inst_s)
    );

    data_mem data_mem_inst(
            .clk_i      (clk_s),
            .addr_i     (data_addr_s),
            .w_data_i   (w_data_s),
            .w_ena_i    (data_w_ena_s),
            .r_ena_i    (data_r_ena_s),
            .r_data_o   (data_out),
            .sign_mask_i(data_sign_mask_s),
            .led_o      (led_s),
            .clk_stall_o(data_clk_stall)
    );

    assign clk_proc_s = (data_clk_stall) ? 1'b1 : clk_s;
    
    // Debugging LED config
    assign led_o = led_s;
    // assign led_o[0] = debug_s;
endmodule
