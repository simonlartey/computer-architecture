# Computer Architecture

<p align="center">
  <b>CS232 Computer Architecture </b><br>
    A project sequence in digital logic, VHDL simulation, processor architecture, memory systems, CPU design, and assembler implementation.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Language-VHDL-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Language-Python-yellow?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Tool-Quartus%20II-purple?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Tool-GHDL-green?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Tool-GTKWave-orange?style=for-the-badge" />
</p>

---

## Course Description

Computer organization focuses on how computers work. This course explores the fundamental hardware components of computers, including memory, input/output, and most importantly the processor. The projects in this repository move across several levels of abstraction, from basic digital logic and electrical component behavior to machine-language execution and assembly programming.

A major goal of the course is to understand how the internal components of a computer are designed, built, and connected so that they work together as a single machine.

---

## Repository Overview

This repository documents a full computer architecture project sequence that progresses from basic digital logic to a working CPU and assembler toolchain.

Rather than focusing only on isolated hardware exercises, the projects build toward a complete understanding of how computation is implemented at the hardware level. The work includes combinational logic circuits, finite-state machines, ROM-controlled processors, stack-based computation, RAM/ROM memory systems, a custom ALU, a CPU datapath and control unit, assembly programs, and Python-based assembler tooling.

This repository documents the design and simulation of a simplified computing system from the gate/control level through machine-code execution.

### The repository includes:

- VHDL hardware modules
- Quartus schematic and project files
- Finite-state machine designs
- ROM-controlled programmable systems
- RAM-backed stack structures
- ALU and CPU implementations
- Program ROM and Data RAM modules
- Simulation testbenches
- GHDL/GTKWave waveform outputs
- Memory initialization files
- Assembly programs
- Python assembler and syntax-checking tools

---
## Core Engineering Concepts

| Area | Topics |
|---|---|
| Digital Systems Design | Boolean logic, counters, registers, multiplexing, finite-state machines |
| Hardware Description | VHDL modules, component wiring, signal control, synchronous design |
| Processor Architecture | ALU design, CPU datapath, control unit FSM, instruction fetch/decode/execute cycle |
| Memory Systems | RAM, ROM, stack storage, memory initialization files, program/data separation |
| Instruction Set Design | Custom instruction encodings, branching, stack operations, call/return, input/output |
| Simulation & Debugging | VHDL testbenches, GHDL simulation, GTKWave waveform analysis, `.vcd` inspection |
| Systems Tooling | Python assembler, syntax checker, `.mif` generator, assembly-to-machine-code workflow |
| Low-Level Programming | Assembly programs, labels, loops, recursive calls, stack-based function behavior |
| Engineering Practice | Modular design, progressive extensions, test programs, structured Git history |

---

## Labs and Projects

| Module | Topic | Description |
|---|---|---|
| Lab 1 | Wires and Circuits | Basic Boolean logic circuit design and simulation |
| Project 1 | Prime Traffic | Prime detector and traffic light controller |
| Project 2 | Double Sevens | Seven-segment displays, counters, and arithmetic logic |
| Project 3 | Reaction Timer | FSM-based reaction timer with extension features |
| Project 4 | Programmable Lights | ROM-controlled programmable LED system |
| Project 5 | Programmable Lights II | Processor-style programmable light display |
| Project 6 | 4-Function Calculator | Stack-based calculator using RAM-backed storage |
| Project 7 | RISC CPU | ALU, memory, CPU datapath, stack, branching, and call/return |
| Project 8 | Assembler | Two-pass assembler and assembly programs for CPU testing |

---

## Clean Project Structure

