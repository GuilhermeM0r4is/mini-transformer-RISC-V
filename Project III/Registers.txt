Opcode: 2 bits minimum (4 different instructions)

Register "indexes": 3 bits mininum (8 registers -> indexes 0 to 7)

---

FORMAT FOR EACH INSTRUCTION (16 bits maximum):

ADD:

[Opcode] (2 bits) | [Destination Register] (3 bits) | [Register A] (3 bits) | [8 bits trash/extra]

LOAD IMMEDIATE:

[Opcode] (2 bits) | [Destination Register] (3 bits) | [Immediate] (11 bits)

DOT:

[Opcode] (2 bits) | [Destination Register] (3 bits) | [Register A] (3 bits) | [8 bits trash/extra)

DOTA:

[Opcode] (2 bits) | [Destination Register] (3 bits) | [Register A] (3 bits) | [Register B] (3 bits) | (5 bits trash/extra)
