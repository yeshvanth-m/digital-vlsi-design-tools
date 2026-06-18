# Yosys Open Synthesis Suite — Setup & Examples

## 1. Installation (Windows — No Admin Required)

### Step 1: Get the Course Files (this repo)

The examples, testbenches, and this guide live in the GitHub repo. The large tools are **not** in the repo — you download them in the next steps.

- **Download:** Go to https://github.com/yeshvanth-m/digital-vlsi-design-tools → green **Code** button → **Download ZIP** (direct link: https://github.com/yeshvanth-m/digital-vlsi-design-tools/archive/refs/heads/main.zip)
- **Extract:** Right-click the ZIP → **Extract All**. It extracts to a folder named `digital-vlsi-design-tools-main`.
- **Rename & place:** Rename that folder to `digital-design-tools` and move it to your C drive, so the final path is `C:\digital-design-tools\`.

After this you have `C:\digital-design-tools\` containing `README.md`, `docs\`, and `examples\`. The next steps add the tool folders (`oss-cad-suite\`, `surfer\`, `graphviz\`, `skywater-pdk\`) alongside them.

> Why rename? Every command and path in this guide uses `C:\digital-design-tools\`. Keeping that exact folder name means you can copy-paste commands without edits.

### Step 2: OSS CAD Suite

Bundles **Yosys** (synthesis), **Icarus Verilog** (simulation), and **GTKWave** (waveforms).

- **Download:** https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2026-05-28/oss-cad-suite-windows-x64-20260528.exe
- **Move:** Move the downloaded `.exe` into `C:\digital-design-tools\`
- **Install:** Double-click the `.exe` → it will extract to `C:\digital-design-tools\oss-cad-suite\`
- **Open:** Double-click `C:\digital-design-tools\oss-cad-suite\start.bat`  
  A terminal opens with all tools ready. Prompt shows `[OSS CAD Suite]`.
- **Verify:** Type `yosys -V` and `iverilog -V` in that terminal.

> No Linux, no WSL, no admin privileges required.  
> For lab machines: copy the folder to a network drive; students just double-click `start.bat`.

---

### Step 3: Surfer (Waveform Viewer)

Modern waveform viewer — much cleaner than GTKWave. Reads `.vcd` files.

- **Download:** https://gitlab.com/api/v4/projects/42073614/packages/generic/surfer/v0.7.0/surfer_win_v0.7.0.zip
- **Create New Folder** Create a new folder under C:\digital-design-tools\ and name it surfer
- **Install:** Extract the zip to `C:\digital-design-tools\surfer\`
  It contains a single `surfer.exe` — no installer needed.
- **Open a waveform:** From the OSS CAD Suite terminal:
  ```
  C:\digital-design-tools\surfer\surfer.exe adder_4bit.vcd
  ```
  Or simply drag-and-drop a `.vcd` file onto `surfer.exe`.

**Key shortcuts:**

| Action | Shortcut |
|--------|----------|
| Zoom to fit | Shift+F |
| Zoom in/out | Scroll wheel |
| Go to time | Ctrl+G |
| Add marker | M |

**To view signals:** Expand the hierarchy in the left sidebar → select signals → press **+** to add them to the waveform view.

> GTKWave is still available in OSS CAD Suite if needed, but Surfer is recommended for this course.

---

### Step 4: SkyWater 130nm Standard Cell Library

Provides real cell data (area, timing) for synthesis exercises.

- **Download:** https://raw.githubusercontent.com/The-OpenROAD-Project/OpenROAD-flow-scripts/master/flow/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib  
  (Right-click → Save As, or open the URL in a browser)
- **Create New Folder** Create a new folder under C:\digital-design-tools\ and name it skywater-pdk
- **Save to:** `C:\digital-design-tools\skywater-pdk\sky130_fd_sc_hd__tt_025C_1v80.lib`
- **What it is:** Typical corner (25°C, 1.8V), 334 standard cells, ~12 MB

**Cell naming convention:**
```
sky130_fd_sc_hd__nand2_1
│       │  │  │    │    └─ drive strength (1 = minimum size)
│       │  │  │    └────── function (nand2 = 2-input NAND)
│       │  │  └─────────── density variant (hd = high density)
│       │  └────────────── standard cell
│       └───────────────── foundry digital
└───────────────────────── SkyWater 130nm process
```

---

### Step 5: Graphviz (Schematic Renderer for `yosys show`)

Yosys's `show` command writes a Graphviz `.dot` file and calls `dot` to render it into an image. OSS CAD Suite does **not** bundle Graphviz, so install this portable build to view netlists graphically.

- **Download (64-bit ZIP, no installer):** https://gitlab.com/api/v4/projects/4207231/packages/generic/graphviz-releases/15.0.0/windows_10_cmake_Release_Graphviz-15.0.0-win64.zip
- **Create New Folder** Create a new folder under C:\digital-design-tools\ and name it graphviz
- **Install:** Extract the zip so that `dot.exe` ends up at `C:\digital-design-tools\graphviz\bin\dot.exe`
- **Make Yosys find it:** add the `bin` folder to your PATH in the OSS CAD Suite terminal for the session:
  ```
  set PATH=C:\digital-design-tools\graphviz\bin;%PATH%
  ```
  (PowerShell: `$env:PATH = "C:\digital-design-tools\graphviz\bin;" + $env:PATH`)
- **Verify:** `dot -V` should print a version (e.g. `dot - graphviz version 15.0.0`).

> Alternative (no install): run `show -format dot -viewer none -prefix name` to write only the `.dot` file, then open it with the VS Code **Graphviz Interactive Preview** extension or an online viewer such as https://dreampuf.github.io/GraphvizOnline.

---

### Summary: What You Should Have After Setup

```
C:\digital-design-tools\
├── oss-cad-suite\
│   ├── start.bat              ← double-click to open tools terminal
│   ├── bin\                   ← yosys, iverilog, vvp, gtkwave, verilator
│   └── ...
├── surfer\
│   └── surfer.exe             ← waveform viewer
├── graphviz\
│   └── bin\dot.exe            ← schematic renderer for `yosys show`
└── skywater-pdk\
    └── sky130_fd_sc_hd__tt_025C_1v80.lib  ← standard cell library
