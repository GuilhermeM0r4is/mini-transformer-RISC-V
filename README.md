# IAC — RISC-V Mini Transformer 

A university project focused on implementing the core concepts of a **mini Transformer model using RISC-V Assembly**.

The project explores how operations commonly used in modern machine-learning architectures can be translated into low-level instructions and executed without relying on high-level machine-learning frameworks.

> **University Project — Computer Architecture and Structures**

## Overview

This repository contains the work developed throughout the IAC course, progressing from fundamental RISC-V Assembly exercises to the implementation of a small computational architecture designed around operations required by a simplified Transformer.

The final project focuses on representing Transformer-style computations at a very low level, requiring direct manipulation of:

* RISC-V registers
* Memory
* Integer arithmetic
* Matrix/vector operations
* Dot products
* Custom instruction formats
* Control flow
* Data representation

The goal was not to build a production-scale AI model, but to understand **how the computational building blocks behind a Transformer can be implemented at the assembly level**.

## Project Structure

```text
IAC/
├── Project I/
├── Project II/
├── Project III/
└── README.md
```

The repository contains the different stages of the coursework, showing the progression from basic Assembly programming towards the final implementation.

## Mini Transformer

The final stage introduces a small custom instruction set designed around the operations needed by the project.
The instruction format is limited to a maximum of **16 bits**, with fields allocated for opcodes, registers, immediates, and operation-specific data.

This required thinking about the Transformer not as a high-level Python/PyTorch model, but as a sequence of primitive operations that can ultimately be executed by a processor.

## What We Learned

This project provided practical experience with:

* **RISC-V Assembly**
* CPU registers and memory management
* Instruction encoding
* Calling conventions and control flow
* Low-level arithmetic
* Vector and matrix computations
* Dot-product operations
* Designing instructions for a specific computational workload
* Translating higher-level algorithms into Assembly
* Understanding the relationship between software and processor architecture
* Thinking about AI workloads from a hardware/architecture perspective

One of the main challenges was bridging the gap between the mathematical operations used in machine learning and the very limited primitives available at the Assembly level.

## Why a Transformer?

Transformers are normally implemented using high-level frameworks such as PyTorch or TensorFlow, where operations such as matrix multiplication and attention are abstracted away.

This project takes the opposite approach:

```text
High-level Transformer
        ↓
Mathematical operations
        ↓
Matrix / vector operations
        ↓
Primitive computational operations
        ↓
RISC-V instructions
        ↓
Assembly execution
```

This makes it possible to study what is actually happening underneath the abstractions used by modern AI software.

## Technologies

| Technology                     | Purpose                              |
| ------------------------------ | ------------------------------------ |
| **RISC-V**                     | Instruction set architecture         |
| **Assembly**                   | Implementation language              |
| **Registers & Memory**         | Data storage and manipulation        |
| **Custom Instructions**        | Specialized computational operations |
| **Matrix / Vector Operations** | Transformer-related computation      |

## Academic Context

This repository was developed as part of the **Introdução à Arquitetura de Computadores (IAC)** course.
The project was designed to combine concepts from computer architecture and Assembly programming with a modern computational workload: a simplified Transformer.

Rather than treating AI as a purely high-level software problem, the project investigates it from the perspective of **instruction execution and computer architecture**.

## Notes

This is an **educational implementation** and is intentionally much smaller and simpler than real-world Transformer architectures.
It is intended to demonstrate the underlying computational concepts and the process of translating them into low-level RISC-V Assembly.

## Authors

**Miguel Afonso** | 
**Guilherme Morais** | 
**Guilherme Rocha**

Computer Science Students
