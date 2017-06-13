OBJ = testmultiplier.v
OBJ1 = config_signals_multiplier.vcd

CC = iverilog
CC1 = vvp
VISOR = gtkwave
DEBUG = -o

TARGET = testmultiplier.o
TARGET1 = config_signals_multiplier.gtkw

all:   $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $(OBJ) $(DEBUG) $(TARGET)
	$(CC1) $(TARGET)

look:
	$(VISOR) $(TARGET1)

values: 
	$(CC1) $(TARGET)

clean:
	rm -f -R *.o *.vcd
