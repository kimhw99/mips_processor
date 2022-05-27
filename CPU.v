`include "InstructionRAM.v"
`include "MainMemory.v"
`include "ALU.v"

`timescale 1ns/1ps

// 32 Bit Mux 
module mux32(inA, inB, cont, out);

    input wire [31:0] inA;
    input wire [31:0] inB;
    input wire cont;

    output wire [31:0] out;
    reg [31:0] temp;

    always @({cont,inA,inB})
        begin
            if(cont==0)
            temp <= inA;

            else if(cont==1)
            temp <= inB;
        end

    assign out = temp;
endmodule


// 5 Bit Mux
module mux5(inA, inB, cont, out);

    input wire [4:0] inA;
    input wire [4:0] inB;
    input wire cont;

    output wire [4:0] out;

    reg [4:0] temp;

    always @({cont,inA,inB})
        begin
            if(cont==0)
            temp <= inA;

            else if(cont==1)
            temp <= inB;
        end
    
    
    assign out = temp;
endmodule


// Sign Extension Module
module signExtend(in, out);

    input [15:0] in;
    output [31:0] out;
    reg [31:0] temp;

    always @(in)
        begin
            if(in[15]==1)
            temp <= 32'b1111_1111_1111_1111_0000_0000_0000_0000 + in;

            else if(in[15]==0)
            temp <= 32'b0000_0000_0000_0000_0000_0000_0000_0000 + in;
        end

        assign out = temp; // sign extend
endmodule

// Main CPU
module CPU(reset, registerOutput, dataAddress, flags);

input wire reset;

output wire [31:0] registerOutput;
output wire [31:0] dataAddress;
output wire [2:0] flags;

// Base
reg clock;
reg enable;

reg [31:0] register[31:0]; // Base Registers ($0 ~ $31)
reg [31:0] pc = 32'b0000_0000_0000_0000_0000_0000_0000_0000; 
wire [31:0] instructions; // 32 Bit Code

reg [31:0] instruction; 
reg [5:0] opcode;
reg [5:0] func;
wire [31:0] sign_Immediate;
reg [31:0] signImmediate;

integer i;
integer j;
integer k;

// Cycle 1 - Instruction Memory
InstructionRAM instructionMemory(clock, reset, enable, (pc)/4, instructions);

// Cycle 2 - Register File & Control Unit
reg [8:0] controlUnit; // In Order : RegWrite, MemtoReg, MemWrite, Branch, ALUControl (0,1,2), ALUSrcD, RegDstD
reg contJump = 0; 

reg [4:0] A1, A2, A3; // rs, rt, rf registers
reg [31:0] RD1, RD2; // Register Output

wire [4:0] outA3;
reg [31:0] jumpAddress;

mux5 muxA3(A2, A3, controlUnit[0], outA3); // Determines A3 Input for Register FIle

// Cycle 3 - ALU
wire [31:0] outMuxALU;
wire [31:0] outALU;
wire [2:0] flagsALU;

reg [31:0] muxaluOut;
reg [31:0] aluA, aluB, aluOut; // 2 ALU Inputs & 1 Output
reg [2:0] aluFlags; // ALU Flags

signExtend sign_extend(instruction[15:0], sign_Immediate);
mux32 muxALU(RD2, signImmediate, controlUnit[1], outMuxALU);
alu mipsALU(instruction, RD1, muxaluOut, outALU, flagsALU);

// Cycle 4 - Data Memory Transfer
reg [31:0] pcBranchM; // signImmediate + pc
wire [31:0] readDataW;
MainMemory dataMemory(clock, reset, enable, {2'b00 , aluOut[31:2]}, {controlUnit[6], 2'b00 , aluOut[31:2] ,RD2}, readDataW); 

// Cycle 5 - Write Data back to Register
wire [31:0] outData;
wire [31:0] outBranch;
wire [31:0] outJump;

reg [31:0] branchOut;
reg [31:0] jumpOut;

mux32 muxDataMemory(aluOut, readDataW, controlUnit[7], outData); 
mux32 muxBranch(pc, pcBranchM, {aluFlags[0] & controlUnit[5]}, outBranch); // Last 2 multiplexers determine the next PC
mux32 muxJump(branchOut, jumpAddress, contJump, outJump);

always @({enable,reset}) // Set all Registers to 0 Upon Start
    begin
        for(k=0;k<32;k=k+1)
            register[k] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
    end

