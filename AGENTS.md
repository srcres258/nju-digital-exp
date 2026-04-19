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
scripts/            Helper Python scripts
build/              Build output (obj_dir/, binaries)
general.mk          Shared Makefile — NVBoard projects (interactive)
general_plain.mk    Shared Makefile — plain Verilator + VCD tracing
<name>.mk           Per-project Makefile stub
```

## Build / Run / Clean Commands

Each experiment has its own Makefile stub (e.g. `fulladder.mk`,
`decode38.mk`). Invoke it with `-f`:

```bash
# Build
make -f fulladder.mk

# Build and run
make -f fulladder.mk run

# Clean build artifacts
make -f fulladder.mk clean

# Generate Verilator C++ headers only (no compile)
make -f fulladder.mk gen_header
```

### Two build flavours

| Flavour | Makefile include | Use for | Produces |
|---|---|---|---|
| NVBoard | `general.mk` | Interactive board visualisation | `build/<topname>` binary |
| Plain | `general_plain.mk` | Waveform simulation only | `build/<topname>` binary + `dump.vcd` |

NVBoard projects require `NVBOARD_HOME` to be set and a `.nxdc` constraint
file listed as `NXDC_FILES` in the project stub.

### Running a single experiment

```bash
make -f decode38.mk run          # plain: builds, runs, exits, writes dump.vcd
make -f fulladder.mk run         # NVBoard: opens interactive GUI
./build/decode38                 # run the binary directly (no rebuild)
```

There is **no automated test suite**. Verification is manual:
- Plain projects: inspect `dump.vcd` in a waveform viewer (e.g. GTKWave).
- NVBoard projects: interact with the virtual board GUI.

### Adding a new experiment

1. Create `vsrc/<topname>/<topname>.v` (top module).
2. Create `csrc/<topname>/tb_<topname>.cpp` (testbench).
3. Optionally create `constr/<topname>.nxdc` (NVBoard pin mapping).
4. Create `<topname>.mk`:

```makefile
all: default
TOPNAME = <topname>
INC_PATH ?=
# For NVBoard:
NXDC_FILES = constr/<topname>.nxdc
include ./general.mk
# For plain Verilator:
include ./general_plain.mk
```

## Code Style — Verilog (.v)

### Module structure
- **File = module**: one top-level module per `.v` file; filename matches
  module name. Helper modules (e.g. `mux_key.v`) live alongside.
- **ANSI-style ports**: `input [3:0] a, output reg [6:0] h` inside the port
  list.
- **Lowercase** for module names, signal names, and file names.
- **Named port connections** when instantiating sub-modules:
  ```verilog
  alu4 alu4(
      .func(func),
      .a(a),
      .b(b),
      .y(y)
  );
  ```

### Sensitivity lists
- Combinational: `always @(x or en)` — explicit signal list (not `always @(*)`).
- Sequential: `always @(posedge clk)`.

### Assignments
- Sequential logic: non-blocking `<=`.
- Combinational logic: blocking `=` or continuous `assign`.

### Comments
- Chinese comments are used for functional descriptions.
- `//` for single-line, `/* */` for block comments.
- Comment-out old implementations rather than deleting them when showing
  alternative approaches.

### Literal notation
- Binary: `4'b0001`, `8'b00000000`.
- Hex: `4'hA`, `8'hFF`.
- Decimal: `3'd7`.
- Use explicit bit widths on all literals.

### Templates and includes
- Use `` `include "mux_key.v" `` for shared templates (`MuxKey`,
  `MuxKeyWithDefault`).
- Suppress Verilator width warnings at file scope when needed:
  `/* verilator lint_off WIDTHEXPAND */`.

### case / casez
- Always include a `default` branch.
- Use `casez` with `z` (don't-care) for priority encoder patterns.

### Registers
- Provide `initial` blocks for register defaults when needed.
- Use `integer` for loop variables in `for` loops inside `always` blocks.

## Code Style — C++ Testbenches (.cpp)

### Two testbench patterns

**Pattern A — VCD waveform (plain):**
```cpp
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vdecode38.h"

VerilatedContext *contextp = nullptr;
VerilatedVcdC *tfp = nullptr;
static Vdecode38 *top = nullptr;

void stepAndDumpWave() {
    top->eval();
    contextp->timeInc(1);
    tfp->dump(contextp->time());
}

void simInit() {
    contextp = new VerilatedContext;
    tfp = new VerilatedVcdC;
    top = new Vdecode38;
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
    // ... stimulus ...
    simExit();
    return 0;
}
```

**Pattern B — NVBoard (interactive):**
```cpp
#include <nvboard.h>
#include "Vfulladder.h"

void nvboard_bind_all_pins(Vfulladder *top);

int main() {
    Vfulladder *dut = new Vfulladder;
    nvboard_bind_all_pins(dut);
    nvboard_init();

    while (1) {
        nvboard_update();
        dut->eval();
    }

    delete dut;
    return 0;
}
```

For sequential NVBoard designs, add a `single_cycle()` helper:
```cpp
void single_cycle() {
    top->clk = 0;
    top->eval();
    top->clk = 1;
    top->eval();
}
```

### Naming conventions
- Top-level DUT pointer: `top` (global or local).
- Verilated context: `contextp`.
- VCD trace file: `tfp`.
- Output waveform: `dump.vcd`.

### Stimulus style
- Use binary literals (`0b00`, `0b111`) for signal values.
- Drive inputs, then call `stepAndDumpWave()` (plain) or `single_cycle()`
  (NVBoard).
- For clocked designs, manually toggle `clk`: `top->clk = 1; stepAndDumpWave();
  top->clk = 0; stepAndDumpWave();`.

## Environment Variables

| Variable | Purpose | Required by |
|---|---|---|
| `NVBOARD_HOME` | Path to NVBoard installation | `general.mk` (NVBoard projects) |

## Scripts

- `scripts/seg_case_gen.py` — Generates seven-segment display `case` statements
  for Verilog. Usage: `python3 scripts/seg_case_gen.py`, then enter the number
  of display digits. Output can be pasted directly into a Verilog source file.

## Important Notes

- The build system passes `-DTOP_NAME="V<TOPNAME>"` as a C++ macro.
- Verilator flags include `-O3 --x-assign fast --x-initial fast --noassert`.
- `general.mk` uses `--trace` for VCD output; `general_plain.mk` also uses
  `--trace`.
- The `auto_bind.cpp` file is auto-generated from `.nxdc` constraint files by
  the NVBoard `auto_pin_bind.py` script — do not edit it manually.
