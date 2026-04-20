all: default

TOPNAME = vga
NXDC_FILES = constr/vga.nxdc
INC_PATH ?=

include ./general.mk

HEX_FILE = vsrc/vga/vga_image.hex
$(BIN): | $(HEX_FILE)

$(HEX_FILE): test.jpg scripts/img2vga.py
	python3 scripts/img2vga.py $< $@
