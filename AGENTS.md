# AGENTS.md

## Project Overview

NJU Digital Experiment — Verilog digital logic designs simulated with
[Verilator](https://www.veripool.org/verilator/) and optionally visualized on
[NVBoard](https://github.com/NJU-ProjectN/nvboard).

## Repository Layout

```
vsrc/<topname>/     Verilog source files (.v)
csrc/<topname>/     C++ testbenches (.cpp)
constr/             NVBoard pin-constraint files (.nxdc)
scripts/            Helper Python scripts
build/              Build output (obj_dir/, binaries, dump.vcd)
general.mk          Shared Makefile — NVBoard projects (interactive GUI)
general_plain.mk    Shared Makefile — plain Verilator + VCD tracing
<topname>.mk        Per-project Makefile stub
```

## Build / Run / Clean

Each experiment has its own Makefile stub invoked with `-f`:

```bash
make -f <topname>.mk             # Build
make -f <topname>.mk run         # Build and run
make -f <topname>.mk clean       # Clean build artifacts
make -f <topname>.mk gen_header  # Generate Verilator C++ headers only
./build/<topname>                # Run pre-built binary
```

### Two build flavours

| Flavour | Makefile | Features | Source scope |
|---|---|---|---|
| NVBoard | `general.mk` | Interactive board GUI | All `*.v` in `vsrc/<topname>/` |
| Plain | `general_plain.mk` | VCD waveform tracing (`dump.vcd`) | Only `<topname>.v` |

**Critical difference**: `general_plain.mk` compiles ONLY `<topname>.v`. If the
top module instantiates helper modules (e.g. `mux_key.v`), either use
`general.mk` or `` `include `` the helper file in the top module.

NVBoard projects require `NVBOARD_HOME` env var set and `NXDC_FILES` defined in
the stub Makefile. There is **no automated test suite** — verify via waveforms
or interactive GUI.

### Viewing waveforms

```bash
gtkwave build/dump.vcd
```

### Adding a new experiment

1. `vsrc/<topname>/<topname>.v` — top module
2. `csrc/<topname>/tb_<topname>.cpp` — testbench
3. (Optional) `constr/<topname>.nxdc` — NVBoard pin mapping
4. `<topname>.mk`:

```makefile
all: default
TOPNAME = <topname>
INC_PATH ?=
# NVBoard (pick one):
NXDC_FILES = constr/<topname>.nxdc
include ./general.mk
# Plain Verilator (pick one):
include ./general_plain.mk
```

## Code Style — Verilog (.v)

### Module conventions
- One top-level module per `.v`; filename = module name. Helper modules
  (e.g. `mux_key.v`) coexist in the same directory.
- **ANSI-style ports**: `input [3:0] a, output reg [6:0] y` inside the port list.
- **Lowercase** for module names, signal names, and file names.
- **Named port connections** for sub-module instantiation:
  `alu4 alu4(.func(func), .a(a), .b(b), .y(y));`
- `inout` ports allowed (e.g. carry signals).

### Sensitivity lists
- Combinational: `always @(x or en)` — explicit signal list, not `always @(*)`.
  Exception: `mux_key.v` template uses `always @(*)` internally.
- Sequential: `always @(posedge clk)`.

### Assignments and literals
- Sequential: non-blocking `<=`. Combinational: blocking `=` or `assign`.
- **Always use explicit bit widths**: `4'b0001`, `8'hFF`, `3'd7`.
  Bare `0` only when width is unambiguous.

### case / casez
- Always include `default`.
- Use `casez` with `z` (don't-care) for priority encoder patterns.

### MuxKey template system
- `` `include "mux_key.v" `` at file top to import `MuxKey` /
  `MuxKeyWithDefault` parameterized mux templates.
- `MuxKey #(#keys, key_width, data_width)` — no default output.
- `MuxKeyWithDefault #(#keys, key_width, data_width)` — has default output.
- Only works with `general.mk` (compiles all `.v`). For `general_plain.mk`,
  use `` `include `` directives.

### Verilator lint suppression
- Place `/* verilator lint_off WIDTHEXPAND */` at **file scope before the module
  declaration**. Common suppressions: `WIDTHEXPAND`, `UNUSEDSIGNAL`, `UNOPTFLAT`.

### Other
- `initial` blocks for register defaults. `integer` for loop variables in `for`.
- Chinese comments for functional descriptions. Comment-out old code rather than
  deleting.

## Code Style — C++ Testbenches (.cpp)

Two patterns — choose based on the Makefile flavour:

**Pattern A — Plain/VCD** (`general_plain.mk`): uses `VerilatedContext`,
`VerilatedVcdC*`, `simInit()`, `stepAndDumpWave()`, `simExit()`. Global pointers:
`contextp`, `tfp`, `top`. Output: `dump.vcd`.

**Pattern B — NVBoard** (`general.mk`): uses `nvboard_bind_all_pins()`,
`nvboard_init()`, `nvboard_update()`. Clocked designs add `single_cycle()`
(toggles `clk` 0→1). Combinational designs just call `top->eval()`.

### Testbench conventions
- DUT pointer: `top` (global or local). Use binary literals (`0b00`, `0b111`)
  for signal values in stimulus.
- Drive inputs, then call `stepAndDumpWave()` (plain) or `single_cycle()` (NVBoard).

## Constraint Files (.nxdc)

Format:
```
top=<topname>
# comment
<signal_name> <NVBOARD_PIN>
```
One signal per line; a signal can map to multiple pins. `auto_bind.cpp` is
auto-generated — do not edit manually.

## Environment Variables

| Variable | Purpose | Required by |
|---|---|---|
| `NVBOARD_HOME` | NVBoard installation path | `general.mk` |

## Important Notes

- Build passes `-DTOP_NAME="V<TOPNAME>"` as a C++ macro.
- Verilator flags: `-O3 --x-assign fast --x-initial fast --noassert`.
- Helper scripts: `scripts/seg_case_gen.py` (seven-segment case statements),
  `scripts/img2vga.py` (image to VGA data).
