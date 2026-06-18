# Digital VLSI Design — Hands-On Tools & Examples

A beginner-friendly, **Windows + no-admin** lab kit for learning digital design with open-source tools:
**Yosys** (synthesis), **Icarus Verilog** (simulation), **Surfer/GTKWave** (waveforms), **Graphviz** (schematics), and the **SkyWater 130nm** standard-cell library.

This repo contains the exercises and guide. The tools themselves are large, so you download them separately (steps below).

---

## Quick Start (Students)

### 1. Download these course files

- Click the green **Code** button at the top of this page → **Download ZIP**
  (direct link: https://github.com/yeshvanth-m/digital-vlsi-design-tools/archive/refs/heads/main.zip)
- Right-click the downloaded ZIP → **Extract All**. You'll get a folder named `digital-vlsi-design-tools-main`.
- **Rename** that folder to `digital-design-tools` and **move it to your C drive**, so the final path is:

  ```
  C:\digital-design-tools\
  ```

  > Keep this exact name — every command in the guide uses `C:\digital-design-tools\`, so you can copy-paste without edits.

### 2. Download the tools (into the same folder)

Each tool goes into its own subfolder under `C:\digital-design-tools\`. Full download links and click-by-click steps are in the setup guide — here's the map:

| Tool | What it's for | Where it goes |
|------|---------------|---------------|
| **OSS CAD Suite** | Yosys, Icarus Verilog, GTKWave | `C:\digital-design-tools\oss-cad-suite\` |
| **Surfer** | Modern waveform viewer | `C:\digital-design-tools\surfer\` |
| **Graphviz** | Renders schematics for `yosys show` | `C:\digital-design-tools\graphviz\` |
| **SkyWater 130nm `.lib`** | Real standard-cell data (area/timing) | `C:\digital-design-tools\skywater-pdk\` |

➡️ **Follow the step-by-step instructions here:** [docs/yosys-setup-and-examples.md](docs/yosys-setup-and-examples.md)

### 3. Open the tools terminal

Double-click `C:\digital-design-tools\oss-cad-suite\start.bat` — a terminal opens with everything on the PATH. Verify:

```
yosys -V
iverilog -V
```

---

## Final Folder Layout

After setup, `C:\digital-design-tools\` should look like this:

```
C:\digital-design-tools\
├── README.md                  ← this file (from the repo)
├── docs\
│   └── yosys-setup-and-examples.md   ← full setup + examples guide
├── examples\                  ← Verilog sources & testbench (from the repo)
│   ├── bool_optimize.v
│   ├── adder_4bit.v
│   ├── tb_adder_4bit.v
│   ├── latch_bad.v
│   └── latch_fixed.v
├── oss-cad-suite\             ← downloaded (Yosys, iverilog, vvp, gtkwave)
├── surfer\                    ← downloaded (surfer.exe)
├── graphviz\                  ← downloaded (bin\dot.exe)
└── skywater-pdk\              ← downloaded (sky130_fd_sc_hd__tt_025C_1v80.lib)
```

The `README.md`, `docs\`, and `examples\` come from this repo. The four tool folders you add in Step 2.

---

## What You'll Do

From the OSS CAD Suite terminal (started in `C:\digital-design-tools\`):

- **Synthesize** Verilog to gates and real sky130 cells, and read area/cell reports (`yosys`)
- **See optimization** collapse redundant Boolean logic to a single gate
- **Simulate** a 4-bit adder testbench and generate a waveform (`iverilog` + `vvp`)
- **View waveforms** in Surfer, and **view schematics** with `yosys show` + Graphviz

Each exercise — with exact commands and expected output — is in the guide:
**[docs/yosys-setup-and-examples.md](docs/yosys-setup-and-examples.md)**

---

## Repository Contents

| Path | Description |
|------|-------------|
| [README.md](README.md) | This getting-started page |
| [docs/yosys-setup-and-examples.md](docs/yosys-setup-and-examples.md) | Full setup guide + worked examples |
| `examples/` | Verilog designs and the adder testbench |

> Generated files (`*.vcd`, `*.vvp`) are git-ignored — they're created when you run the exercises.

---

## Requirements

- Windows 10/11 (no admin rights needed)
- ~3 GB free disk space for the tools
- No Linux, WSL, or installers with admin prompts