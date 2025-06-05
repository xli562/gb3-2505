# Processor

## Common Verilog source for an RV32I processor

Sail-RV32I-common is a small RISC-V processor core used as the baseline in teaching. These files are also currently used by [Narvie](https://github.com/physical-computation/narvie) for it's processor.

## Tests

The verilog modules have a (non-comprehensive) test suite which can be run using [iverilog](http://iverilog.icarus.com/).

## Modules

### Combinational

- `adder`: adds two words, no carry-in or carry-out.
- `alu_control`: decodes [3:0] funccode and [6:0] opcode into [6:0] alu_ctl.
- (?)`alu`: operates on two input words, gives one output word, and outputs branch_enable. (What's branch_enable?)
- (?)`branch_decide`: outputs mispredict, decision, branch_jump_trigger based on branch, predicted, branch_enable, jump.
- `control_unit`: decodes opcodes into flags such as memread / memwrite (for load / store instructions), jalr (for, literally, jalr) etc.
- `imm_gen`: coins the immediate fields together based on the instruction type.
- `forwarding_unit`:
- `instruction_memory`: 4096-word (0x1000 word / 0x4000 byte) block RAM, a place to store the compiled instructions (program.hex).
- `mux2to1`: 2-to-1 mux with word inputs, word output and 1-bit select.
- `sign_mask_gen`: for sign-extending.

### Clocked

- (?)`branch_predictor`: does some sort of branch prediction. The prediction passes thru some LUTs to determine if it is valid, before reaching the PC.
- `cpu`: connects all modules together, except the instruction memory and the data memory.
- `toplevel`: connects CPU with instruction memory and data memory.
- (?)`csr_file`: control and status registers, 1024 words. Supposed to be used in atomic swaps etc, other purposes unclear.
- (?)`data_mem`: data cache
- `cycle_counter`: sweet module from morse_encoder to count cycles.
- `morse_counter`: used for timing, for the morse module
- `morse_encoder`: toplevel of the morse module
- `morse_fsm`: fsm of the morse module
- `if_id`, `id_ex`, `ex_mem`, `mem_wb`: cute and simple pipeline dffs.
- `program_counter`: surprisingly **not** a counter, it is a simple, cute d-flipflop! Who does the counting for it?
- `regfile`: the 32 registers, their I/O buffers, and with some read / write control logic.
