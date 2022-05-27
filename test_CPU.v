`include "CPU.v"
`timescale 1ns/1ps

module test;

reg reset;

wire [31:0] registerOutput;
wire [31:0] dataAddress;
wire [2:0] flags;

CPU test_CPU (reset, registerOutput, dataAddress, flags);

initial
    begin

        #10
        reset<=0;

        #100000
        reset<=1;
        
        $finish;

    end
endmodule

/* 
iverilog.exe -o output test_CPU.v
vvp output

*/
