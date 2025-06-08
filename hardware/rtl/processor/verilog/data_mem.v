`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

module data_mem (
    input               clk_i,
    input       [31:0]  addr_i,
    input       [31:0]  w_data_i,
    input               w_ena_i,
    input               r_ena_i,
    input       [ 3:0]  sign_mask_i,
    output reg  [31:0]  r_data_o,
    output      [ 7:0]  led_o,
    output reg          clk_stall_o  //Sets the clock high
);
    
    reg  [31:0] word_buf;  // Line buffer
    wire [31:0] read_buf;  // Read buffer
    reg  [31:0] led_reg;  

    // State
    integer state = 0;
    parameter IDLE = 0;
    parameter READ_BUFFER = 1;
    parameter READ = 2;
    parameter WRITE = 3;

    reg         r_ena_buf;
    reg         w_ena_buf;
    reg  [31:0] w_data_buf;
    reg  [31:0] addr_buf;
    reg  [ 2:0] sign_mask_buf;
    reg  [31:0] data_block[0:1023];
    wire [ 9:0] addr_buf_block_addr_s;
    wire [ 1:0] addr_buf_byte_offset_s;
    wire [31:0] replacement_word_s;
    assign addr_buf_block_addr_s  = addr_buf[11:2];
    assign addr_buf_byte_offset_s = addr_buf[ 1:0];

    // Regs for multiplexer output
    wire [7:0] buf0;
    wire [7:0] buf1;
    wire [7:0] buf2;
    wire [7:0] buf3;
    assign buf0 = word_buf[ 7: 0];
    assign buf1 = word_buf[15: 8];
    assign buf2 = word_buf[23:16];
    assign buf3 = word_buf[31:24];

    // Byte select decoder
    wire bdec_sig0;
    wire bdec_sig1;
    wire bdec_sig2;
    wire bdec_sig3;
    assign bdec_sig0 = (~addr_buf_byte_offset_s[1]) & (~addr_buf_byte_offset_s[0]);
    assign bdec_sig1 = (~addr_buf_byte_offset_s[1]) & ( addr_buf_byte_offset_s[0]);
    assign bdec_sig2 = ( addr_buf_byte_offset_s[1]) & (~addr_buf_byte_offset_s[0]);
    assign bdec_sig3 = ( addr_buf_byte_offset_s[1]) & ( addr_buf_byte_offset_s[0]);

    // Constructing the word to be replaced for write byte
    wire[7:0] byte_r0;
    wire[7:0] byte_r1;
    wire[7:0] byte_r2;
    wire[7:0] byte_r3;
    assign byte_r0 = (bdec_sig0==1'b1) ? w_data_buf[7:0] : buf0;
    assign byte_r1 = (bdec_sig1==1'b1) ? w_data_buf[7:0] : buf1;
    assign byte_r2 = (bdec_sig2==1'b1) ? w_data_buf[7:0] : buf2;
    assign byte_r3 = (bdec_sig3==1'b1) ? w_data_buf[7:0] : buf3;

    // For write halfword
    wire[15:0] halfword_r0;
    wire[15:0] halfword_r1;
    assign halfword_r0 = (addr_buf_byte_offset_s[1]==1'b1) ? {buf1, buf0} : w_data_buf[15:0];
    assign halfword_r1 = (addr_buf_byte_offset_s[1]==1'b1) ? w_data_buf[15:0] : {buf3, buf2};

    // a is sign_mask_buf[1], b is sign_mask_buf[0], c is sign_mask_buf[0]
    wire        write_select0;
    wire        write_select1;
    wire [31:0] write_out1;
    wire [31:0] write_out2;
    assign write_select0 = ~sign_mask_buf[0] & sign_mask_buf[0];
    assign write_select1 =  sign_mask_buf[0];
    assign write_out1 = (write_select0) ? 
                        {halfword_r1, halfword_r0} : 
                        {byte_r3, byte_r2, byte_r1, byte_r0};
    assign write_out2 = (write_select0) ? 32'b0 : w_data_buf;
    assign replacement_word_s = (write_select1) ? write_out2 : write_out1;

    // Combinational logic for generating 32-bit read data
    wire        select0;
    wire        select1;
    wire        select2;
    wire [31:0] out1;
    wire [31:0] out2;
    wire [31:0] out3;
    wire [31:0] out4;
    wire [31:0] out5;
    wire [31:0] out6;
    // a is sign_mask_buf[1], b is sign_mask_buf[0], c is sign_mask_buf[0]
    // d is addr_buf_byte_offset_s[1], e is addr_buf_byte_offset_s[0]
    assign select0 = (~sign_mask_buf[1] & ~sign_mask_buf[0] & ~addr_buf_byte_offset_s[1] & addr_buf_byte_offset_s[0]) | (~sign_mask_buf[1] & addr_buf_byte_offset_s[1] & addr_buf_byte_offset_s[0]) | (~sign_mask_buf[1] & sign_mask_buf[0] & addr_buf_byte_offset_s[1]); //~a~b~de + ~ade + ~abd
    assign select1 = (~sign_mask_buf[1] & ~sign_mask_buf[0] & addr_buf_byte_offset_s[1]) | (sign_mask_buf[1] & sign_mask_buf[0]); // ~a~bd + ab
    assign select2 = sign_mask_buf[0]; //b
    assign out1 = (select0) ? 
                  ((sign_mask_buf[2]==1'b1) ? {{24{buf1[7]}}, buf1} : {24'b0, buf1}) :
                  ((sign_mask_buf[2]==1'b1) ? {{24{buf0[7]}}, buf0} : {24'b0, buf0});
    assign out2 = (select0) ?
                  ((sign_mask_buf[2]==1'b1) ? {{24{buf3[7]}}, buf3} : {24'b0, buf3}) :
                  ((sign_mask_buf[2]==1'b1) ? {{24{buf2[7]}}, buf2} : {24'b0, buf2});
    assign out3 = (select0) ?
                  ((sign_mask_buf[2]==1'b1) ? {{16{buf3[7]}}, buf3, buf2} : {16'b0, buf3, buf2}) :
                  ((sign_mask_buf[2]==1'b1) ? {{16{buf1[7]}}, buf1, buf0} : {16'b0, buf1, buf0});
    assign out4 = (select0) ? 32'b0 : {buf3, buf2, buf1, buf0};
    assign out5 = (select1) ? out2 : out1;
    assign out6 = (select1) ? out4 : out3;
    assign read_buf = (select2) ? out6 : out5;

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
        if(w_ena_i == 1'b1 && addr_i == 32'h2000) begin
            led_reg <= w_data_i;
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

                if(w_ena_i==1'b1 || r_ena_i==1'b1) begin
                    state <= READ_BUFFER;
                    clk_stall_o <= 1;
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

    assign led_o = led_reg;
endmodule
