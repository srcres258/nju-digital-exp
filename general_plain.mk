VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc  \
				-O3 --x-assign fast --x-initial fast --noassert \
				-I$(abspath ./vsrc/$(TOPNAME))

BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(TOPNAME)

default: $(BIN)

$(shell mkdir -p $(BUILD_DIR))

# project source
VSRCS = $(shell find $(abspath ./vsrc/$(TOPNAME)) -name "$(TOPNAME).v")
CSRCS = $(shell find $(abspath ./csrc/$(TOPNAME)) -name "*.c" -or -name "*.cc" -or -name "*.cpp")

# rules for verilator
INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS += $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\""

$(BIN): $(VSRCS) $(CSRCS)
	@rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $^ \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe --trace -o $(abspath $(BIN))

run: $(BIN)
	@$^

clean:
	rm -rf $(BUILD_DIR)

gen_header:
	$(VERILATOR) --top-module $(TOPNAME) --Mdir $(OBJ_DIR) --cc $(VSRCS) \
		-I$(abspath ./vsrc/$(TOPNAME))

.PHONY: default all clean run sim gen_header
