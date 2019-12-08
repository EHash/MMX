#
# Author: Fengling <Fengling.Qin@gmail.com>
#
# This is free and unencumbered software released into the public domain.
# For details see the UNLICENSE file at the root of the source tree.
#

FUSESOC ?= fusesoc
GTKWAVE ?= gtkwave

FIRMWARE_FILE = firmware/MMX.hex
BIT_FILE = atta.bit
VCD_FILE = build/atta_0/sim-icarus/testbench.vcd
SIM_FILE = build/atta_0/sim-icarus/atta_0
SAV_FILE = testbench/atta/atta_tb.gtkw

.PHONY: all clean load sim view $(FIRMWARE_FILE)

all: $(BIT_FILE)

load:
	$(FUSESOC) pgm atta

sim: $(FIRMWARE_FILE) $(SIM_FILE)
	$(FUSESOC) sim atta --firmware=$(FIRMWARE_FILE) --vcd

view: sim $(VCD_FILE) $(SAV_FILE)
	$(GTKWAVE) $(VCD_FILE) $(SAV_FILE)

$(FIRMWARE_FILE):
	make -C firmware all

$(BIT_FILE): $(FIRMWARE_FILE)
	$(FUSESOC) build --target=synth --tool=vivado atta

$(SIM_FILE): $(FIRMWARE_FILE)
	$(FUSESOC) build --target=sim --tool=icarus atta --firmware=$(FIRMWARE_FILE)

clean:
	rm -rf build
	make -C firmware clean
