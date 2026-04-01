**Name:** Ethan Lee  
**Education:** University of Illinois Urbana-Champaign  
**Major:** Computer Engineering  
**Graduation Date:** May 2028

March 31, 2026

# ScatterV
ScatterV is a custom RISC-V processor implemented in Verilog and synthesized on FPGA. It features standard functionality of a RISC-V processor and includes a custom instruction, RND, that loads a pseudorandom number to a register, utilizing primitive polynomials that define a linear feedback shift register (LFSR) to produce the longest sequence possible. Hardware level random number generation sets the foundation for applications such as cryptography, simulations, and randomized algorithms.

This repository builds upon my previous work, [learningVerilog](https://github.com/LeeT27/learningVerilog), where I created a simple processor to execute basic ALU, loads, stores, and jumps. ScatterV expands beyond this by achieving RISC-V compatibility, integrating new complex instructions, and utilizing industry-standard verification tools during the debugging process.

---
## Goals
1. Understand the architecture of a RISC-V processor
2. Apply the math theory behind [hardware random number generation](#) to create custom instructions
3. Understand the effects of [pipeline hazards](#) and how they can be mitigated
4. Build familiarity with Questasim simulation
5. Learn the full [FPGA toolchain flow](#) (synthesis, implementation, bitstream generation) with Vivado
6. Learn to interface with FPGA peripherals like [digit displays](#)
7. Learn [RISC-V assembly](#) syntax to compile programs for processor

---

## Features
- **Instruction Set:** RV32I base instructions — arithmetic, logic, loads, stores, branches, and jumps — plus a custom `RND` instruction for pseudorandom number generation every clock cycle  
- **Assembly Compatibility:** Runs standard RISC-V assembly programs with full compatibility  
- **FPGA Deployment:** Easily deployed on FPGA with Vivado's toolchain (synthesis, implementation, bitstream generation)  
- **Display Output:** Seven-segment display shows decimal numbers directly from the processor  
- **Pipeline Protection:** Hazard protection using forwarding and stalling  
- **Demo Program:** Assembly program that utilizes counters and `RND` for FPGA demo  

---
## Tools & Hardware
- **FPGA Board:** [model], seven-segment displays
- **HDL:** Verilog
- **IDE:** Visual Studio Code
- **FPGA Deployment software:** Xilinx Vivado (synthesis, implementation, bitstream generation)
- **RTL Simulation:** QuestaSim
- **Demo Program:** RISC-V assembly
  
---
## Demo

---
## Deep Dive Notes

---

## Challenges and Fixes

---
## Reflection

---
