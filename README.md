# Pipelined RISC-V CPU

A Verilog implementation of a pipelined RISC-V processor, organized for continued RTL development, verification, and future ASIC implementation.

## Repository Structure

```text
Pipelined-RISC-V-CPU/
├── rtl/                     # Processor, pipeline, control, and memory RTL
├── verification/
│   ├── tb.v                 # Testbench for processor instruction checks
│   └── programs/
│       └── rv32i_test.s     # Assembly test program source
├── docs/
│   └── architecture.pdf     # Architecture reference
├── rv32i_test.hex           # Instruction image loaded by instr_mem.v
├── .gitignore
└── README.md
```

## Design Overview

The design is organized as a pipelined processor with separate modules for the processor top level, datapath, controller, instruction and data memories, ALU, immediate generation, register file, pipeline registers, forwarding, hazard handling, and branch control.

### RTL Entry Points

- `rtl/pl_riscv_cpu.v` — top-level integration module, including processor and memory interfaces.
- `rtl/riscv_cpu.v` — processor core integration.
- `rtl/datapath.v` — datapath and pipeline-stage connections.
- `rtl/controller.v` — control-signal integration.
- `rtl/instr_mem.v` and `rtl/data_mem.v` — instruction and data memory models.

## Verification Assets

The repository includes a testbench and an RV32I assembly test program. The instruction memory initializes itself by reading `rv32i_test.hex`; run simulations with the repository root as the working directory so the relative file path resolves. The testbench writes `results.txt` to the simulator's current working directory.

## Future Work

- Run regression tests after RTL changes.
- Review synthesis constraints and target technology assumptions.
- Prepare ASIC synthesis and physical-design setup when the target PDK, libraries, and institutional flow are available.

**Note:** This repository contains RTL and verification assets. ASIC synthesis, physical design, and GDSII generation are future steps, not completed results.
