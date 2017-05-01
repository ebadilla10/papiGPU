#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <api/cpu_driver.h>
#include <api/driver/i_cpu_driver.h>
#include <api/utils/u_ieee754.h>
#include <api/mem/papiGPU_memory.h>

// Includes for UART comunication
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>

// Allowed pre-states for each state
#define INITIALIZED_PS        1 << GPU_ERROR
#define CAMERA_CREATE_PS      1 << GPU_INITIALIZED
#define OBJECT_CREATE_PS      1 << GPU_CAMARA_CREATED
#define VERTEX_INSERT_PS      1 << GPU_OBJECT_CREATED  | \
                              1 << GPU_VERTEX_INSERTED
#define OBJECT_CLOSE_PS       1 << GPU_VERTEX_INSERTED
#define OBJ_TMATRIX_CHANGE_PS 1 << GPU_OBJECT_CREATED  | \
                              1 << GPU_VERTEX_INSERTED | \
                              1 << GPU_OBJECT_CLOSED
#define REFRESH_PS            1 << GPU_OBJECT_CLOSED

#define UART_SENT

// Status of the UART filestream
int stream_status;

static int uart_transmitter(void *data, int bytesize){
  int status = 0;

  if (0 > stream_status){
    #ifdef DEBUGLOG
    printf ("\x1B[31m" "ERROR: " "\x1B[0m" "Unable to send data via " \
            "UART. Filestream is not valid. Error code: %d\n", stream_status);
    #endif
    return stream_status;
  }

  status = write(stream_status, data, bytesize);
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

static int uart_receiver(void *data, int bytesize){
  int status = 0;
  int receiver_status;

  if (0 > stream_status){
    #ifdef DEBUGLOG
    printf ("\x1B[31m" "ERROR: " "\x1B[0m" "Unable to receive data via " \
            "UART. Filestream is not valid. Error code: %d\n", stream_status);
    #endif
    return stream_status;
  }

  while (true) {
    receiver_status = read(stream_status, data, bytesize);

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

int i_papiGPU_initialize(gpu_portname         portname[],
                         enum papiGPU_states *state)
{
  int status = 0;
  struct termios uart_options = {0};
  uint16_t mem_valid_tag;
  unsigned char *mem_valid_tag_str;
  unsigned char *str_to_compare;

  mem_valid_tag_str = (char *) malloc(sizeof(uint16_t));
  str_to_compare = (char *) malloc(sizeof(uint16_t));

  if (!((1 << *state) & INITIALIZED_PS)){
    #ifdef DEBUGLOG
    printf ("\x1B[31m" "ERROR: " "\x1B[0m" "Unable to initialize the " \
            "GPU. Check it is not already initialized. Error code: " \
            "%d\n", EPERM);
    #endif
    // No change the state
    return EPERM;
  }

  stream_status = open(portname, O_RDWR | O_NOCTTY | O_SYNC);

  if (0 > stream_status){
    #ifdef DEBUGLOG
    printf ("\x1B[31m" "ERROR: " "\x1B[0m" "Unable to open UART. " \
            "Ensure device is connected or it is not in use by " \
            "another application. Error code: %d\n", stream_status);
    #endif
    *state = GPU_ERROR;
    return stream_status;
  }

  status = tcgetattr(stream_status, &uart_options);
  if (status){
    #ifdef DEBUGLOG
    printf ("\x1B[31m" "ERROR: " "\x1B[0m" "Unable to get the parameters " \
            "associated with the terminal. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  uart_options.c_cflag = B9600 | CS8 | CLOCAL | CREAD;
	uart_options.c_iflag = IGNPAR;
	uart_options.c_oflag = 0;
	uart_options.c_lflag = 0;

  status = tcflush(stream_status, TCIOFLUSH);
  if (status){
    #ifdef DEBUGLOG
    printf ("\x1B[31m" "ERROR: " "\x1B[0m" "Unable to set the flash " \
            "the output/input data. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = tcsetattr(stream_status, TCSANOW, &uart_options);
  if (status){
    #ifdef DEBUGLOG
    printf ("\x1B[31m" "ERROR: " "\x1B[0m" "Unable to set the parameters " \
            "associated with the terminal. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  mem_valid_tag = REQUEST_VALID_TAG;
  status = u_half_prec_to_string(mem_valid_tag, mem_valid_tag_str);
  if (status){
    #ifdef DEBUGLOG
    printf ("\x1B[31m" "ERROR: " "\x1B[0m" "Unable to convert the " \
    "request valid tag to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = uart_transmitter((void*) mem_valid_tag_str, sizeof(uint16_t));
  if (status){
    *state = GPU_ERROR;
    return status;
  }

  #ifdef UART_SENT
  mem_valid_tag = APPROVAL_VALID_TAG;
  status = u_half_prec_to_string(mem_valid_tag, str_to_compare);
  if (status){
    #ifdef DEBUGLOG
    printf ("\x1B[31m" "ERROR: " "\x1B[0m" "Unable to convert the " \
    "approval valid tag to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = uart_receiver((void*) mem_valid_tag_str, sizeof(uint16_t));
  if (status){
    *state = GPU_ERROR;
    return status;
  }

  status = memcmp(str_to_compare, mem_valid_tag_str, sizeof(uint16_t));
  if (status){
    #ifdef DEBUGLOG
    printf ("\x1B[31m" "ERROR: " "\x1B[0m" "UART approval tag is not " \
            "valid. Error code: %d\n", EIO);
    #endif
    *state = GPU_ERROR;
    return EIO;
  }
  #endif // UART_SENT

  return status;
}

int i_papiGPU_create_camara(struct papiGPU_vertex  cam_vertex,
                            gpu_focal_point        fp_distance,
                            enum papiGPU_states   *state)
{
  return 0;
}
