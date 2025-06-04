include /gb3-2505/conf/setup.conf

# Base name for all generated files (.json, .asc, etc.)
DESIGN	= sail

# Acquire the sw directory from command line
ifndef hw
$(error Error: hw undefined; use `make hw=<some_hardware> <options>`)
endif
ifeq ($(wildcard $(hw)/),)
$(error Error: hw ("$(hw)") is not a subdirectory of $(CURDIR))
endif

HW = $(hw)

all:
	mkdir -p $(GB3_ROOT)/build
# cp $(HW)/programs/*_data.hex $(HW)/verilog/data.hex
# cp $(HW)/programs/*_program.hex $(HW)/verilog/program.hex

# Synthesize rtl into .json netlist
	yosys -q $(RTL_ROOT)/$(HW)/$(DESIGN).ys
# Place-and-route, translates the .json netlist to .asc bitstream
	nextpnr-ice40 --up5k --package uwg30 --json $(HW)/$(DESIGN).json --pcf $(HW)/$(DESIGN).pcf --asc $(HW)/$(DESIGN).asc --freq 6
# Timing analysis for the .asc bitstream
	icetime -p $(HW)/$(DESIGN).pcf -P uwg30 -d up5k -t $(HW)/$(DESIGN).asc
# Pack into .bin bitstream
	icepack $(HW)/$(DESIGN).asc design.bin
	mv design.bin $(GB3_ROOT)/build/design.bin

	@programs=$$(find $(RTL_ROOT)/$(HW)/programs -maxdepth 1 -type f -name '*_*' -exec basename {} \;); \
	echo "Converted to bitstream:"; \
	echo $$programs \

clean-hw:
	rm -f *.json *.blif *.asc *.bin

clean:
	rm -f *.json *.blif *.asc *.bin
	rm -f programs/*.hex
	rm -f verilog/*.hex
