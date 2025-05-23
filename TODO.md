# TODO

1. Go through & format RTL source code
1. Enable .hex files to be loaded in Cocotb/Verilator simulation
1. Write tests for modules
1. Automate with Python (one python file per workflow):
    1. (sim.py) build software and simulate
    1. (tb.py) build software and run testbench
    1. (bin-gen.py) build software, generate bitstream, and save as some_software_design.bin for upload later
    1. (upload.py) build software, generate bitstream, and upload to board

## Questions for Tuesday 20

- Why does bubblesort do strange things after it terminates? It sorts perfectly, then goes on to flash randomly until it settles on a fixed routine of flashing every 5 seconds or so. Blinking the LED forever upon sort finish proves that sorting _does_ finish.
