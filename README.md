This is an implementation of a simplified 5-stage pipelined CPU using Verilog.
The code was originally made for a school assignment, which provided "InstructionRAM.v" and "MainMemory.v".

The code supports the follwing instructions:
- lw, sw
- add, addu, addi, addiu, sub, subu
- and, andi, nor, or, ori, xor, xori
- sll, sllv, srl, srlv, sra, srav
- beq, bne, slt
- j, jr, jal

"instruction.bin" contains the 32-bit machine code to be read by "test_CPU.v" and the program ends when the CPU executes 32'hffffffff.
The output will be the state of the main memory after the machine code has been compiled.
