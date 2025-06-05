`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

/*
 *	RISC-V instruction memory
 */

module instruction_memory(addr, out);
	input [31:0]		addr;
	output [31:0]		out;

	/*
	 *	Size the instruction memory.
	 *
	 *	(Bad practice: The constant should be a `define).
	 */
	reg [31:0]		instruction_memory[0:2**12-1];

	/*
	 *	According to the "iCE40 SPRAM Usage Guide" (TN1314 Version 1.0), page 5:
	 *
	 *		"SB_SPRAM256KA RAM does not support initialization through device configuration."
	 *
	 *	The only way to have an initializable memory is to use the Block RAM.
	 *	This uses Yosys's support for nonzero initial values:
	 *
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design.
	 */

	// Load hex file, raise error if file not found.
    initial begin
		`ifdef SYNTHESIS
		$readmemh("baseline_processor/verilog/program.hex", instruction_memory);
		`elsif SIMULATION
		$readmemh("verilog/program.hex", instruction_memory);
		`else
		$error("You must define SYNTHESIS or SIMULATION");
		`endif
    end

	// multiply addr by 4 (RV32I uses byte addressing, 4 bytes in word)
	assign out = instruction_memory[addr >> 2];
endmodule
