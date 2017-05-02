#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>


/*******************
  Send data via UART

INPUT   filestream is the UART filestream
INPUT  *data       is the data to be sent
INPUT   bytesize   is the bytesize of data to be sent
RETURN  0          if function was succesful
        errno      if function failed
*******************/
int u_uart_transmitter(int filestream, void *data, int bytesize);


/**************************************
  Waiting for and receive data via UART

INPUT   filestream is the UART filestream
OUTPUT *data       is the data to be received
INPUT   bytesize   is the bytesize of data to be received
RETURN  0          if function was succesful
        errno      if function failed
**************************************/
int u_uart_receiver(int filestream, void *data, int bytesize);
