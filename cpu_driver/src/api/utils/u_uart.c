#include <stdio.h>
#include <stdbool.h>
#include <api/cpu_driver.h>
#include <api/utils/u_uart.h>


/**
 * Send data via UART
 */
int u_uart_transmitter(int filestream, void *data, int bytesize)
{
  int status = 0;

  // Check for valid arguments
  if (0 > filestream){
    #ifdef DEBUGLOG
    printf ("\x1B[31m" "ERROR: " "\x1B[0m" "Unable to send data via " \
            "UART. Filestream is not valid. Error code: %d\n", filestream);
    #endif
    return filestream;
  }

  // Write in UART filestream
  status = write(filestream, data, bytesize);
  if (0 > status){
    #ifdef DEBUGLOG
    printf ("\x1B[31m" "ERROR: " "\x1B[0m" "Unable to send data via " \
            "UART. Error code: %d\n", status);
    #endif
    return status;
  }

  status = 0;
  #ifdef DEBUGLOG
  printf ("\x1B[33m" "\tSENT data via UART" "\x1B[0m\n");
  #endif
  return status;
}


/**
 * Waiting for and receive data via UART
 */
int u_uart_receiver(int filestream, void *data, int bytesize)
{
  int status = 0;
  int receiver_status;

  // Check for valid arguments
  if (0 > filestream){
    #ifdef DEBUGLOG
    printf ("\x1B[31m" "ERROR: " "\x1B[0m" "Unable to receive data via " \
            "UART. Filestream is not valid. Error code: %d\n", filestream);
    #endif
    return filestream;
  }

  // Waiting for input UART data
  while (true) {
    receiver_status = read(filestream, data, bytesize);

    if (0 > receiver_status){
      #ifdef DEBUGLOG
      printf ("\x1B[31m" "ERROR: " "\x1B[0m" "Unable to receive data " \
              "via UART. Error code: %d\n", receiver_status);
      #endif
      return receiver_status;
    } else if (0 < receiver_status){
      #ifdef DEBUGLOG
      printf ("\x1B[33m" "\tRECEIVED data via UART" "\x1B[0m\n");
      #endif
      return status;
    }
  }

}
