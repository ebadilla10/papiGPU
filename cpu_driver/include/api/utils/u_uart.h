#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>


/**
 * Send data via UART
 *
 * @param[in]   filestream is the UART filestream
 * @param[in]  *data       is the data to be sent
 * @param[in]   bytesize   is the bytesize of data to be sent
 * @return      0          if function was succesful
 *              errno      if function failed
 */
int u_uart_transmitter(int filestream, void *data, int bytesize);


/**
 * Waiting for and receive data via UART
 *
 * @param[in]   filestream is the UART filestream
 * @param[out] *data       is the data to be received
 * @param[in]   bytesize   is the bytesize of data to be received
 * @return      0          if function was succesful
 *              errno      if function failed
 */
int u_uart_receiver(int filestream, void *data, int bytesize);
