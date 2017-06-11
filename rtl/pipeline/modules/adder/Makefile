inicio:
	iverilog testadder.v -o testadder.o
	vvp testadder.o
	gtkwave config_signals_adder.gtkw
clean:
	rm -rf *.vcd *.o
