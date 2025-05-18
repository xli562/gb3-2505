# README

## Common Verilog source for an RV32I processor

Sail-RV32I-common is a small RISC-V processor core used as the baseline in teaching. These files are also currently used by [Narvie](https://github.com/physical-computation/narvie) for it's processor.

## Tests

The verilog modules have a (non-comprehensive) test suite which can be run using [iverilog](http://iverilog.icarus.com/).

## RTL Coding Convention

Follow the RTL linter as a baseline. Specific linting can be turned off by

```verilog
/* verilator lint_off UNUSEDPARAM */
```

if there is good reason to do so.

### 1.   Authorship Notice

Include this at the start of each file. Collapse this in the code editor if it is cumbersome.

```verilog
/*
    Authored 2019, <Author Name Here>.

    All rights reserved.
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:

    *   Redistributions of source code must retain the above
        copyright notice, this list of conditions and the following
        disclaimer.

    *   Redistributions in binary form must reproduce the above
        copyright notice, this list of conditions and the following
        disclaimer in the documentation and/or other materials
        provided with the distribution.

    *   Neither the name of the author nor the names of its
        contributors may be used to endorse or promote products
        derived from this software without specific prior written
        permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/
```

### 2. Signal and Instance Names

i. Signal names lowercase. I see an aesthetic argument in favor of underscores in the hardware case, as opposed to camelCase in the software case.

ii. Use the suffix `_register` for signals that are single-bit registers (flip-flops) or multi-bit registers.

iii. Use the suffix `_latch` for signals that you really intend to be non-clocked, level-sensitive, memory elements (latches).

iv. Use suffix `_i` for input, and `_o` for output signals.

v. Use suffix `_n` (e.g. `ipsa_spi_cs_n`) for active-low signals.

vi. Use suffix `_inst` for instances, `inst_0`, `inst_1` etc. for multiple instances of the same module, to separate instances from signals and module names. For example,

```verilog
skid_buffer skid_buffer_inst (
    .clk           (clk_i),
    .rst           (~reset_n_i),
    .data_in       (data_i),
    .data_in_valid (valid_i),
    .data_in_ready (ready_o),
    .data_out      (data_o),
    .data_out_valid(valid_o),
    .data_out_ready(ready_i)
);
```

### 3.   Signal Declarations

i. One type specifier per signal and end the line with a comment on the signal's use where appropriate. So,

```verilog
wire  ipsa_spi_cs_n;    /*  SPI chip select, at Ipsa module interface.          */
wire  ipsa_spi_miso;    /*  SPI master out slave in, at Ipsa module interface.  */
```

but not

```verilog
wire  ipsa_spi_cs_n, ipsa_spi_miso;
```

ii. Keep all port definitions and variable definitions at the top of the module, grouped by type (e.g., `input`, `output`, and `inout` grouped together, followed by `wire`, then `reg`).

iii. Use the following convention for ordering the signal arguments of a module $^1$: `inout` signals first, followed by `input` signals, with `output` signals last.

For example, here is the signal declarations section of a FIFO queue:

```verilog
input  logic                  clk_i,
input  logic                  reset_n_i,

input  logic [DATA_WIDTH-1:0] data_i,
input  logic                  valid_i,
output logic                  ready_o,

output logic [DATA_WIDTH-1:0] data_o,
output logic                  valid_o,
input  logic                  ready_i,

output logic                  empty_o,
output logic                  full_o
```

iv. To prevent the compiler misrecognising typos as new signal names, have these two lines immediately following the authorship notice:

```verilog
`default_nettype none
`timescale 1ns/1ps
```

### 4.   Indentation

Indent with the 'Tab' key, not the 'Spacebar' key. Indenting with spaces does not let you provide as clear semantic intent. Set tab width to 4 spaces in editor.

### 5.   Width of content per line and wrapping

Keep the length of lines short. One reasonable guide is to keep to the left side of the 79-character ruler (set in `.vscode/settings.json`). Manually break lines rather than using the editor to automatically visually wrap them.

### 7.   Constants and `define`s

All constants begin with `k<namespace>`. So, e.g., in Ipsa design constants which are conceptually part of the overall Ipsa design are `kIpsaXXX`.

### 8.   Type names and alignment

Type names (along with any width specification) in the first column, with instance names aligned in second column.

```verilog
wire                                barrier_done_wire;
wire [(`kIpsaWireWidth-1):0]        i2c_address;
```

### 9. Newlines, carriage returns, and whitespace

i. Line endings are Unix line endings (newline only, no carriage return).

ii. A newline should never come after whitespace (space or tab).

### 10. Files

i. One module per file.

ii. The file name should mirror the name of the module it contains.

iii. All constants in a separate file to be included from other design files.

iv. File name extensions should match file type: shell scripts should have the `.sh` suffix, Verilog files the `.v` suffix, etc.

----
$^1$ This convention is specifically borrowed from Monty Dalrymple's Z80 RTL design.
