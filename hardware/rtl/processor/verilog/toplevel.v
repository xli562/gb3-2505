`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"


// Top level entity, linking cpu with data and instruction memory.
module toplevel (
    output [7:0] led_o
);
    wire        clk_proc_s;
    wire        data_clk_stall;
    wire [31:0] inst_in;
    wire [31:0] inst_out;
    wire [31:0] data_out;
    wire [31:0] data_addr;
    wire [31:0] data_WrData;
    wire        data_memwrite;
    wire        data_memread;
    wire [ 3:0] data_sign_mask;
   wire       debug_s;
    wire [ 7:0] led_s;
   reg        reset_n_s = 1'b0;
   reg  [ 4:0] reset_counter_s = 0;

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

   always @(posedge clk_s) begin
      if (reset_counter_s == 5'b11111)
         reset_n_s <= 1'b1;
      else
         reset_counter_s <= reset_counter_s + 1;
   end

    cpu processor(
        .clk_i(clk_proc_s),
        .reset_n_i(reset_n_s),
        .inst_mem_in(inst_in),
        .inst_mem_out(inst_out),
        .data_mem_out(data_out),
        .data_mem_addr(data_addr),
        .data_mem_WrData(data_WrData),
        .data_mem_memwrite(data_memwrite),
        .data_mem_memread(data_memread),
        .data_mem_sign_mask(data_sign_mask),
        .debug_o(debug_s)
    );

    instruction_memory inst_mem( 
        .addr(inst_in), 
        .out(inst_out)
    );

    data_mem data_mem_inst(
            .clk(clk_s),
            .addr(data_addr),
            .write_data(data_WrData),
            .memwrite(data_memwrite),
            .memread(data_memread),
            .read_data(data_out),
            .sign_mask(data_sign_mask),
            .led(led_s),
            .clk_stall(data_clk_stall)
   );

    assign clk_proc_s = (data_clk_stall) ? 1'b1 : clk_s;
   
   // Debugging LED config
    assign led_o = led_s;
   // assign led_o[0] = debug_s;
endmodule
