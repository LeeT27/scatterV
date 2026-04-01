**Name:** Ethan Lee  
**Education:** University of Illinois Urbana-Champaign  
**Major:** Computer Engineering  
**Graduation Date:** May 2028

March 31, 2026

# ScatterV
ScatterV is a RISC-V processor implemented in Verilog and synthesized on FPGA. It features standard functionality of a RISC-V processor and includes a custom instruction, RND, that loads a pseudorandom number to a register, utilizing primitive polynomials that define a linear feedback shift register (LFSR) to produce the longest sequence possible. Hardware level random number generation sets the foundation for applications such as cryptography, simulations, and randomized algorithms.

This repository builds upon my previous work, [learningVerilog](https://github.com/LeeT27/learningVerilog), where I created a simple processor to execute basic ALU, loads, stores, and jumps. ScatterV expands beyond this by achieving RISC-V compatibility, integrating new complex instructions, and utilizing industry-standard verification tools during the debugging process.

---
## Goals
- Understand the architecture of a RISC-V processor
- Apply the math theory behind [hardware random number generation](#) to create custom instructions
- Understand the effects of [pipeline hazards](#) and how they can be mitigated
- Build familiarity with Questasim simulation
- Learn the full [FPGA toolchain flow](#) (synthesis, implementation, bitstream generation) with Vivado
- Learn to interface with FPGA peripherals like [digit displays](#)
- Learn [RISC-V assembly](#) syntax to compile programs for processor

---

## Features
- RV32I base instruction set: arithmetic, logic, loads, stores, branches, and jumps, plus a custom `RND` instruction for pseudorandom number generation every clock cycle
- Runs standard RISC-V assembly programs with full compatibility
- Easily deployed on FPGA with Vivado's toolchain (synthesis, implementation, bitstream generation)
- Seven-segment display output: Shows decimal numbers directly from the processor
- Hazard protection using forwarding and stalling
- Demo assembly program that utilizes counters and `RND` to be displayed on FPGA

---
## Tools & Hardware

---
## Verification

---
## Demo

---
## Deep Dive Notes

---

## Challenges and Fixes

---
## Reflection

---