```text
.
├── CS3232_lab1
│   ├── circuit1.bdf
│   ├── circuit1.vhd
│   └── testbench.vhd
├── Project1_slarte27
│   ├── CS_252_Report (1).pdf
│   ├── extensions
│   │   └── prime_5bit
│   │       ├── prime.qpf
│   │       ├── prime.qsf
│   │       ├── prime_5bit.bdf
│   │       ├── prime_5bit.vhd
│   │       └── testbench.vhd
│   ├── prime
│   │   ├── prime.bdf
│   │   ├── prime.qpf
│   │   ├── prime.qsf
│   │   ├── prime.vhd
│   │   └── testbench.vhd
│   └── traffic
│       ├── counter.vhd
│       ├── traffic.bdf
│       ├── traffic.qpf
│       ├── traffic.qsf
│       ├── traffic.vhd
│       └── trafficbench.vhd
├── Project2_slarte27
│   ├── CS232  Project 2 Report.docx
│   ├── extension
│   │   └── task2_extension.vhd
│   ├── task1
│   │   ├── hexdisplay.vhd
│   │   ├── lpm_counter0.vhd
│   │   └── task1_top.bdf
│   └── task2
│       └── task2.vhd
├── Project3_slarte27
│   ├── CS232_Project3_Report.docx
│   ├── extensions
│   │   ├── hexdisplay.vhd
│   │   ├── reaction.bdf
│   │   ├── reaction.qpf
│   │   └── timer.vhd
│   └── task1
│       ├── hexdisplay.vhd
│       ├── reaction.bdf
│       ├── reaction.qpf
│       ├── reaction_test.vhd
│       └── timer.vhd
├── Project4_slarte27
│   ├── CS232_project4_report.docx
│   ├── extensions
│   │   ├── larger_program
│   │   │   ├── lightrom_extended.vhd
│   │   │   └── lights_extended.vhd
│   │   └── lights_custom_display
│   │       ├── hexdisplay.vhd
│   │       ├── light_pattern_1.vhd
│   │       ├── light_pattern_2.vhd
│   │       ├── lightrom.vhd
│   │       ├── lightrom_extended.vhd
│   │       └── lights_runtime_display_top.vhd
├── Project5_slarte27
│   ├── pld2.vhd
│   ├── pldbench.vhd
│   ├── pldrom.vhd
│   ├── pldrom_extension_bounce.vhd
│   ├── pldrom_extension_growing_bar.vhd
│   ├── pldrom_extension_longer_program.vhd
│   ├── pldrom_program8.vhd
│   ├── pldrom_program9.vhd
│   ├── pldrom_test1.vhd
│   ├── pldrom_test2.vhd
│   └── slarte27_Project5_report.docx
├── Project6_slarte27
│   ├── CS232._project6_report .docx
│   ├── calculator.vhd
│   ├── hexdisplay.vhd
│   ├── memram.vhd
│   ├── project6_extension
│   │   ├── calculator.vhd
│   │   ├── hexdisplay.vhd
│   │   └── memram.vhd
│   └── stacker.vhd
├── Project7_slarte27
│   ├── CS232_Project_7_Report.docx
│   ├── DataRAM.vhd
│   ├── ProgramROM.vhd
│   ├── alu.vhd
│   ├── alutestbench.vhd
│   ├── cpu.vhd
│   ├── cpubench.vhd
│   ├── data.mif
│   ├── extension
│   │   ├── DataRAM.vhd
│   │   ├── ProgramROM.vhd
│   │   ├── alu.vhd
│   │   ├── cpu.vhd
│   │   ├── cpubench.vhd
│   │   ├── data.mif
│   │   ├── mif_generator
│   │   │   ├── mif_generator.py
│   │   │   ├── sample_input.mif
│   │   │   └── sample_input.txt
│   │   ├── program.mif
│   │   ├── testmultiply.mif
│   │   └── testsquare.mif
│   ├── fibonacci.mif
│   ├── program.mif
│   ├── testcall.mif
│   └── testpush.mif
├── Project8_slarte27
│   ├── CS232_Project8_Report.docx
│   ├── assembler.py
│   ├── assembler_error_checker.py
│   ├── assembler_ext2.py
│   ├── cpu
│   │   ├── DataRAM.vhd
│   │   ├── ProgramROM.vhd
│   │   ├── alu.vhd
│   │   ├── cpu.vhd
│   │   ├── cpubench.vcd
│   │   ├── cpubench.vhd
│   │   ├── data.mif
│   │   └── program.mif
│   └── programs
│       ├── fib.a
│       ├── recursive_sum.a
│       ├── test.a
│       ├── test_arithmetic.a
│       ├── test_errors.a
│       ├── test_function_args.a
│       ├── test_loop.a
│       └── test_stack.a
└── README.md