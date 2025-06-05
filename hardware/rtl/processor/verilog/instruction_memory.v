`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"


module instruction_memory (
    input  [31:0] addr,
    output [31:0] out
);
    reg [31:0]        memory_s[0:`kINST_MEM_SIZE-1];

    /*
     * According to the "iCE40 SPRAM Usage Guide" (TN1314 Version 1.0), page 5:
     *
     *     "SB_SPRAM256KA RAM does not support initialization through device configuration."
     *
     * The only way to have an initializable memory is to use the Block RAM.
     * This uses Yosys's support for nonzero initial values:
     *
     *     https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
     *
     * Rather than using this simulation construct (`initial`),
     * the design should instead use a reset signal going to
     * modules in the design.
     */

    // integer fh;
    initial begin
        `ifdef SYNTHESIS
        $readmemh("processor/verilog/program.hex", memory_s);
        `elsif SIMULATION
        $readmemh("verilog/program.hex", memory_s);
        `else
        $error("You must define SYNTHESIS or SIMULATION");
        `endif
    end

    // multiply addr by 4 (RV32I uses byte addressing, 4 bytes in a word)
    assign out = memory_s[addr >> 2];
endmodule
