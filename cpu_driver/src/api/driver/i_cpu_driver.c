#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <api/cpu_driver.h>
#include <api/driver/i_cpu_driver.h>
#include <api/utils/u_ieee754.h>
#include <api/mem/papiGPU_memory.h>
#include <api/utils/u_uart.h>

/** Allowed pre-states for each state */
#define INITIALIZED_PS        1 << GPU_ERROR
#define CAMERA_CREATE_PS      1 << GPU_INITIALIZED
#define OBJECT_CREATE_PS      1 << GPU_CAMERA_CREATED
#define VERTEX_INSERT_PS      1 << GPU_OBJECT_CREATED  | \
                              1 << GPU_VERTEX_INSERTED
#define OBJECT_CLOSE_PS       1 << GPU_VERTEX_INSERTED
#define OBJ_TMATRIX_CHANGE_PS 1 << GPU_OBJECT_CREATED  | \
                              1 << GPU_VERTEX_INSERTED | \
                              1 << GPU_OBJECT_CLOSED
#define REFRESH_PS            1 << GPU_OBJECT_CLOSED

#define NO_OBJECTS 0x0000

/** Memory block description */
#define INITIAL_BLOCK_BYTE_SIZE (SRAM_ADDRESS_BYTE_SIZE + \
                                 SRAM_ENTRY_BYTE_SIZE)  * \
                                 INITIAL_BLOCK_SIZE + 1

/** Status of the UART filestream */
int stream_status;


/**
 * Initialize the papiGPU
 */
int i_papiGPU_initialize(gpu_portname         portname[],
                         enum papiGPU_states *state)
{
  int status = 0;
  struct termios uart_options = {0};
  uint16_t mem_valid_tag = 0;
  unsigned char *str_converted;
  unsigned char *str_to_send;
  unsigned char *str_to_receive;
  unsigned char *str_to_compare;
  uint16_t SRAM_address = 0;
  uint16_t SRAM_entry = 0;
  uint16_t block_element = 0;

  str_converted = (char *) malloc(sizeof(uint16_t));
  str_to_send = (char *) malloc(sizeof(uint16_t));
  str_to_receive = (char *) malloc(sizeof(uint16_t));
  str_to_compare = (char *) malloc(sizeof(uint16_t));

  // Check if pre-states is allowed
  if (!((1 << *state) & INITIALIZED_PS)){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to initialize the GPU. Check it is " \
               "not already initialized. Error code: %d\n", EPERM);
    #endif
    // No change the state
    return EPERM;
  }

  // Open UART filestream
  stream_status = open(portname, O_RDWR | O_NOCTTY | O_SYNC);

  if (0 > stream_status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to open UART. Ensure device is " \
               "connected or it is not in use by another application. " \
               "Error code: %d\n", stream_status);
    #endif
    *state = GPU_ERROR;
    return stream_status;
  }

  // Set the UART configuration and options
  status = tcgetattr(stream_status, &uart_options);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to get the parameters associated " \
               "with the terminal. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  uart_options.c_cflag = B921600 | CS8 | CLOCAL | CREAD;
	uart_options.c_iflag = IGNPAR;
	uart_options.c_oflag = 0;
	uart_options.c_lflag = 0;

  status = tcflush(stream_status, TCIOFLUSH);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to set the flash the output/input " \
               "data. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = tcsetattr(stream_status, TCSANOW, &uart_options);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to set the parameters associated " \
               "with the terminal. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  // Request the papiGPU initialization
  mem_valid_tag = REQUEST_VALID_TAG;
  status = u_half_prec_to_string(mem_valid_tag, str_to_send);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the request valid tag " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = u_uart_transmitter(stream_status,
                              (void*) str_to_send,
                              SRAM_TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to transmit data using UART. " \
               "Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  // Waiting for papiGPU initialization approval
  mem_valid_tag = APPROVAL_VALID_TAG;
  status = u_half_prec_to_string(mem_valid_tag, str_to_compare);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the approval valid tag " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = u_uart_receiver(stream_status,
                           (void*) str_to_receive,
                           SRAM_TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to receive data using UART. " \
               "Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = memcmp(str_to_compare, str_to_receive, SRAM_TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: UART approval tag is not valid. " \
               "Error code: %d\n", EIO);
    #endif
    *state = GPU_ERROR;
    return EIO;
  }

  // Format the SRAM of the papiGPU
  str_to_send = (char *) malloc(INITIAL_BLOCK_BYTE_SIZE);

  // Set initial address and valid tag for the papiGPU
  SRAM_address = INITIAL_ADDRESS;
  status = u_half_prec_to_string(SRAM_address, str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the initial papiGPU " \
               "address to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[0],
          str_converted,
          sizeof(uint16_t));

  SRAM_entry = GPU_VALID_TAG;
  status = u_half_prec_to_string(SRAM_entry, str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the papiGPU valid tag " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  // Set the number of objects in cero
  block_element++;
  SRAM_entry = NO_OBJECTS;
  status = u_half_prec_to_string(SRAM_entry, str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the number of objects " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  // Finish the initialization
  block_element++;
  SRAM_entry = FINAL_BLOCK_VALID_TAG;
  status = u_half_prec_to_string(SRAM_entry, str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the number of objects " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  // Sending initial block to SRAM
  status = u_uart_transmitter(stream_status,
                              (void*) str_to_send,
                              INITIAL_BLOCK_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to transmit data using UART. " \
               "Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  // Waiting for papiGPU success answer
  mem_valid_tag = (uint16_t)(REQUEST_VALID_TAG);
  status = u_half_prec_to_string(mem_valid_tag, str_to_compare);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the approval valid tag " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = u_uart_receiver(stream_status,
                           (void*) str_to_receive,
                           SRAM_TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to receive data using UART. " \
               "Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = memcmp(str_to_compare, str_to_receive, SRAM_TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to format the SRAM of the papiGPU. " \
               "Error code: %d\n", EIO);
    #endif
    *state = GPU_ERROR;
    return EIO;
  }

  // Release Memory
  free(str_converted);
  free(str_to_send);
  free(str_to_receive);
  free(str_to_compare);

  return status;
}


/**
 * Create the camera
 */
int i_papiGPU_create_camera(struct papiGPU_vertex  cam_vertex,
                            gpu_focal_point        fp_distance,
                            enum papiGPU_states   *state)
{
  return 0;
}
