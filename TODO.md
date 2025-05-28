# TODO

1. Go through & write tests & format RTL source code
1. Enable .hex files to be loaded in Cocotb/Verilator simulation
1. Watch Moodle videos: pipelining (14'), sunflower tutorial (28'), verilog tutorial (53'), intro to FPGA tools (5'); read Emma (17p), Amdahl (3p), Reevaluating Amdahl (2p).
1. Add reset logic for consistent behaviour
1. Automate with Python (one python file per workflow):
    1. (sim.py) build software and simulate with Sunflower
    1. (tb.py) build software and run Cocotb testbench
    1. (bin-gen.py) build software, generate bitstream, and save as some_software_design.bin for upload later
    1. (upload.py) build software, generate bitstream, and upload to board

## Questions for Tuesday 27

- Bug in baseline RTL code?

```verilog
/*
 *    LUI, U-Type
 */
`kRV32I_INSTRUCTION_OPCODE_LUI:
    ALUCtl = 7'b0000010;
```