always @({enable,reset})
    begin
        if(reset==0)
        begin
            for(i=0;i<10;i=i) // For loop continues the cycle
            begin
                clock <= 1;
                enable <= 1;
                
                #1 // PC is added by 4
                instruction <= instructions;
                pc <= pc + 32'b0000_0000_0000_0000_0000_0000_0000_0100;

                #1 // Opcode & Function Code is Established
                opcode <= instruction[31:26];
                func <= instruction[5:0];

                #1 // Control Unit Tabs are Established depending on the Instruction Type
                if(opcode==6'b000000 & func!=6'b001000)
                begin
                    controlUnit = 10'b1000_010_01; // R Type
                end

                else if(opcode==6'b001000 || opcode==6'b001001 || opcode==6'b001100 || opcode==6'b001101 || opcode==6'b001110 || opcode==6'b001010 || opcode==6'b001011 || opcode==6'b001111) 
                begin
                    controlUnit=10'b1000_000_10; // Major I Types
                end

                else if(opcode==6'b000010 || opcode==6'b000011 || {opcode,func}==12'b000000_001000)
                begin
                    controlUnit=10'b0000_000_00; // Jump(j , jal) 
                    contJump = 1;
                    jumpAddress <= {instruction[25:0],2'b00};

                    if(opcode==6'b000011) // jal
                        begin
                            register[31]<=pc;
                        end
                end

                else if(opcode==6'b000100 || opcode==6'b000001 || opcode==6'b000111 || opcode==6'b000110 || opcode==6'b000001 || opcode==6'b000101)
                begin
                    controlUnit=10'b0001_001_00; // Branch
                end

                else if(opcode==6'b100011 || opcode==6'b100101 || opcode==6'b100001 || opcode==6'b100100 || opcode==6'b100000 || opcode==6'b100010 || opcode==6'b100110)
                begin
                    controlUnit=10'b1100_000_10; // Load
                end

                else if(opcode==6'b101011 || opcode==6'b101001 || opcode==6'b101000 || opcode==6'b101010 || opcode==6'b101110)
                begin
                    controlUnit=10'b0010_000_10; // Store
                end

                // 10 bit Control Unit In Order : RegWrite, MemtoReg, MemWrite, Branch, ALUControl (0,1,2), ALUSrcD, RegDstD
                // Additional Jump Unit is included

                
                #1 // Register Address is established
                A1 <= instruction[25:21];
                A2 <= instruction[20:16];
                A3 <= instruction[15:11];

                #1 // Real Register Address (A3 is reestablished through multiplexer between A2 and A3)
                A3 <= outA3;
                
                #1 // Register Data Output
                RD1 <= register[A1];
                RD2 <= register[A2];

                #1 // Jump Register, second input of ALU is determined through the multiplexer before the ALU
                muxaluOut<=outMuxALU;

                if({opcode,func}==12'b000000_001000) //jr instructions activates here if appropriate
                    jumpAddress <= RD1;

                #1 // ALU Output (ALU Flags and Outputs are Determined)
                aluOut <= outALU;
                aluFlags <= flagsALU;

                #1 // 16-bit Immediate Sign Extension
                signImmediate <= sign_Immediate;
                
                #1 // Branch Address
                pcBranchM <= (signImmediate<<2) + pc;
                clock<=0;

                #1 // Triggers Clock for Memory
                clock<=1;

                #1 // Write to Memory (If Declared)
                if(controlUnit[8]==1'b1)
                    register[A3] <= outData;

                #1 // Determine New PC (Branch)
                branchOut <= outBranch;
                clock<=0;

                #1 // Determine New PC (Jump)
                pc <= outJump;
                contJump = 0;

                #1 // End CPU (When input is a row of 1's)
                if(instructions==32'b1111_1111_1111_1111_1111_1111_1111_1111)
                    i=100;
            end

            // Display Main Memory on the Console
            $display("-------------Memory-------------");

            for(j=0;j<512;j=j+1)
                $display("%b",dataMemory.DATA_RAM[j]);

            $display("--------------------------------");
        end
        else if(reset==1) // Reset the CPU (If Declared)
        begin
            pc<=32'b0000_0000_0000_0000_0000_0000_0000_0000;

            for(k=0;k<32;k=k+1)
                register[k] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;

            for(k=0;k<512;k=k+1)
                dataMemory.DATA_RAM[k] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
        end
    end
endmodule

/* 
iverilog.exe -o output CPU.v 
vvp out

*/
