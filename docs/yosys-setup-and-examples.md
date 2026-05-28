# Yosys Open Synthesis Suite — Setup & Examples

## 1. Installation (Windows — No Admin Required)

### Download OSS CAD Suite

The OSS CAD Suite bundles **Yosys** (synthesis), **Icarus Verilog** (simulation), and **GTKWave** (waveform viewer) into a single package. We also use **Surfer** — a modern waveform viewer with a far cleaner UI than GTKWave.

1. Download the latest Windows release from:  
   https://github.com/YosysHQ/oss-cad-suite-build/releases  
   File: `oss-cad-suite-windows-x64-YYYYMMDD.exe` (~316 MB)

2. Run the self-extracting archive — extract to `C:\oss-cad-suite\`

3. Open PowerShell and activate the environment:
   ```powershell
   . "C:\oss-cad-suite\oss-cad-suite\environment.ps1"
   ```

4. Verify installation:
   ```powershell
   yosys -V        # Should show: Yosys 0.65+
   iverilog -V     # Should show: Icarus Verilog version 14.x
   ```

> **No Linux, no WSL, no admin privileges required.**  
> For lab machines: copy the extracted folder to a network drive; students just run `start.bat`.

### Download Surfer (Waveform Viewer)

Surfer is a modern, GPU-accelerated waveform viewer that reads `.vcd` files. It replaces GTKWave for a much better experience.

1. Download the latest Windows binary from:  
   https://gitlab.com/surfer-project/surfer/-/releases  
   File: `surfer_win_v0.7.0.zip` (~40 MB)

   Or use the direct link for the latest build:
   ```powershell
   $surferUrl = "https://gitlab.com/api/v4/projects/42073614/jobs/artifacts/main/raw/surfer_win.zip?job=windows_build"
   Invoke-WebRequest -Uri $surferUrl -OutFile "C:\oss-cad-suite\surfer_win.zip" -UseBasicParsing
   ```

2. Extract to `C:\oss-cad-suite\surfer\`:
   ```powershell
   Expand-Archive -Path "C:\oss-cad-suite\surfer_win.zip" -DestinationPath "C:\oss-cad-suite\surfer" -Force
   ```

3. (Optional) Add to PATH or create a shortcut:
   ```powershell
   $env:PATH += ";C:\oss-cad-suite\surfer"
   ```

4. Open a VCD file:
   ```powershell
   surfer.exe waveform.vcd
   ```

**Key Surfer shortcuts:**
| Action | Shortcut |
|--------|----------|
| Zoom to fit | Shift+F |
| Zoom in/out | Scroll wheel |
| Go to time | Ctrl+G |
| Add marker | M |
| Add divider | D |

**Why Surfer over GTKWave:**
- Modern dark/light themes, smooth rendering
- Bus values displayed inline on waveforms
- Drag-and-drop signal reordering
- No DPI/scaling issues on high-res displays
- Standalone binary — no install needed

> GTKWave is still included in OSS CAD Suite if you prefer it, but Surfer is recommended for this course.

---

## 2. SkyWater 130nm PDK Setup

The SkyWater 130nm PDK provides real standard cell libraries (liberty `.lib` files) with timing and area data.

### Download the Liberty File

```powershell
$libUrl = "https://raw.githubusercontent.com/The-OpenROAD-Project/OpenROAD-flow-scripts/master/flow/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
Invoke-WebRequest -Uri $libUrl -OutFile "C:\oss-cad-suite\sky130_fd_sc_hd__tt_025C_1v80.lib" -UseBasicParsing
```

This gives you `sky130_fd_sc_hd__tt_025C_1v80.lib` (~12 MB) — the typical-typical corner (25°C, 1.8V) of the high-density standard cell library with 334 cells.

### Cell Naming Convention

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

## 3. Basic Yosys Commands

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
| `show` | Generate schematic diagram (opens graphviz viewer) |
| `write_verilog netlist.v` | Export gate-level netlist |
| `clean` | Remove unused wires/cells |

### One-liner for quick synthesis:
```bash
yosys -p "read_verilog design.v; synth -top top_module; stat"
```

---

## 4. Example 1: Boolean Optimization

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
   Number of cells:  10
     $_AND_:  6
     $_OR_:   4
```

Both `y_minimal` and `y_redundant` produce identical netlists after optimization.

### With SkyWater 130nm:

```bash
yosys -p "read_verilog examples/bool_optimize.v; synth -top bool_optimize; abc -liberty sky130_fd_sc_hd__tt_025C_1v80.lib; stat -liberty sky130_fd_sc_hd__tt_025C_1v80.lib"
```

