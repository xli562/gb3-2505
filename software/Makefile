# This Makefile does the following:
#
#   some_software.c   (C source)
#         ↓  [preprocessor + compiler]
#   some_software.S   (RV32I assembly with CPP)
#         ↓  [assembler]
#   some_software.o   (ELF object file)
#         ↓  [linker (ld + sail.ld)]
#   some_software     (ELF executable, fully linked)
#         ↓  [objcopy -O srec]
#   some_software.sr  (Motorola S-Record image)
#         ↓  [srec2hex]
#   program.hex + data.hex
#         ↓  [copy to SPI flash on GB3 board]
# Some intermediate files are passed on directly and not stored in the file system.
# 
# ELF (Executable and Linkable Format file) is your on-disk/unix format for objects and executables.
# Object files (.o) are incomplete binaries waiting to be linked.
# Linker (ld) merges objects & libraries, applies an ABI, and produces a runnable image.
# LD is just the name of that linker program.
# Default target (riscv32-elf) tells every tool “we’re building for RV32I, ELF format.”
# Init files (init.S) bootstrap the C runtime.
# .S files are RV32I assembly language plus C-style preprocessing.
# .sr files are ASCII-encoded S-Records ready for your embedded bootloader.

include /gb3-2505/conf/setup.conf

# Acquire the sw directory from command line
ifndef sw
$(error Error: sw undefined; use `make sw=<some_software> <options>`)
endif
ifeq ($(wildcard $(sw)/),)
$(error Error: sw ("$(sw)") is not a subdirectory of $(CURDIR))
endif

# We perform two parallel builds:
#   Normal:     some_software with entry code init.S
#   Sunflower:  some_software-sf with entry code init-sf.S 
#               and a different load address.
#
# init.S and init-sf.S are tiny assembly routines that run before the main() in
# some_software.c. They typically sets up the stack pointer, clears any
# uninitialised data, calls any library constructors, and jumps to main().

SW 			= $(sw)
PROGRAM     = $(SW)/$(SW)
PROGRAM-SF  = $(SW)/$(SW)-sf
INIT        = $(SW)/init
INIT-SF     = $(SW)/init-sf
INCLUDE_DIR = include

.PHONY: \
	all \
	$(SW) \
	clean

# No compiler optimisations. Useful for FPGA debugging, 
# as we can step through source.
OPTFLAGS    = -O0

# Compiler flags
# Runtimes use the application binary interface (ABI) to
# express low-level binbary details. The ABI used here is ILP32.
# It defines, e.g., the stack pointer to be register x2.
#
# -Wall reports all warnings in the terminal
CFLAGS      = -march=rv32i -mabi=ilp32 $(TARGET-ARCH-FLAGS) -Wall

# Assembler flags
# Assembler translates .S file into binary opcodes
ASFLAGS     = --march=rv32i --mabi=ilp32
INCLUDES    = -I$(INCLUDE_DIR)

# Linker flags
#
# The linker (LD, short for 'link editor)':
#   * Reads reads all the .o files plus any required libraries,
#       (e.g., -lc, -lgcc, -lgloss. )
#   * Resolves symbol references 
#       (e.g. “where is main?” or “where is printf?”)
#   * Places code & data into memory regions defined by a linker script 
#       (sail.ld or via -Ttext 0x08004000)
#   * Produces a single ELF executable (now fully linked).
#
# The normal build uses sail.ld (the Sail generated linker script) to 
# load design into flash / RAM.
# The Sunflower build ignores sail.ld and does a raw load at LOADADDR-SF.
#
# .sr or SREC fikes are binary converted to ASCII, along with simple checksums.
# srec2hex converts them to hex files aligned to the flash memory's page size
LDFLAGS     = -L$(TOOLSLIB)/$(TARGET) -Map $(PROGRAM).map -T $(SW)/sail.ld
LDFLAGS-SF  = -Ttext $(LOADADDR-SF)  -L$(TOOLSLIB)/$(TARGET) -Map $(PROGRAM).map
SREC2HEX    = srec2hex
# Memory-mapped SPI-flash location for the FPGA RISC-V core 
# (plus 0x4000 for safety)
LOADADDR-SF = 0x08004000

# Object lists
OBJS		=\
		$(INIT).o\
		$(PROGRAM).o\

OBJS-SF	 	=\
		$(INIT-SF).o\
		$(PROGRAM).o\

# Default target
all: $(PROGRAM) $(PROGRAM).sr $(PROGRAM-SF) $(PROGRAM-SF).sr Makefile

# Assemble init.S into init.o
$(INIT).o: $(INIT).S
	$(AS) $(ASFLAGS) $(INIT).S -o $(INIT).o

# Link both of the .o files
$(PROGRAM): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@ -lc -lm -lgcc

# Convert the ELF to a .sr file, to be translated to .hex later by srec2hex
$(PROGRAM).sr:$(PROGRAM)
	$(OBJCOPY) -O srec $(PROGRAM) $@

# Compile some_software.c into some_software.o
$(PROGRAM).o: $(PROGRAM).c Makefile
	$(CC) $(CFLAGS) $(OPTFLAGS) $(INCLUDES) -c $(PROGRAM).c -o $(PROGRAM).o

# Preprocess init-sf.S into an intermediate .i file;
# assemble the .i file into init-sf.o
$(INIT-SF).o: $(INIT-SF).S
	$(CPP) $(INIT-SF).S > $(INIT-SF).i; \
	$(AS) $(ASFLAGS) $(INIT-SF).i -o $(INIT-SF).o

# Link at address 0x08004000 and
# pull in the “gloss” stubs (-lgloss) instead of the full math library.
$(PROGRAM-SF): $(OBJS-SF)
	$(LD) $(LDFLAGS-SF) $(OBJS-SF) -o $@ -lc -lgcc -lgloss

# Convert to .sr
$(PROGRAM-SF).sr:$(PROGRAM-SF)
	$(OBJCOPY) -O srec $(PROGRAM-SF) $@

# srec2hex splits the S-Record into program.hex & data.hex, 
# each aligned to 4 KiB blocks (-b 4096x4 = 16384)
# Copies those two Intel-Hex files into /processor/programs/ 
# so the FPGA loader can pick them up.
install: all
	mkdir -p $(RTL_ROOT)/processor/programs/
	mkdir -p $(BUILD_ROOT)/$(SW)/
	$(SREC2HEX) -b 16384 $(PROGRAM).sr
	cp program.hex $(RTL_ROOT)/processor/programs/$(SW)_program.hex
	cp data.hex $(RTL_ROOT)/processor/programs/$(SW)_data.hex
	mv program.hex $(BUILD_ROOT)/$(SW)/$$(date +%y%m%d-%H-%M-%S)_$(SW)_program.hex
	mv data.hex $(BUILD_ROOT)/$(SW)/$$(date +%y%m%d-%H-%M-%S)_$(SW)_data.hex

# Clean the directory, delete any build files.
# Does not affect .hex in $(BUILD_ROOT)/$(SW)/
clean:
	$(RM) $(PROGRAM-SF) $(PROGRAM-SF).sr $(PROGRAM-SF).map; \
	$(RM) $(PROGRAM) $(PROGRAM).sr $(PROGRAM).map; \
	cd $(SW_ROOT); \
	$(RM) $(INIT).i $(INIT-SF).i *.o 
