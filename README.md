# mips--processor-pipelined-in-5-stages
"I designed and implemented a simplified pipelined MIPS processor in Verilog as part of my learning journey in RTL design. 🚀

# MIPS Pipelined Processor (Verilog)

## Project Description
This project implements a simplified MIPS-style pipelined processor using Verilog HDL.  
The processor executes instructions through multiple pipeline stages and demonstrates the basic concepts of processor architecture and RTL design.

The design was implemented and verified using simulation tools.

---

## Architecture Overview

The processor is implemented with a pipelined architecture consisting of the following stages:

1. Instruction Fetch (IF)
2. Instruction Decode (ID)
3. Execute (EX)
4. Memory Access (MEM)
5. Write Back (WB)

Pipeline registers are used between stages to store intermediate values.

---

## Main Components

### Program Counter
- Maintains the address of the next instruction
- Supports sequential execution and jump operations

### Instruction Memory
- Stores instructions
- Instructions are fetched using the program counter

### Decoder
- Extracts opcode and register fields from instructions

### Register File
- Stores processor registers
- Provides operands to the ALU
- Supports write-back operations

### ALU (Arithmetic Logic Unit)
Performs arithmetic and logic operations:

| Opcode | Operation |
|------|-----------|
| 00 | Addition |
| 01 | Multiplication |
| 10 | Subtraction |
| 11 | Division |

### Sign Extension
Extends immediate values to match operand width.

### Data Memory
- Supports memory read and write operations
- Used during the MEM pipeline stage

### Multiplexers
Used to select between multiple data sources during pipeline execution.

---

## Pipeline Registers

Intermediate registers store values between stages:

- IF/ID
- ID/EX
- EX/MEM
- MEM/WB

These registers allow multiple instructions to execute simultaneously in different pipeline stages.


## these are the some snipptes



<img width="1867" height="810" alt="Image" src="https://github.com/user-attachments/assets/bda6a4cf-925f-48de-b785-9888831cc269" />




<img width="828" height="542" alt="Image" src="https://github.com/user-attachments/assets/048e522a-cc0d-477f-a182-cf0e3117dce2" />