```

---

## 2. Basic Yosys Commands

| Command | Purpose |
|---------|---------|
| `read_verilog file.v` | Read Verilog source |
| `synth -top module_name` | Full synthesis (elaborate → optimize → techmap → ABC) |
| `synth -top module_name -noabc` | Synthesis stopping before ABC (for manual gate mapping) |
| `abc -g AND,OR,XOR` | Map to specific gate types (textbook-friendly) |
| `abc -liberty sky130.lib` | Map to real sky130 standard cells |
| `dfflibmap -liberty sky130.lib` | Map flip-flops to sky130 sequential cells |
| `stat` | Print cell count statistics |
| `stat -liberty sky130.lib` | Print statistics with area (µm²) |
| `show` | Generate schematic diagram (needs Graphviz `dot`; use `-format svg`/`-format dot`) |
| `write_verilog netlist.v` | Export gate-level netlist |
| `clean` | Remove unused wires/cells |

### One-liner for quick synthesis:
```bash
yosys -p "read_verilog design.v; synth -top top_module; stat"
```

---

## 3. Example 1: Boolean Optimization

This demonstrates how Yosys optimizes redundant Boolean logic.

### Source: `examples/bool_optimize.v`

```verilog
// Deliberately redundant Boolean expression
// y = a & b | a & c | b & c  (majority function, 3 AND + 2 OR)
// But also: y_redundant uses extra terms that should optimize away
module bool_optimize(
  input  a, b, c,
  output y_minimal,
  output y_redundant
);

  // Minimal: majority-3
  assign y_minimal = (a & b) | (b & c) | (a & c);

  // Redundant: includes tautological and absorbed terms
  // (a & b) | (a & b & c) | (b & c) | (a & c) | (a & b & ~c & c)
  //  ^^^^^^^^^^^^^^^^^^^^^^ absorbed    ^^^^^^^^^^^^^^^^^^^^^^^^^^^ tautology (always 0)
  assign y_redundant = (a & b) | (a & b & c) | (b & c) | (a & c) | (a & b & ~c & c);

