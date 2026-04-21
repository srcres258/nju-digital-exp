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
scripts/            Helper Python scripts (seg_case_gen.py, img2vga.py)
build/              Build output (obj_dir/, binaries, dump.vcd)
general.mk          Shared Makefile — NVBoard projects (interactive GUI)
general_plain.mk    Shared Makefile — plain Verilator + VCD tracing
<name>.mk           Per-project Makefile stub
```

## Build / Run / Clean Commands

Each experiment has its own Makefile stub. Invoke with `-f`:

```bash
make -f <topname>.mk           # Build only
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
  **Only compiles `<topname>.v`** — does NOT pick up helper modules automatically.
- **NVBoard** (`general.mk`): links NVBoard library, compiles **all `.v` files** in
  the source directory. No VCD by default.
- NVBoard projects require `NVBOARD_HOME` set and `NXDC_FILES` in the stub.
- There is **no automated test suite**. Verify manually via waveforms or GUI.

### Viewing waveforms

After running a plain build, open `build/dump.vcd` with a waveform viewer:
```bash
gtkwave build/dump.vcd
```

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
- `inout` ports are allowed (e.g. carry signals in `fulladder`).

### Sensitivity lists
- Combinational: `always @(x or en)` — explicit signal list, not `always @(*)`.
  Exception: `mux_key.v` template uses `always @(*)` internally.
- Sequential: `always @(posedge clk)`.

### Assignments
- Sequential logic: non-blocking `<=`.
- Combinational logic: blocking `=` or continuous `assign`.

### Literals
- Always use explicit bit widths: `4'b0001`, `8'hFF`, `3'd7`.
- Avoid bare integers in assignments; write `y = 0;` only when width is unambiguous.

### case / casez
- Always include a `default` branch.
- Use `casez` with `z` (don't-care) for priority encoder patterns.

### MuxKey template system
- Use `` `include "mux_key.v" `` at the top of the file to import `MuxKey` and
  `MuxKeyWithDefault` parameterized multiplexer templates.
- `MuxKey #(#keys, key_width, data_width)` — no default output.
- `MuxKeyWithDefault #(#keys, key_width, data_width)` — has default output.
- **Important**: Only works with `general.mk` (NVBoard) which compiles all `.v`
  files. If using `general_plain.mk`, helper modules must be included via
  `` `include `` directives.

### Verilator lint suppression
- Place `/* verilator lint_off WIDTHEXPAND */` at **file scope before the module
  declaration** — not inside always blocks.
- Common suppressions: `WIDTHEXPAND`, `UNUSEDSIGNAL`, `UNOPTFLAT`.

### Other conventions
- `initial` blocks for register defaults when needed.
- `integer` for loop variables in `for` inside `always` blocks.
- Chinese comments for functional descriptions; `//` single-line, `/* */` block.
- Comment-out old implementations rather than deleting.

## Code Style — C++ Testbenches (.cpp)

### Pattern A — VCD waveform (plain, `general_plain.mk`)

```cpp
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "V<topname>.h"

VerilatedContext *contextp = nullptr;
VerilatedVcdC *tfp = nullptr;
static V<topname> *top = nullptr;

void stepAndDumpWave() {
    top->eval();
    contextp->timeInc(1);
    tfp->dump(contextp->time());
}

void simInit() {
    contextp = new VerilatedContext;
    tfp = new VerilatedVcdC;
    top = new V<topname>;
    contextp->traceEverOn(true);
    top->trace(tfp, 0);
    tfp->open("dump.vcd");
}

void simExit() {
    stepAndDumpWave();
    tfp->close();
    delete top;
    delete tfp;
    delete contextp;
}

int main() {
    simInit();
    // drive inputs, call stepAndDumpWave() after each change
    simExit();
    return 0;
}
```

### Pattern B — NVBoard (interactive, `general.mk`)

Combinational (no clock):
```cpp
#include <nvboard.h>
#include "V<topname>.h"
void nvboard_bind_all_pins(V<topname> *top);

int main() {
    V<topname> *top = new V<topname>;
    nvboard_bind_all_pins(top);
    nvboard_init();
    while (1) { nvboard_update(); top->eval(); }
    delete top;
    return 0;
}
```

Clocked (with `single_cycle` helper):
```cpp
#include <nvboard.h>
#include "V<topname>.h"
V<topname> *top = nullptr;
void nvboard_bind_all_pins(V<topname> *top);

void single_cycle() {
    top->clk = 0; top->eval();
    top->clk = 1; top->eval();
}

int main() {
    top = new V<topname>;
    nvboard_bind_all_pins(top);
    nvboard_init();
    while (true) { nvboard_update(); single_cycle(); }
    delete top;
    return 0;
}
```

### Naming and stimulus conventions
- DUT pointer: `top` (global or local). Verilated context: `contextp`. VCD: `tfp`.
- Waveform output: `dump.vcd` in the project root.
- Use binary literals (`0b00`, `0b111`) for signal values in stimulus code.
- Drive inputs, then call `stepAndDumpWave()` (plain) or `single_cycle()` (NVBoard).

## Constraint Files (.nxdc)

NVBoard pin mapping files live in `constr/`. Format:
```
top=<topname>

# comment
<signal_name> <NVBOARD_PIN>
```

- One signal per line. A signal can map to multiple pins (e.g. `y LD0` and `y LD1`).
- `auto_bind.cpp` is auto-generated from `.nxdc` by NVBoard's `auto_pin_bind.py`
  — do not edit manually.

## Environment Variables

| Variable | Purpose | Required by |
|---|---|---|
| `NVBOARD_HOME` | Path to NVBoard installation | `general.mk` (NVBoard projects) |

## Helper Scripts

| Script | Purpose |
|---|---|
| `scripts/seg_case_gen.py` | Generates seven-segment `case` statements for Verilog |
| `scripts/img2vga.py` | Converts images to VGA framebuffer data for Verilog |

## Important Notes

- Build system passes `-DTOP_NAME="V<TOPNAME>"` as a C++ macro.
- Verilator flags: `-O3 --x-assign fast --x-initial fast --noassert`.
- `general_plain.mk` finds only `<topname>.v`; `general.mk` finds all `*.v` in the
  source directory. Keep this in mind when adding helper modules.
