OBJ = testgp.v
OBJ1 = config_signals_gp.vcd

CC = iverilog
CC1 = vvp
VISOR = gtkwave
DEBUG = -o

TARGET = testgp.o
TARGET1 = config_signals_gp.gtkw

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