endmodule
```

### Run Synthesis:

```bash
# Synthesize to generic gates
yosys -p "read_verilog examples/bool_optimize.v; synth -top bool_optimize -noabc; abc -g AND,OR,XOR; clean; stat"
```

### Expected Result:

Both outputs should synthesize to the **same gate count** — Yosys/ABC recognizes that:
- `(a & b & c)` is absorbed by `(a & b)` (absorption law)
- `(a & b & ~c & c)` is always 0 (contradiction)

The tool eliminates redundancy automatically.

```
=== bool_optimize ===

        5 cells
        2   $_AND_
        3   $_OR_
```

Both `y_minimal` and `y_redundant` produce identical netlists after optimization.

### With SkyWater 130nm:

```bash
yosys -p "read_verilog examples/bool_optimize.v; synth -top bool_optimize; abc -liberty skywater-pdk/sky130_fd_sc_hd__tt_025C_1v80.lib; stat -liberty skywater-pdk/sky130_fd_sc_hd__tt_025C_1v80.lib"
```

The tool may pick `sky130_fd_sc_hd__maj3_1` (majority-3 gate) since this function is literally MAJ3 — one cell instead of 5 gates.

### View it graphically:

With Graphviz installed (see Setup), render a schematic with `show` (Windows: use a **backslash** in `-prefix`):

```bash
# Generic gates (5 cells) — both outputs share the same AND/OR logic
yosys -p "read_verilog examples/bool_optimize.v; synth -top bool_optimize -noabc; abc -g AND,OR,XOR; clean; show -format svg -viewer none -prefix examples\bool_optimize_show"

# SkyWater 130nm — the whole function collapses to a single maj3_1 cell
yosys -p "read_verilog examples/bool_optimize.v; synth -top bool_optimize; abc -liberty skywater-pdk/sky130_fd_sc_hd__tt_025C_1v80.lib; show -format svg -viewer none -prefix examples\bool_optimize_sky130_show"
```

Open the generated `.svg` in a browser or VS Code. The sky130 schematic clearly shows `y_minimal` and `y_redundant` driven by one `sky130_fd_sc_hd__maj3_1`.

---

## 4. Example 2: Behavioral Adder Decomposition

This shows how a simple `a + b` is decomposed into gate-level hardware.

### Source: `examples/adder_4bit.v`

```verilog
module adder_4bit(
  input  [3:0] a,
  input  [3:0] b,
  output [4:0] y
);
  assign y = a + b;
endmodule
```

### Step A: Synthesize to Generic Gates (AND/OR/XOR)

```bash
yosys -p "read_verilog examples/adder_4bit.v; synth -top adder_4bit -noabc; abc -g AND,OR,XOR; clean; stat"
```

**Expected output:**
```
=== adder_4bit ===
       17 cells
        7   $_AND_
        3   $_OR_
        7   $_XOR_
```

**Interpretation:** The `+` operator on 4-bit inputs becomes:
- 7 × XOR gates — compute sum bits
- 7 × AND gates — carry generation
- 3 × OR gates — carry propagation

Yosys internally uses a **Brent-Kung carry-lookahead** architecture (visible in synthesis log: `Using template ... _90_lcu_brent_kung`), not a naive ripple-carry.

### Step B: Synthesize to SkyWater 130nm Cells

```bash
yosys -p "read_verilog examples/adder_4bit.v; synth -top adder_4bit; dfflibmap -liberty skywater-pdk/sky130_fd_sc_hd__tt_025C_1v80.lib; abc -liberty skywater-pdk/sky130_fd_sc_hd__tt_025C_1v80.lib; stat -liberty skywater-pdk/sky130_fd_sc_hd__tt_025C_1v80.lib"
```

**Expected output:**
```
=== adder_4bit ===
       13 cells       Area: 95.09 µm²
        1   sky130_fd_sc_hd__lpflow_isobufsrc_1   (buffer)
        2   sky130_fd_sc_hd__maj3_1               (majority-3 gate)
        2   sky130_fd_sc_hd__nand2_1              (2-input NAND)
        1   sky130_fd_sc_hd__nor2_1               (2-input NOR)
        1   sky130_fd_sc_hd__o21ai_0              (OR-AND-Invert)
        5   sky130_fd_sc_hd__xnor2_1             (2-input XNOR)
        1   sky130_fd_sc_hd__xor2_1              (2-input XOR)

   Chip area for module '\adder_4bit': 95.09 µm²
