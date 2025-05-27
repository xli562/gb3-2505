// sb_hfosc_stub.v
// A “dummy” SB_HFOSC so that simulation/synthesis 
// won’t complain about the missing Lattice primitive.

`ifndef SYNTHESIS
module SB_HFOSC #(
    parameter CLKHF_DIV = "0b11"  // default divider value
) (
    output CLKHFEN,
    output CLKHFPU,
    output CLKHF
    );
    // Either tie it low or feed it from your testbench
    // Here we just turn it off in simulation:
endmodule
`endif