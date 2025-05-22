# Readme

This is a fork of [gb3-resources](https://github.com/f-of-e/gb3-resources), the teaching repo of the GB3 RISC-V Processor project.

## Workflow

Using the bubblesort program in `./bubblesort` as an example.

### Connecting the iCE5UP5K to the host machine

#### Windows

Find the bus id with

`usbipd list`

attach device to WSL with

`usbipd attach --wsl --busid <bus_id>`

### Compile and install

Run in docker bash

```bash
cd bubblesort
make
make install 
```

This creates `program.hex` and `data.hex` in `./bubblesort`, and copies them into `./processor/programs`.

At this point, emulation can be made.

### Emulation

Emulation is performed using the [Sunflower emulator](https://github.com/physical-computation/sunflower-embedded-system-emulator/tree/ad12f949c23b0c01477ad0b0325dc2f8f8c3deb2), capable of power and behavioural simulation.

Go to `./bubblesort`. Create `run.m` if the file is not yet there.

```c
newnode     riscv
sizemem     65536
srecl       "bubblesort-sf.sr"
run
on
```

(Alternatively, the above instructions can be manually input to the Sunflower CLI.)

Then run in docker bash

```bash
sf run.m
ni
showclk
quit
```

This should give the instruction count for the emulation of bubblesort, for example

```bash
ni
Dynamic instruction count = [687], fetched instructions = [736]
showclk
CLK = 739, ICLK = 739, TIME = 1.231667E-05, CYCLETIME = 1.666667E-08
```

### Upload

To upload the processor design loaded with the compiled C program, the design needs to be built first. Go to `./processor` and run in docker bash

```bash
make
```

This creates `design.bin` in `./processor`, and copies it into `./build`.

Finally, run in Linux bash

```bash
sudo iceprog-S build/design.bin
```

to upload the design through USB.

### Measurement

#### Execution time

Two controllable pins are found:

led[7] -> E4 -> pin 15 of J33
led[0] -> D3 -> Green LED ("D14" on the PCB).

## Tools for convenience

`tmux` makes switching between docker and linux easier. I personally distrust the VS Code intergrated command line.

### Install

```bash
sudo apt install tmux
```

### Basic use

All commands are prefixed by Control + B (`^B`).

`tmux`

New window: `^B ^C`

Next window: `^B ^N`

Previous window: `^B ^P`

Rename window: `^B ,`

Enter scroll mode: `^B [`

Scroll: PgUp / PgDn

Exit bash (close window): `exit` or `^D`
