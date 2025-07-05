# Readme

This is a fork of [gb3-resources](https://github.com/f-of-e/gb3-resources), the teaching repo of the GB3 RISC-V Processor project.

## Hopefully this is helpful to future students...

ALL RIGHTS RESERVED, DO NOT PLAGIARISE.

It is 01:28 in the morning, so don't expect logical smoothness. But I'm trying to be helpful, as you will find out, help is very much needed for this project. Also, this part of readme is purely personal opinion. Take with a pinch of salt and spices. Use Git to see who wrote this, if interested. If you don't know how to do this with Git, you're underequipped. Learn Git. Git is important to keep things intact.

Structure of the Git graph of this repo. Very messy. Most branches are unfinished attempts or drafts. The branches we used in the final competition are `perf` and `comp`. perf is faster and comp is more frugal. We made it to the Pareto frontier.

It is VERY important to clear some obstacles at the VERY beginning of the project:

- Who does what
- Make sure you use and respect Git!! (However, "a foolish consistency is the hobgoblin of little minds")
- Understand the CPU structure, `cpu.v`. Difficult, but once this passed Eureka, the mist around the project would suddenly be gone.
- Tidy up the code in the original repo. It is shamefully messy, with tab indents and stylistic inconsistency everywhere. Perhaps use AI tools to do a big re-format. After re-formatting, the code will be a pleasure to read, at least compared to what's there before. Alternatively, refer to `perf` and `comp` in this repo, but avoid plagiarism.

### Tips

- There are some bugs in the repo. All known bugs are fixed in `perf` and `comp` to the best of my knowledge. Notablly, the memory is byte-addressed, so an increment of FOUR for every 32-bit word.
- Lots of knowledge is assumed but not posessed. Learn the important bits (eg RISC-V instructions' meaning) first, don't waste too much time on details (eg makefile grammar). Use good AI tools to help you learn!
- Find academic papers on optimised RISC-V cores. Some have 'wow' ideas that you can implement. Remember to test if their method actually speeds things up.
- The P&H book (*Computer Organisation, the Hardware - Software Interface*), Chapter 4, is the reason for the pitiable variable naming convention. The chapter itself, though, is highly recommended.
- Sunflower is only used for counting instructions. Don't try to use it for anything else.
- Use robust testing. You will be SAD to realise something's probably broken by some changes earlier on, but there are a hundred changes that could potentially be the issue. Testbench code is needed, but not too much. More than 30-50% of your time should be spent writing NEW Verilog code, or you'll struggle to fill the reports' pages. Only ever merge tested changes to main.

### Other thoughts

Potential improvements. We have attempted to eliminate memory access clock stalls, but our design could not synthesize, since it uses both positive edge and negative edge triggering, whereas the iCE40 RAM only supports either positive or negative edge triggering. While the limited timeframe forces abandonment of this design, I was close to designing a zero-stall data memory using purely negative edge triggered sequential logic. This design is proven possible by a team this year. Additionally, further simplifications in the pipeline and forwarding logic can reduce the critical path delay.

Test process. using a single program that integrates behavioural and I/O tests can save time in compilation and uploading test softwares to the development board.

Branch predictor optimisations are abandoned since they do not provide significant speedup but consume more energy and resource. Other designs such as the zero-stall data memory fail to pass test.

In hindsight, I would have focused the first two days of the project on formatting the codebase, instead of formatting as the project goes along. In this way, it would be easier to merge changes.

I would not have spent two days trying to automate the make and test process with Python scripts, since the invested time does not yield significant benefits, and the automation scripts are abandoned in the end.

It would also be helpful to keep a shared log of changes that each team member is making, so that we do not repeat others' work. 

Finally, although drawing a full schematics of the CPU is difficult and time-consuming, **producing a complete schematic of `cpu.v` has proved extremely valuable in helping me understand the fine structural details of the baseline design** (yes!). It would be difficult to come up with effective optimisations had I not posessed this level of insight into the baseline design.

I learned a lot from the project, and I still love hardware design. Now I shall sleep.

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
