`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"


module regfile(
    input  wire        clk,
    input  wire        write,
    input  wire [ 4:0] wrAddr,
    input  wire [31:0] wrData,
    input  wire [ 4:0] rdAddrA,
    output wire [31:0] rdDataA,
    input  wire [ 4:0] rdAddrB,
    output wire [31:0] rdDataB
);
    // register file, 32 x 32-bit registers
    reg [31:0] regfile [31:1];

    // buffer to store address at each positive clock edge
    reg [ 4:0] rdAddrA_buf;
    reg [ 4:0] rdAddrB_buf;

    // registers for forwarding
    reg [31:0] regDatA;
    reg [31:0] regDatB;
    reg [ 4:0] wrAddr_buf;
    reg [31:0] wrData_buf;
    reg        write_buf;


    always @(posedge clk) begin
        if (write==1'b1 && wrAddr!=5'b0) begin
            regfile[wrAddr] <= wrData;
        end
        wrAddr_buf  <= wrAddr;
        write_buf   <= write;
        wrData_buf  <= wrData;
        rdAddrA_buf <= rdAddrA;
        rdAddrB_buf <= rdAddrB;
        regDatA     <= regfile[rdAddrA];
        regDatB     <= regfile[rdAddrB];
    end

    assign rdDataA = ((wrAddr_buf==rdAddrA_buf) & write_buf & wrAddr_buf!=5'b0) ? wrData_buf : regDatA;
    assign rdDataB = ((wrAddr_buf==rdAddrB_buf) & write_buf & wrAddr_buf!=5'b0) ? wrData_buf : regDatB;
endmodule