```

**Key observations for students:**
1. The tool picks **complex gates** (MAJ3, OAI, XNOR) — not textbook AND/OR
2. These map efficiently to CMOS transistors (fewer transistors than AND+OR equivalent)
3. Area is now **measurable** — 95 µm² for a 4-bit adder
4. Compare: 17 generic gates vs 13 sky130 cells — real libraries have multi-input complex cells

### Step C: Export Gate-Level Netlist

```bash
yosys -p "read_verilog examples/adder_4bit.v; synth -top adder_4bit; abc -liberty skywater-pdk/sky130_fd_sc_hd__tt_025C_1v80.lib; write_verilog examples/adder_4bit_netlist.v"
```

This produces a structural Verilog file (`examples/adder_4bit_netlist.v`, ~3 KB) referencing sky130 cells — the same format sent to place & route tools.

> **If no netlist file appears:** check the synthesis log for an `ERROR`. A `-p` script stops at the **first** failed command, so if an earlier step fails (most commonly `abc -liberty` not finding the `.lib`), `write_verilog` never runs and no file is written. The `-liberty` and output paths are resolved relative to your **current working directory**, so run this from `C:\digital-design-tools\` (or adjust the paths accordingly).

### Step D: View the Netlist Graphically

With Graphviz installed (see Setup), Yosys's `show` command renders a schematic directly to SVG:

```bash
# Add Graphviz to PATH for this session (cmd):  set PATH=C:\digital-design-tools\graphviz\bin;%PATH%
yosys -p "read_verilog examples/adder_4bit.v; synth -top adder_4bit; abc -liberty skywater-pdk/sky130_fd_sc_hd__tt_025C_1v80.lib; show -format svg -viewer none -prefix examples\adder_4bit_show"
```

This writes `examples/adder_4bit_show.svg` (~55 KB), which you can open in a browser or VS Code.

> **Windows note:** use a **backslash** in `-prefix` when it includes a folder (`examples\adder_4bit_show`). Yosys finishes by running a `move` command, and Windows `move` fails on forward-slash paths with `ERROR: Shell command failed!`. A slash-free prefix (run from inside the folder) also works.

Without Graphviz, write just the `.dot` and view it elsewhere:

```bash
yosys -p "read_verilog examples/adder_4bit.v; synth -top adder_4bit; abc -liberty skywater-pdk/sky130_fd_sc_hd__tt_025C_1v80.lib; show -format dot -viewer none -prefix examples/adder_4bit_show"
```

Open `examples/adder_4bit_show.dot` with the VS Code **Graphviz Interactive Preview** extension or paste it into https://dreampuf.github.io/GraphvizOnline.

---

## 5. Example 3: Latch Inference (What NOT to Do)

### Source: `examples/latch_bad.v`

```verilog
// BAD: incomplete if-else infers a latch
module latch_bad(input a, input sel, output reg y);
  always @(*) begin
    if (sel)
      y = a;
    // MISSING: else y = ...;
  end
endmodule
```

### Run:

```bash
yosys -p "read_verilog examples/latch_bad.v; synth -top latch_bad; stat"
```

### Expected output (key lines):

```
Latch inferred for signal `\latch_bad.\y' from process ...
...
1 cells
1   $_DLATCH_P_
```

### Fixed version: `examples/latch_fixed.v`

```verilog
// GOOD: complete else branch — no latch
module latch_fixed(input a, input sel, output reg y);
  always @(*) begin
    if (sel)
      y = a;
    else
      y = 1'b0;
  end
endmodule
```

```bash
yosys -p "read_verilog examples/latch_fixed.v; synth -top latch_fixed; stat"
```

**Result:** No `$_DLATCH_P_` — just a `$_MUX_` or AND gate (pure combinational).

---

## 6. Simulation Flow (Icarus Verilog + Surfer)

### Testbench: `examples/tb_adder_4bit.v`

