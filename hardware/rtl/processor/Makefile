include /gb3-2505/conf/setup.conf

# Base name for all generated files (.json, .asc, etc.)
DESIGN	= sail

all:
	mkdir -p $(GB3_ROOT)/build
	cp programs/*_data.hex verilog/data.hex
	cp programs/*_program.hex verilog/program.hex

# Synthesize rtl into .json netlist
	yosys -q $(RTL_ROOT)/processor/$(DESIGN).ys -l stats.txt
# Place-and-route, translates the .json netlist to .asc bitstream
	nextpnr-ice40 --up5k --package uwg30 --json $(DESIGN).json --pcf $(DESIGN).pcf --asc $(DESIGN).asc
# Timing analysis for the .asc bitstream
	icetime -p $(DESIGN).pcf -P uwg30 -d up5k -t sail.asc
# Pack into .bin bitstream
	icepack $(DESIGN).asc design.bin
	mv design.bin $(GB3_ROOT)/build/design.bin

	@programs=$$(find $(RTL_ROOT)/processor/programs -maxdepth 1 -type f -name '*_*' -exec basename {} \;); \
	echo "Converted to bitstream:"; \
	echo $$programs \

clean-hw:
	rm -f *.json *.blif *.asc *.bin

clean:
	rm -f *.json *.blif *.asc *.bin
	rm -f programs/*.hex
	rm -f verilog/*.hex
