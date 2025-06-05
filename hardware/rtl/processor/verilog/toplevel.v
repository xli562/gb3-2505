`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"


/*
 *	Top level entity, linking cpu with data and instruction memory.
 */


module toplevel (led_o);
	output [7:0]	led_o;

	wire		clk_proc;
	wire		data_clk_stall;
	

	`ifdef SIMULATION
		reg clk_i;
	`else
		wire		clk_i;
		reg		ENCLKHF		= 1'b1;	// Plock enable
		reg		CLKHF_POWERUP	= 1'b1;	// Power up the HFOSC circuit
		wire	local_clk;


		/*
		*	Use the iCE40's hard primitive for the clock source.
		*/
		// 0b00 = 48 MHz, 0b01 = 24 MHz, 0b10 = 12MHz, 0b11 = 6MHz 
		SB_HFOSC #(
			.CLKHF_DIV("0b11")
		) OSCInst0 (
			.CLKHFEN(ENCLKHF),
			.CLKHFPU(CLKHF_POWERUP),
			.CLKHF(local_clk)
		);
		SB_PLL40_CORE #(
			.FEEDBACK_PATH("SIMPLE"),
			.PLLOUT_SELECT("GENCLK"),
			.DIVR(4'b1111),
			.DIVF(7'b0000000),
			.DIVQ(3'b111),
			.FILTER_RANGE(3'b100),
		) SB_PLL40_CORE_inst (
			.RESETB(1'b1),
			.BYPASS(1'b0),
			.PLLOUTCORE(clk_i),
			.REFERENCECLK(local_clk)
		);
	`endif

	

	/*
	Use a PLL to synthesise the clock signal
	*/

	/*
	 *	Memory interface
	 */
	wire[31:0]	inst_in;
	wire[31:0]	inst_out;
	wire[31:0]	data_out;
	wire[31:0]	data_addr;
	wire[31:0]	data_WrData;
	wire		data_memwrite;
	wire		data_memread;
	wire[2:0]	data_sign_mask;

	wire [7:0] led;
	cpu processor(
		.clk(clk_proc),
		.inst_mem_in(inst_in),
		.inst_mem_out(inst_out),
		.data_mem_out(data_out),
		.data_mem_addr(data_addr),
		.data_mem_WrData(data_WrData),
		.data_mem_memwrite(data_memwrite),
		.data_mem_memread(data_memread),
		.data_mem_sign_mask(data_sign_mask),
		.led_i(led),
		.led_o(led_o)
	);

	instruction_memory inst_mem( 
		.addr(inst_in), 
		.out(inst_out)
	);

	data_mem data_mem_inst(
			.clk(clk_i),
			.addr(data_addr),
			.write_data(data_WrData),
			.memwrite(data_memwrite), 
			.memread(data_memread), 
			.read_data(data_out),
			.sign_mask(data_sign_mask),
			.led(led),
			.clk_stall(data_clk_stall)
		);

	assign clk_proc = (data_clk_stall) ? 1'b1 : clk_i;
endmodule
