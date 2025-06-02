`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"



//Data cache

module data_mem (clk, addr, write_data, memwrite, memread, sign_mask, read_data, led, clk_stall);
    input               clk;
    input       [31:0]  addr;
    input       [31:0]  write_data;
    input               memwrite;
    input               memread;
    input       [3:0]   sign_mask;
    output reg  [31:0]  read_data;
    output      [7:0]   led;
    output reg          clk_stall;  //Sets the clock high

    // led register
    reg [31:0]          led_reg;

    //Current state
    integer state = 0;

    // Possible states
    parameter           IDLE = 0;
    parameter           READ_BUFFER = 1;
    parameter           READ = 2;
    parameter           WRITE = 3;

    // Line buffer
    reg [31:0]        word_buf;

    // Read buffer
    wire [31:0]        read_buf;

    // Buffer to identify read or write operation
    reg            memread_buf;
    reg            memwrite_buf;

    // Buffers to store write data
    reg [31:0]        write_data_buffer;

    // Buffer to store address
    reg [31:0]        addr_buf;

    // Sign_mask buffer
    reg [3:0]        sign_mask_buf;

    // Block memory registers
    // (Bad practice: The constant for the size should be a `define).
    reg [31:0]        data_block[0:`kDATA_MEM_SIZE-1];

    // wire assignments
    wire [9:0]        addr_buf_block_addr;
    wire [1:0]        addr_buf_byte_offset;

    wire [31:0]        replacement_word;

    assign            addr_buf_block_addr    = addr_buf[11:2];
    assign            addr_buf_byte_offset    = addr_buf[1:0];

    // Regs for multiplexer output
    wire [7:0]        buf0;
    wire [7:0]        buf1;
    wire [7:0]        buf2;
    wire [7:0]        buf3;

    assign             buf0    = word_buf[7:0];
    assign             buf1    = word_buf[15:8];
    assign             buf2    = word_buf[23:16];
    assign             buf3    = word_buf[31:24];

    // Byte select decoder
    wire bdec_sig0;
    wire bdec_sig1;
    wire bdec_sig2;
    wire bdec_sig3;

    assign bdec_sig0 = (~addr_buf_byte_offset[1]) & (~addr_buf_byte_offset[0]);
    assign bdec_sig1 = (~addr_buf_byte_offset[1]) & (addr_buf_byte_offset[0]);
    assign bdec_sig2 = (addr_buf_byte_offset[1]) & (~addr_buf_byte_offset[0]);
    assign bdec_sig3 = (addr_buf_byte_offset[1]) & (addr_buf_byte_offset[0]);


    // Constructing the word to be replaced for write byte
    wire[7:0] byte_r0;
    wire[7:0] byte_r1;
    wire[7:0] byte_r2;
    wire[7:0] byte_r3;

    assign byte_r0 = (bdec_sig0==1'b1) ? write_data_buffer[7:0] : buf0;
    assign byte_r1 = (bdec_sig1==1'b1) ? write_data_buffer[7:0] : buf1;
    assign byte_r2 = (bdec_sig2==1'b1) ? write_data_buffer[7:0] : buf2;
    assign byte_r3 = (bdec_sig3==1'b1) ? write_data_buffer[7:0] : buf3;

    // For write halfword
    wire[15:0] halfword_r0;
    wire[15:0] halfword_r1;

    assign halfword_r0 = (addr_buf_byte_offset[1]==1'b1) ? {buf1, buf0} : write_data_buffer[15:0];
    assign halfword_r1 = (addr_buf_byte_offset[1]==1'b1) ? write_data_buffer[15:0] : {buf3, buf2};

    // a is sign_mask_buf[2], b is sign_mask_buf[1], c is sign_mask_buf[0]
    wire write_select0;
    wire write_select1;

    wire[31:0] write_out1;
    wire[31:0] write_out2;

    assign write_select0 = ~sign_mask_buf[2] & sign_mask_buf[1];
    assign write_select1 = sign_mask_buf[2];

    assign write_out1 = (write_select0) ? {halfword_r1, halfword_r0} : {byte_r3, byte_r2, byte_r1, byte_r0};
    assign write_out2 = (write_select0) ? 32'b0 : write_data_buffer;

    assign replacement_word = (write_select1) ? write_out2 : write_out1;
    // Combinational logic for generating 32-bit read data

    wire select0;
    wire select1;
    wire select2;

    wire[31:0] out1;
    wire[31:0] out2;
    wire[31:0] out3;
    wire[31:0] out4;
    wire[31:0] out5;
    wire[31:0] out6;
    // a is sign_mask_buf[2], b is sign_mask_buf[1], c is sign_mask_buf[0]
    // d is addr_buf_byte_offset[1], e is addr_buf_byte_offset[0]

    assign select0 = (~sign_mask_buf[2] & ~sign_mask_buf[1] & ~addr_buf_byte_offset[1] & addr_buf_byte_offset[0]) | (~sign_mask_buf[2] & addr_buf_byte_offset[1] & addr_buf_byte_offset[0]) | (~sign_mask_buf[2] & sign_mask_buf[1] & addr_buf_byte_offset[1]); //~a~b~de + ~ade + ~abd
    assign select1 = (~sign_mask_buf[2] & ~sign_mask_buf[1] & addr_buf_byte_offset[1]) | (sign_mask_buf[2] & sign_mask_buf[1]); // ~a~bd + ab
    assign select2 = sign_mask_buf[1]; //b

    assign out1 = (select0) ? ((sign_mask_buf[3]==1'b1) ? {{24{buf1[7]}}, buf1} : {24'b0, buf1}) : ((sign_mask_buf[3]==1'b1) ? {{24{buf0[7]}}, buf0} : {24'b0, buf0});
    assign out2 = (select0) ? ((sign_mask_buf[3]==1'b1) ? {{24{buf3[7]}}, buf3} : {24'b0, buf3}) : ((sign_mask_buf[3]==1'b1) ? {{24{buf2[7]}}, buf2} : {24'b0, buf2});
    assign out3 = (select0) ? ((sign_mask_buf[3]==1'b1) ? {{16{buf3[7]}}, buf3, buf2} : {16'b0, buf3, buf2}) : ((sign_mask_buf[3]==1'b1) ? {{16{buf1[7]}}, buf1, buf0} : {16'b0, buf1, buf0});
    assign out4 = (select0) ? 32'b0 : {buf3, buf2, buf1, buf0};

    assign out5 = (select1) ? out2 : out1;
    assign out6 = (select1) ? out4 : out3;

    assign read_buf = (select2) ? out6 : out5;

	// Load hex file, raise error if file not found.
    // integer fh;
    initial begin
        // // try to open it for reading
        // fh = $fopen("verilog/data.hex", "r");
        // if (fh == 0) begin
        //     // couldn’t find it: dump an error + cwd, then exit
        //     $display("%m: ERROR: could not open data.hex at \"verilog/data.hex\"");
        //     $display(">>> Simulation working directory:");
        //     // this invokes the shell command `pwd`
        //     // (Verilator supports $system)
        //     $system("pwd");
        //     $finish(1);
        // end else begin
        //     // file exists: close the probe handle and actually load it
        //     $fclose(fh);
        `ifdef SYNTHESIS
		$readmemh("processor/verilog/data.hex", data_block);
		`elsif SIMULATION
		$readmemh("verilog/data.hex", data_block);
		`else
		$error("You must define SYNTHESIS or SIMULATION");
		`endif
        // end
        clk_stall = 0;
    end

    // LED register interfacing with I/O
    always @(posedge clk) begin
		if(memwrite == 1'b1 && addr == 32'h2000) begin
			led_reg <= write_data;
		end
	end

    

    // State machine
    always @(posedge clk) begin
        case (state)
            IDLE: begin
                clk_stall <= 0;
                memread_buf <= memread;
                memwrite_buf <= memwrite;
                write_data_buffer <= write_data;
                addr_buf <= addr;
                sign_mask_buf <= sign_mask;

                if(memwrite==1'b1 || memread==1'b1) begin
                    state <= READ_BUFFER;
                    clk_stall <= 1;
                end
            end

            READ_BUFFER: begin
                // Subtract out the size of the instruction memory.
                `ifdef SIMULATION
					// In simulation: testbench provides normalized address, so no offset needed
					word_buf <= data_block[addr_buf_block_addr];
				`else
					// In synthesis: address is physical, so subtract base address offset
					word_buf <= data_block[addr_buf_block_addr - `kINST_MEM_SIZE];
				`endif

                if(memread_buf==1'b1) begin
                    state <= READ;
                end
                else if(memwrite_buf == 1'b1) begin
                    state <= WRITE;
                end
            end

            READ: begin
                clk_stall <= 0;
                read_data <= read_buf;
                state <= IDLE;
            end

            WRITE: begin
                clk_stall <= 0;

                // Subtract out the size of the instruction memory.
                `ifdef SIMULATION
					data_block[addr_buf_block_addr] <= replacement_word;
				`else
					data_block[addr_buf_block_addr - `kINST_MEM_SIZE] <= replacement_word;
				`endif
                state <= IDLE;
            end

        endcase
    end

    // Test LEDs on the MDP board
    // led[0] is green led
    // led[7] is pin 15 of J33
    // led[1] is cycle counter trigger
    // led[2] is morse encoder's 'send' signal
    assign led = led_reg;
endmodule
