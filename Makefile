all: compile sim
compile:
	iverilog -o test test_CPU.v
sim:
	vvp test
