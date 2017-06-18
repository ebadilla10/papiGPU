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
      fprintf (stderr, "ERROR: Unable to send data via UART. Filestream " \
               "is not valid. Error code: %d\n", filestream);
    #endif
    return filestream;
  }

  // Write in UART filestream
  status = write(filestream, data, bytesize);
  if (0 > status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to send data via UART. " \
               "Error code: %d\n", status);
    #endif
    return status;
  }

  status = 0;
  #ifdef DEBUGLOG
    fprintf (stderr, "\tSENT data via UART\n");
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
      fprintf (stderr, "ERROR: Unable to receive data via UART. Filestream " \
               "is not valid. Error code: %d\n", filestream);
    #endif
    return filestream;
  }

  // Waiting for input UART data
  while (true) {
    receiver_status = read(filestream, data, bytesize);

    if (0 > receiver_status){
      #ifdef DEBUGLOG
        fprintf (stderr, "ERROR: Unable to receive data via UART. " \
                 "Error code: %d\n", receiver_status);
      #endif
      return receiver_status;
    } else if (0 < receiver_status){
      #ifdef DEBUGLOG
        fprintf (stderr, "\tRECEIVED data via UART\n");

        uint8_t *uart;
        uart = (uint8_t*) data;
        printf("Data for UART %d %d\n", uart[0], uart[1]);
      #endif
      return status;
    }
  }

}
