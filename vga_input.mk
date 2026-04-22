all: default

TOPNAME = vga_input
NXDC_FILES = constr/vga_input.nxdc
INC_PATH ?=

include ./general.mk

FONT_FILE = vsrc/vga_input/font.hex
$(BIN): | $(FONT_FILE)

$(FONT_FILE): iv9x16u.bdf scripts/bdf2font.py
	python3 scripts/bdf2font.py $< $@
