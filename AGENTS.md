# AGENTS.md

## Project Overview

Nanjing University Digital Experiment project — Verilog digital logic design
experiments simulated with [Verilator](https://www.veripool.org/verilator/) and
optionally visualized on [NVBoard](https://github.com/NJU-ProjectN/nvboard).

## Repository Layout

```
vsrc/<topname>/     Verilog source files (.v)
csrc/<topname>/     C++ testbenches (.cpp)
constr/             NVBoard pin-constraint files (.nxdc)
scripts/            Helper Python scripts (seg_case_gen.py)
build/              Build output (obj_dir/, binaries, dump.vcd)
general.mk          Shared Makefile — NVBoard projects (interactive GUI)
general_plain.mk    Shared Makefile — plain Verilator + VCD tracing
<name>.mk           Per-project Makefile stub
```

## Build / Run / Clean Commands

Each experiment has its own Makefile stub. Invoke with `-f`:

```bash
make -f <topname>.mk           # Build
make -f <topname>.mk run       # Build and run
make -f <topname>.mk clean     # Clean build artifacts
make -f <topname>.mk gen_header # Generate Verilator C++ headers only
./build/<topname>              # Run binary directly (no rebuild)
```

### Two build flavours

| Flavour | Include | Use for | Produces |
|---|---|---|---|
| NVBoard | `general.mk` | Interactive board visualisation | `build/<topname>` binary |
| Plain | `general_plain.mk` | Waveform simulation only | `build/<topname>` + `dump.vcd` |

- **Plain** (`general_plain.mk`): passes `--trace` to Verilator, generates VCD.
- **NVBoard** (`general.mk`): links NVBoard library, no VCD by default.
- NVBoard projects require `NVBOARD_HOME` set and `NXDC_FILES` in the stub.
- There is **no automated test suite**. Verify manually via waveforms or GUI.

### Adding a new experiment

1. Create `vsrc/<topname>/<topname>.v` (top module).
2. Create `csrc/<topname>/tb_<topname>.cpp` (testbench).
3. Optionally create `constr/<topname>.nxdc` (NVBoard pin mapping).
4. Create `<topname>.mk`:

```makefile
all: default
TOPNAME = <topname>
INC_PATH ?=
# For NVBoard (pick one):
NXDC_FILES = constr/<topname>.nxdc
include ./general.mk
# For plain Verilator (pick one):
include ./general_plain.mk
```

## Code Style — Verilog (.v)

### Module structure
- One top-level module per `.v` file; filename = module name. Helper modules
  (e.g. `mux_key.v`) live in the same directory.
- **ANSI-style ports**: `input [3:0] a, output reg [6:0] y` inside the port list.
- **Lowercase** for module names, signal names, and file names.
- **Named port connections** when instantiating sub-modules:
  `alu4 alu4(.func(func), .a(a), .b(b), .y(y));`

### Sensitivity lists
- Combinational: `always @(x or en)` — explicit signal list, not `always @(*)`.
- Sequential: `always @(posedge clk)`.

### Assignments
- Sequential logic: non-blocking `<=`.
- Combinational logic: blocking `=` or continuous `assign`.

### Literals
- Always use explicit bit widths: `4'b0001`, `8'hFF`, `3'd7`.

### case / casez
- Always include a `default` branch.
- Use `casez` with `z` (don't-care) for priority encoder patterns.

### Other
- `initial` blocks for register defaults when needed.
- `integer` for loop variables in `for` inside `always` blocks.
- `` `include "mux_key.v" `` for shared templates (`MuxKey`, `MuxKeyWithDefault`).
- Suppress Verilator warnings at file scope: `/* verilator lint_off WIDTHEXPAND */`.
- Chinese comments for functional descriptions; `//` single-line, `/* */` block.
- Comment-out old implementations rather than deleting.

## Code Style — C++ Testbenches (.cpp)

### Pattern A — VCD waveform (plain)

```cpp
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "V<topname>.h"

VerilatedContext *contextp = nullptr;
VerilatedVcdC *tfp = nullptr;
static V<topname> *top = nullptr;

void stepAndDumpWave() { top->eval(); contextp->timeInc(1); tfp->dump(contextp->time()); }
void simInit() { /* new context, new VCD, new top, trace on, open dump.vcd */ }
void simExit() { stepAndDumpWave(); tfp->close(); delete top; delete tfp; delete contextp; }

int main() { simInit(); /* stimulus */ simExit(); return 0; }
```

### Pattern B — NVBoard (interactive)

```cpp
#include <nvboard.h>
#include "V<topname>.h"
void nvboard_bind_all_pins(V<topname> *top);

int main() {
    V<topname> *dut = new V<topname>;
    nvboard_bind_all_pins(dut);
    nvboard_init();
    while (1) { nvboard_update(); dut->eval(); }
    delete dut; return 0;
}
```

For clocked NVBoard designs, add a `single_cycle()` helper:
```cpp
void single_cycle() { top->clk = 0; top->eval(); top->clk = 1; top->eval(); }
```

### Naming and stimulus conventions
- DUT pointer: `top` (global or local). Verilated context: `contextp`. VCD: `tfp`.
- Waveform output: `dump.vcd`.
- Use binary literals (`0b00`, `0b111`) for signal values.
- Drive inputs, then call `stepAndDumpWave()` (plain) or `single_cycle()` (NVBoard).

## Environment Variables

| Variable | Purpose | Required by |
|---|---|---|
| `NVBOARD_HOME` | Path to NVBoard installation | `general.mk` (NVBoard projects) |

## Important Notes

- Build system passes `-DTOP_NAME="V<TOPNAME>"` as a C++ macro.
- Verilator flags: `-O3 --x-assign fast --x-initial fast --noassert`.
- `auto_bind.cpp` is auto-generated from `.nxdc` by NVBoard's `auto_pin_bind.py`
  — do not edit manually.
- `scripts/seg_case_gen.py` generates seven-segment `case` statements for Verilog.