The tool may pick `sky130_fd_sc_hd__maj3_1` (majority-3 gate) since this function is literally MAJ3 — one cell instead of 5 gates.

---

## 5. Example 2: Behavioral Adder Decomposition

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
yosys -p "read_verilog examples/adder_4bit.v; synth -top adder_4bit; dfflibmap -liberty sky130_fd_sc_hd__tt_025C_1v80.lib; abc -liberty sky130_fd_sc_hd__tt_025C_1v80.lib; stat -liberty sky130_fd_sc_hd__tt_025C_1v80.lib"
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
yosys -p "read_verilog examples/adder_4bit.v; synth -top adder_4bit; abc -liberty sky130_fd_sc_hd__tt_025C_1v80.lib; write_verilog examples/adder_4bit_netlist.v"
```

This produces a structural Verilog file referencing sky130 cells — the same format sent to place & route tools.

---

## 6. Example 3: Latch Inference (What NOT to Do)

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

## 7. Simulation Flow (Icarus Verilog + GTKWave)

### Testbench: `examples/tb_adder_4bit.v`

```verilog
module tb_adder_4bit;
  reg  [3:0] a, b;
  wire [4:0] y;

  adder_4bit dut(.a(a), .b(b), .y(y));

  initial begin
    $dumpfile("adder_4bit.vcd");
    $dumpvars(0, tb_adder_4bit);

    a = 4'd0;  b = 4'd0;  #10;
    a = 4'd3;  b = 4'd5;  #10;
    a = 4'd7;  b = 4'd8;  #10;
    a = 4'd15; b = 4'd1;  #10;
    a = 4'd15; b = 4'd15; #10;
    a = 4'd9;  b = 4'd6;  #10;

    $display("All tests passed.");
    $finish;
  end

  initial $monitor("t=%0t a=%d b=%d y=%d", $time, a, b, y);
endmodule
```

### Commands:

```bash
# Compile
iverilog -o sim.vvp examples/adder_4bit.v examples/tb_adder_4bit.v

# Simulate (generates adder_4bit.vcd)
vvp sim.vvp

# View waveforms (Surfer — recommended)
C:\oss-cad-suite\surfer\surfer.exe adder_4bit.vcd

# Or if surfer is in PATH:
surfer.exe adder_4bit.vcd

# Alternative: GTKWave (bundled with OSS CAD Suite)
gtkwave adder_4bit.vcd
```

**Using Surfer:**
1. Expand the hierarchy in the left sidebar (`tb_adder_4bit`)
2. Click signals (`a`, `b`, `y`) or select all and press **+** to add to waveform
3. Press **Shift+F** to zoom to fit all transitions
4. Scroll to zoom, click to place cursor, read values at cursor position

### Expected console output:

```
t=0 a= 0 b= 0 y= 0
t=10 a= 3 b= 5 y= 8
t=20 a= 7 b= 8 y=15
t=30 a=15 b= 1 y=16
t=40 a=15 b=15 y=30
t=50 a= 9 b= 6 y=15
All tests passed.
```

---

## 8. Quick Reference: Full Synthesis + Simulation Workflow

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

## 9. File Organization

```
examples/
├── bool_optimize.v         # Boolean optimization demo
├── adder_4bit.v            # Behavioral adder (a + b)
├── tb_adder_4bit.v         # Adder testbench
├── latch_bad.v             # Latch inference (bad practice)
└── latch_fixed.v           # Latch fixed (good practice)
```

---

## 10. Troubleshooting

| Issue | Fix |
|-------|-----|
| `yosys: command not found` | Run `. "C:\oss-cad-suite\oss-cad-suite\environment.ps1"` first |
| Spaces in file path cause Yosys error | Copy files to a path without spaces (e.g., `C:\oss-cad-suite\`) |
| `abc -g ... NOT` error | NOT is auto-included; use `abc -g AND,OR,XOR` without NOT |
| Liberty file not found | Ensure `sky130_fd_sc_hd__tt_025C_1v80.lib` is in the working directory |
| Surfer shows empty waveform | Expand hierarchy in left panel → select signals → press **+** → **Shift+F** to zoom fit |
| Surfer flagged by Windows Defender | False positive for Rust binaries; verify with [VirusTotal](https://www.virustotal.com/) if concerned |
| GTKWave shows no signals | Click signals in left panel → "Append" → Ctrl+Shift+F to zoom fit |
