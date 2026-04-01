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
- Implement the full RV32I base instruction set that can run basic RISC-V assembly
- Understand the math theory behind hardware random number generation to add on a custom `RND` instruction
- Understand the impact of pipeline hazards and apply mitigation techniques
- Develop experience with the full FPGA toolchain flow (synthesis, implementation, bitstream generation) using Vivado
- Interface with FPGA peripherals, like outputing decimal numbers on a seven-segment display
- Program an assembly program that utilizes counters and the 'RND' instruction for a demo video
---

## Features
- 
- 
- 

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
