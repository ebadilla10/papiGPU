inicio:
	iverilog testdivider.v -o testdivider.o
	vvp testdivider.o
	gtkwave config_signals_divider.gtkw
clean:
	rm -rf *.vcd *.o
