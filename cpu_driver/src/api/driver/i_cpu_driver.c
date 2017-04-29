#include <stdio.h>
#include <errno.h>
#include <api/cpu_driver.h>
#include <api/driver/i_cpu_driver.h>

// Includes for UART comunication
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>

int i_papiGPU_initialize(gpu_portname         portname[],
                         enum papiGPU_states *state)
{

  int code_status;
  code_status = open(portname, O_RDWR | O_NOCTTY | O_NDELAY);

  if (0 <= code_status){
    *state = GPU_INITIALIZED;
    return 0;
  } else {
    #ifdef DEBUGLOG
    printf ("\x1B[31m" "ERROR: " "\x1B[0m" "Unable to open UART. " \
            "Ensure device is connected or it is not in use by " \
            "another application. Error code: %d\n", code_status);
    #endif
    *state = GPU_ERROR;
    return ENODEV;
  }

}
