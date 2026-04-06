**Name:** Ethan Lee  
**Education:** University of Illinois Urbana-Champaign  
**Major:** Computer Engineering  
**Graduation Date:** May 2028

March 31, 2026

# ScatterV
ScatterV is a custom RISC-V processor implemented in SystemVerilog and synthesized on FPGA. It features standard functionality of a RISC-V processor and includes a custom instruction, `RND`, which loads a pseudorandom number into a register using a linear feedback shift register (LFSR) to produce maximal-length sequences. Hardware level random number generation sets the foundation for applications such as cryptography, simulations, and randomized algorithms.

This repository builds upon my previous work, [learningVerilog](https://github.com/LeeT27/learningVerilog), where I created a simple processor to execute basic ALU, loads, stores, and jumps. ScatterV expands beyond this by achieving RISC-V compatibility, integrating new complex instructions, and utilizing industry-standard verification tools during the debugging process. Each of the goals outlined below is linked to a detailed deep dive writeup, providing visuals, code examples, and explanations that show how these objectives were achieved.

---
## Goals
1. Understand the architecture of a RISC-V processor ([Learn more](#risc-v-architecture))
2. Apply the math theory behind hardware random number generation to create custom instructions ([Learn more](#rnd-instruction-implementation))
3. Understand the effects of pipeline hazards and how they can be mitigated ([Learn more](#pipeline-hazards))
4. Build familiarity with Questasim simulation ([Learn more](#rtl-verification))
5. Learn the full FPGA toolchain flow (synthesis, implementation, bitstream generation) with Vivado ([Learn more](#fpga-synthesis))
6. Learn to interface with FPGA peripherals like digit displays ([Learn more](#digit-display))
7. Learn RISC-V assembly syntax to compile programs for processor ([Learn more](#risc-v-assembly))

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
- **FPGA Board:** RealDigital Boolean Board (Xilinx Spartan-7 XC7S50), seven-segment displays
- **HDL:** SystemVerilog
- **IDE:** Visual Studio Code
- **FPGA Deployment software:** Xilinx Vivado (synthesis, implementation, bitstream generation)
- **RTL Simulation:** QuestaSim
- **Demo Program:** RISC-V assembly
  
---
## Demo

---
## Deep Dive Notes
### RISC-V Architecture
hullo
### `RND` Instruction Implementation
hullo
### Pipeline Hazards
hullo
### RTL Verification
hullo
### FPGA Synthesis
hullo
### Digit Display
hullo
### RISC-V Assembly
hullo

---

## Challenges and Fixes

---
## Reflection

---