```verilog
module tb_adder_4bit;
  reg  [3:0] a, b;
  wire [4:0] y;

  adder_4bit dut(.a(a), .b(b), .y(y));

  integer pass_count = 0;
  integer fail_count = 0;

  task check;
    input [3:0] a_in, b_in;
    input [4:0] expected;
    begin
      a = a_in; b = b_in; #10;
      if (y !== expected) begin
        $display("FAIL: a=%d b=%d expected=%d got=%d", a_in, b_in, expected, y);
        fail_count = fail_count + 1;
      end else begin
        pass_count = pass_count + 1;
      end
    end
  endtask

  initial begin
    $dumpfile("adder_4bit.vcd");
    $dumpvars(0, tb_adder_4bit);

    check(4'd0,  4'd0,  5'd0);
    check(4'd3,  4'd5,  5'd8);
    check(4'd7,  4'd8,  5'd15);
    check(4'd15, 4'd1,  5'd16);   // carry out
    check(4'd15, 4'd15, 5'd30);   // maximum
    check(4'd9,  4'd6,  5'd15);
    check(4'd1,  4'd1,  5'd2);
    check(4'd10, 4'd5,  5'd15);

    $display("---------------------------");
    $display("Results: %0d passed, %0d failed", pass_count, fail_count);
    $display("---------------------------");

    if (fail_count == 0)
      $display("ALL TESTS PASSED");
    else
      $display("SOME TESTS FAILED");

    $finish;
  end

  initial $monitor("t=%0t a=%2d b=%2d y=%2d", $time, a, b, y);
endmodule
```

### Commands:

```bash
# Compile
iverilog -o sim.vvp examples/adder_4bit.v examples/tb_adder_4bit.v

# Simulate (generates adder_4bit.vcd)
vvp sim.vvp

# View waveforms
C:\digital-design-tools\surfer\surfer.exe adder_4bit.vcd
```

### Expected console output:

```
t=0 a= 0 b= 0 y= 0
t=10 a= 3 b= 5 y= 8
t=20 a= 7 b= 8 y=15
t=30 a=15 b= 1 y=16
t=40 a=15 b=15 y=30
t=50 a= 9 b= 6 y=15
t=60 a= 1 b= 1 y= 2
t=70 a=10 b= 5 y=15
---------------------------
Results: 8 passed, 0 failed
---------------------------
ALL TESTS PASSED
```

---

## 7. Quick Reference: Full Synthesis + Simulation Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                    DESIGN FLOW                                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Write RTL          →  design.v                              │
│  2. Write Testbench    →  tb_design.v                           │
│  3. Simulate           →  iverilog + vvp → .vcd                 │
│  4. View Waveforms     →  surfer design.vcd                     │
│  5. Synthesize         →  yosys (generic gates or sky130)       │
│  6. Read Reports       →  stat → area, cell count              │
│  7. Export Netlist     →  write_verilog netlist.v               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 8. File Organization

```
examples/
├── bool_optimize.v         # Boolean optimization demo
├── adder_4bit.v            # Behavioral adder (a + b)
├── tb_adder_4bit.v         # Adder testbench
├── latch_bad.v             # Latch inference (bad practice)
└── latch_fixed.v           # Latch fixed (good practice)
```

---

## 9. Troubleshooting

| Issue | Fix |
|-------|-----|
| `yosys: command not found` | Double-click `C:\digital-design-tools\oss-cad-suite\start.bat` first |
| Spaces in file path cause Yosys error | Copy files to a path without spaces (e.g., `C:\digital-design-tools\`) |
| `abc -g ... NOT` error | NOT is auto-included; use `abc -g AND,OR,XOR` without NOT |
| Liberty file not found | Reference the full path `skywater-pdk/sky130_fd_sc_hd__tt_025C_1v80.lib`, or copy the `.lib` into the working directory |
| `write_verilog` produces no netlist file | An earlier command failed (often `abc -liberty` not finding the `.lib`); a `-p` script aborts on the first error before reaching `write_verilog`. Fix the error and re-run. |
| `show` fails with `dot: command not found` / no image | Graphviz isn't on PATH. Install it (see Setup) and run `set PATH=C:\digital-design-tools\graphviz\bin;%PATH%`, or use `show -format dot -viewer none` and open the `.dot` elsewhere. |
| `show` fails with `ERROR: Shell command failed!` | Windows `move` rejects forward slashes. Use a backslash in `-prefix` (e.g. `-prefix examples\adder_4bit_show`) or a slash-free prefix. |
| Surfer shows empty waveform | Expand hierarchy in left panel → select signals → press **+** → **Shift+F** to zoom fit |
| Surfer flagged by Windows Defender | False positive for Rust binaries; verify with [VirusTotal](https://www.virustotal.com/) if concerned |
| GTKWave shows no signals | Click signals in left panel → "Append" → Ctrl+Shift+F to zoom fit |
