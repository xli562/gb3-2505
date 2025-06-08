`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"


module forwarding_unit(rs1, rs2, MA_RegWriteAddr, WB_RegWriteAddr, MA_RegWrite, WB_RegWrite, MA_fwd1, MA_fwd2, WB_fwd1, WB_fwd2);
   input [4:0]   rs1;
   input [4:0]   rs2;
   input [4:0]   MA_RegWriteAddr;
   input [4:0]   WB_RegWriteAddr;
   input      MA_RegWrite;
   input      WB_RegWrite;
   output      MA_fwd1;
   output      MA_fwd2;
   output      WB_fwd1;
   output      WB_fwd2;

   /*
    *   if data hazard detected, assign RegWrite to decide if...
    *   result MA or WB stage should be rerouted to ALU input
    */
   assign MA_fwd1 = (MA_RegWriteAddr != 5'b0 && MA_RegWriteAddr ==  rs1)?MA_RegWrite:1'b0;
   assign MA_fwd2 = (MA_RegWriteAddr != 5'b0 && MA_RegWriteAddr ==  rs2 && MA_RegWrite == 1'b1)?1'b1:1'b0;

   /*
    *   from wb stage
    */
   assign WB_fwd1 = (WB_RegWriteAddr != 5'b0 && WB_RegWriteAddr ==  rs1 && WB_RegWriteAddr != MA_RegWriteAddr)?WB_RegWrite:1'b0;
   assign WB_fwd2 = (WB_RegWriteAddr != 5'b0 && WB_RegWriteAddr ==  rs2 && WB_RegWrite == 1'b1 && WB_RegWriteAddr != MA_RegWriteAddr)?1'b1:1'b0;

endmodule
