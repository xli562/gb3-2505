# TODO

1. Look at waveform to see what exactly triggers LED switch. Could insert signal `wire write_led = w_ena_i == 1'b1 && addr_i == 32'h2000;`

Run this command: `gtkwave /home/xl562/gb3/gb3-2505/hardware/tb/waves/250609_00_26_55_toplevel.fst`

1. Very high clk stall rate for data mem -> wrap data mem in forwarding so that no stall is needed.

## Questions for Friday 30

- What is branch_enable in alu?
- Is CSRR in the RV32I ISA? Do we really need it for our single-core single-process single-thread processor? --- NO! Get rid of CSRR.
