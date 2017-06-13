inicio:
	iverilog testgp.v -o test.o
	vvp test.o
	gtkwave config_signals_gp.gtkw
clean:
	rm -rf *.vcd *.o
