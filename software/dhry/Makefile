# If running dhry,
# back up `software/Makefile`,
# move to `software/`,
# run `make sw=dhry clean && make sw=dhry && make sw=dhry install`

include /gb3-2505/conf/setup.conf

ifndef sw
$(error Error: sw undefined; use `make sw=<some_software> <options>`)
endif
ifeq ($(wildcard $(sw)/),)
$(error Error: sw ("$(sw)") is not a subdirectory of $(CURDIR))
endif

SW			= $(sw)
PROGRAM		= $(SW)/$(SW)
INIT		= $(SW)/init
INCLUDE_DIR	= include

.PHONY: \
	all \
	$(SW) \
	clean

OPTFLAGS	= -O0

CFLAGS	 	 = -march=rv32i -mabi=ilp32 $(TARGET-ARCH-FLAGS) -Wall

ASFLAGS	 	= --march=rv32i --mabi=ilp32
INCLUDES	= -I$(INCLUDE_DIR)

LDFLAGS	 	= -L$(TOOLSLIB)/$(TARGET) -Map $(PROGRAM).map -T $(SW)/sail.ld
SREC2HEX	= srec2hex

OBJS		=\
		$(INIT).o\
		$(PROGRAM).o\
		$(SW)/syscalls.o\

all: $(PROGRAM) $(PROGRAM).sr Makefile

$(INIT).o: $(INIT).S
	$(AS) $(ASFLAGS) $(INIT).S -o $(INIT).o

$(SW)/syscalls.o: $(SW)/syscalls.c Makefile
	$(CC) $(CFLAGS) $(OPTFLAGS) $(INCLUDES) -c $(SW)/syscalls.c -o $(SW)/syscalls.o

$(PROGRAM): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@ -lc -lm -lgcc
	@echo "Generating symbol map for $(PROGRAM)"
	$(NM) -C $@ > $@.sym

$(PROGRAM).sr:$(PROGRAM)
	$(OBJCOPY) -O srec $(PROGRAM) $@

$(PROGRAM).o: $(PROGRAM).c Makefile
	$(CC) $(CFLAGS) $(OPTFLAGS) $(INCLUDES) -c $(PROGRAM).c -o $(PROGRAM).o

install: all
	mkdir -p $(PROCESSOR_ROOT)/programs/
	mkdir -p $(BUILD_ROOT)/$(SW)/
	$(SREC2HEX) -b 16384 $(PROGRAM).sr
	cp program.hex $(PROCESSOR_ROOT)/programs/$(SW)_program.hex
	cp data.hex $(PROCESSOR_ROOT)/programs/$(SW)_data.hex
	mv program.hex $(BUILD_ROOT)/$(SW)/$$(date +%y%m%d-%H-%M-%S)_$(SW)_program.hex
	mv data.hex $(BUILD_ROOT)/$(SW)/$$(date +%y%m%d-%H-%M-%S)_$(SW)_data.hex

clean:
	$(RM) $(PROGRAM) $(PROGRAM).sr $(PROGRAM).map; \
	cd $(SW_ROOT); \
	$(RM) $(INIT).i *.o 
