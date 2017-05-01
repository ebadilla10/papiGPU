#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>

int u_uart_transmitter(int filestream, void *data, int bytesize);

int u_uart_receiver(int filestream, void *data, int bytesize);
