`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

module sp_ram(data_in, out, addr, wren);
    input reg [31:0]        data_in;
	output [31:0]		out;
	input reg [13:0]		addr;
    input [7:0]          wren;

	wire CHIPSELECT;
	wire STANDBY;
	wire SLEEP;
	wire POWEROFF;

	SB_SPRAM256KA  inst_mem_1(
		.DATAIN(data_in[31:16]),
		.ADDRESS(addr[13:0]),
		.MASKWREN(MASKWREN),
		.WREN(WREN),
		.CHIPSELECT(CHIPSELECT),
		.CLOCK(clk),
		.STANDBY(STANDBY),
		.SLEEP(SLEEP),
		.POWEROFF(POWEROFF),
		.DATAOUT(out[31:16])
	);

	SB_SPRAM256KA  inst_mem_2(
		.DATAIN(data_in[15:0]),
		.ADDRESS(addr[13:0]),
		.MASKWREN(MASKWREN),
		.WREN(WREN),
		.CHIPSELECT(CHIPSELECT),
		.CLOCK(clk),
		.STANDBY(STANDBY),
		.SLEEP(SLEEP),
		.POWEROFF(POWEROFF),
		.DATAOUT(out[15:0])
	);
endmodule