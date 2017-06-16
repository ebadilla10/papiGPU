#include <stdio.h>
#include <math.h>
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
#define OBJECT_CREATE_PS      1 << GPU_CAMERA_CREATED  | \
                              1 << GPU_OBJECT_CLOSED
#define VERTEX_INSERT_PS      1 << GPU_OBJECT_CREATED
#define OBJECT_CLOSE_PS       1 << GPU_VERTEX_INSERTED
#define OBJ_TMATRIX_CHANGE_PS 1 << GPU_OBJECT_CREATED  | \
                              1 << GPU_VERTEX_INSERTED | \
                              1 << GPU_OBJECT_CLOSED
#define REFRESH_PS            1 << GPU_OBJECT_CLOSED

#define NO_OBJECTS 0x0000

/** State burst sizes */
#define INITIAL_BURST_BYTE_SIZE SRAM_ADDRESS_BYTE_SIZE + \
                                (SRAM_ENTRY_BYTE_SIZE  * \
                                INITIAL_BLOCK_SIZE) + 2

#define CAMERA_BURST_BYTE_SIZE SRAM_ADDRESS_BYTE_SIZE + \
                               (SRAM_ENTRY_BYTE_SIZE  * \
                               CAM_BLOCK_SIZE) + 2

#define OBJECT_BURST_BYTE_SIZE SRAM_ADDRESS_BYTE_SIZE + \
                               (SRAM_ENTRY_BYTE_SIZE  * \
                               TO_INIT_VERTEX_BLOCK_SIZE) + 2

#define CLS_OBJ_BURST_BYTE_SIZE SRAM_ADDRESS_BYTE_SIZE + \
                                SRAM_ENTRY_BYTE_SIZE + 2

/** Baud Rate for UART (bit/s) */
#define UART_BAUD_RATE B921600

/** Status of the UART filestream */
int stream_status;

/** UART Options */
struct termios uart_options = {0};

/** Next Object Address = Next Object ID*/
int next_object_address = INIT_OBJS_ADDRESS;


/**
 * Initialize the papiGPU
 */
int i_papiGPU_initialize(gpu_portname         portname[],
                         enum papiGPU_states *state)
{
  int status = 0;
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

  uart_options.c_cflag = UART_BAUD_RATE | CS8 | CLOCAL | CREAD;
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
                              TAG_BYTE_SIZE);
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
                           TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to receive data using UART. " \
               "Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = memcmp(str_to_compare, str_to_receive, TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: UART approval tag is not valid. " \
               "Error code: %d\n", EIO);
    #endif
    *state = GPU_ERROR;
    return EIO;
  }

  // Format the SRAM of the papiGPU
  free(str_to_send);
  str_to_send = (char *) malloc(INITIAL_BURST_BYTE_SIZE);

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
                              INITIAL_BURST_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to transmit data using UART. " \
               "Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  // Waiting for papiGPU success answer
  mem_valid_tag = REQUEST_VALID_TAG;
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
                           TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to receive data using UART. " \
               "Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = memcmp(str_to_compare, str_to_receive, TAG_BYTE_SIZE);
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
  int status = 0;
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
  if (!((1 << *state) & CAMERA_CREATE_PS)){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to create camera. Check papiGPU " \
               "is already initialized. Error code: %d\n", EPERM);
    #endif
    // No change the state
    return EPERM;
  }

  // Request the papiGPU Camera Create
  mem_valid_tag = CAM_VALID_TAG;
  status = u_half_prec_to_string(mem_valid_tag, str_to_send);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the camera request valid " \
               "tag to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = u_uart_transmitter(stream_status,
                              (void*) str_to_send,
                              TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to transmit data using UART. " \
               "Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  // Waiting for papiGPU camera create approval
  mem_valid_tag = (uint16_t) ~(CAM_VALID_TAG);
  status = u_half_prec_to_string(mem_valid_tag, str_to_compare);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the camera tag " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = u_uart_receiver(stream_status,
                           (void*) str_to_receive,
                           TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to receive data using UART. " \
               "Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = memcmp(str_to_compare, str_to_receive, TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Camera approval tag is not valid. " \
               "Error code: %d\n", EIO);
    #endif
    *state = GPU_ERROR;
    return EIO;
  }

  // Configure the Camera burst
  free(str_to_send);
  str_to_send = (char *) malloc(CAMERA_BURST_BYTE_SIZE);

  // Set camera address and camera tag for the papiGPU
  SRAM_address = CAM_ADDRESS;
  status = u_half_prec_to_string(SRAM_address, str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the camera " \
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
      fprintf (stderr, "ERROR: Unable to convert the camera tag " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  // Set camera values
  block_element++;

  status = u_float_to_half_prec(cam_vertex.x, &SRAM_entry, str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert camera vertex X " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  block_element++;
  status = u_float_to_half_prec(cam_vertex.y, &SRAM_entry, str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert camera vertex Y " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  block_element++;
  status = u_float_to_half_prec(cam_vertex.z, &SRAM_entry, str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert camera vertex Z " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  block_element++;
  status = u_float_to_half_prec(fp_distance, &SRAM_entry, str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert camera focal distance " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  // Finish the camera creation
  block_element++;
  SRAM_entry = FINAL_BLOCK_VALID_TAG;
  status = u_half_prec_to_string(SRAM_entry, str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the final tag " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  // Sending camera burst to SRAM
  status = u_uart_transmitter(stream_status,
                              (void*) str_to_send,
                              CAMERA_BURST_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to transmit data using UART. " \
               "Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  // Waiting for papiGPU success answer
  mem_valid_tag = CAM_VALID_TAG;
  status = u_half_prec_to_string(mem_valid_tag, str_to_compare);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the camera valid tag " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = u_uart_receiver(stream_status,
                           (void*) str_to_receive,
                           TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to receive data using UART. " \
               "Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = memcmp(str_to_compare, str_to_receive, TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to set the camera of the papiGPU. " \
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
 * Create an object and keep it open
 */
int i_papiGPU_create_object(bool                          enable,
                            struct papiGPU_rotate_angles  rota_angles,
                            struct papiGPU_scales         scales,
                            struct papiGPU_translation    translation,
                            gpu_object_id                *object_id,
                            enum papiGPU_states          *state)
{
  int status = 0;
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
  if (!((1 << *state) & OBJECT_CREATE_PS)){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to create object. Check papiGPU " \
               "previous function. Error code: %d\n", EPERM);
    #endif
    // No change the state
    return EPERM;
  }

  // Request the papiGPU object create
  mem_valid_tag = OBJ_VALID_TAG;
  status = u_half_prec_to_string(mem_valid_tag, str_to_send);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert object create request valid " \
               "tag to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = u_uart_transmitter(stream_status,
                              (void*) str_to_send,
                              TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to transmit data using UART. " \
               "Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  // Waiting for papiGPU object create approval
  mem_valid_tag = (uint16_t) ~(OBJ_VALID_TAG);
  status = u_half_prec_to_string(mem_valid_tag, str_to_compare);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the object create tag " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = u_uart_receiver(stream_status,
                           (void*) str_to_receive,
                           TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to receive data using UART. " \
               "Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = memcmp(str_to_compare, str_to_receive, TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Object create approval tag is not valid. " \
               "Error code: %d\n", EIO);
    #endif
    *state = GPU_ERROR;
    return EIO;
  }

  // Configure the object create burst
  free(str_to_send);
  str_to_send = (char *) malloc(OBJECT_BURST_BYTE_SIZE);

  // Set object addresss, object tag and next object address
  *object_id = next_object_address;
  SRAM_address = (uint16_t) next_object_address;
  status = u_half_prec_to_string(SRAM_address, str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the object " \
               "address to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[0],
          str_converted,
          sizeof(uint16_t));

  if (enable) SRAM_entry = OBJ_VALID_TAG;
  else SRAM_entry = (uint16_t) OBJ_DISABLE_TAG;
  status = u_half_prec_to_string(SRAM_entry, str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the object tag " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  block_element++;
  SRAM_entry = (uint16_t) 0x0000;
  status = u_half_prec_to_string(SRAM_entry, str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the next object address " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  // Set object values
  block_element++;
  status = u_float_to_half_prec(cos(rota_angles.yaw),
                                &SRAM_entry,
                                str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert object cos(yaw) " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  block_element++;
  status = u_float_to_half_prec(cos(rota_angles.pitch),
                                &SRAM_entry,
                                str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert object cos(pitch) " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  block_element++;
  status = u_float_to_half_prec(cos(rota_angles.row),
                                &SRAM_entry,
                                str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert object cos(row) " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  block_element++;
  status = u_float_to_half_prec(sin(rota_angles.yaw),
                                &SRAM_entry,
                                str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert object sin(yaw) " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  block_element++;
  status = u_float_to_half_prec(sin(rota_angles.pitch),
                                &SRAM_entry,
                                str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert object sin(pitch) " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  block_element++;
  status = u_float_to_half_prec(sin(rota_angles.row),
                                &SRAM_entry,
                                str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert object sin(row) " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  block_element++;
  status = u_float_to_half_prec(scales.sx,
                                &SRAM_entry,
                                str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert object scale X " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  block_element++;
  status = u_float_to_half_prec(scales.sy,
                                &SRAM_entry,
                                str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert object scale Y " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  block_element++;
  status = u_float_to_half_prec(scales.sz,
                                &SRAM_entry,
                                str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert object scale Z " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  block_element++;
  status = u_float_to_half_prec(translation.tx,
                                &SRAM_entry,
                                str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert object translation X " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  block_element++;
  status = u_float_to_half_prec(translation.ty,
                                &SRAM_entry,
                                str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert object translation Y " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  block_element++;
  status = u_float_to_half_prec(translation.tz,
                                &SRAM_entry,
                                str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert object translation Z " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  // Finish the object creation
  block_element++;
  SRAM_entry = FINAL_BLOCK_VALID_TAG;
  status = u_half_prec_to_string(SRAM_entry, str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the final tag " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  // Sending object burst to SRAM
  status = u_uart_transmitter(stream_status,
                              (void*) str_to_send,
                              OBJECT_BURST_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to transmit data using UART. " \
               "Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  // Waiting for papiGPU success answer
  mem_valid_tag = OBJ_VALID_TAG;
  status = u_half_prec_to_string(mem_valid_tag, str_to_compare);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the object valid tag " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = u_uart_receiver(stream_status,
                           (void*) str_to_receive,
                           TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to receive data using UART. " \
               "Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = memcmp(str_to_compare, str_to_receive, TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to create a object of the papiGPU. " \
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
 * Insert an array of verteces in open object
 */
int i_papiGPU_insert_vertices(gpu_object_id          object_id,
                              int                    num_vtx,
                              struct papiGPU_vertex  vertex[],
                              enum papiGPU_states   *state)
{
  int status = 0;
  uint16_t mem_valid_tag = 0;
  unsigned char *str_converted;
  unsigned char *str_to_send;
  unsigned char *str_to_receive;
  unsigned char *str_to_compare;
  uint16_t SRAM_address = 0;
  uint16_t SRAM_entry = 0;
  uint16_t block_element = 0;

  // TODO: No magic numbers to VTX BURST
  int vtx_burst_byte_size = (6 * num_vtx) + 6 + 2;
  int vtx_address = 0;

  // Set the address to next object
  next_object_address += TO_INIT_VERTEX_BLOCK_SIZE + (3 * num_vtx);

  str_converted = (char *) malloc(sizeof(uint16_t));
  str_to_send = (char *) malloc(sizeof(uint16_t));
  str_to_receive = (char *) malloc(sizeof(uint16_t));
  str_to_compare = (char *) malloc(sizeof(uint16_t));

  // Check if pre-states is allowed
  if (!((1 << *state) & VERTEX_INSERT_PS)){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to insert vertices. Check papiGPU " \
               "is already initialized. Error code: %d\n", EPERM);
    #endif
    // No change the state
    return EPERM;
  }

  // Request the papiGPU insert vertices
  mem_valid_tag = VRTX_VALID_TAG;
  status = u_half_prec_to_string(mem_valid_tag, str_to_send);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert vertex request valid " \
               "tag to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = u_uart_transmitter(stream_status,
                              (void*) str_to_send,
                              TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to transmit data using UART. " \
               "Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  // Waiting for papiGPU vertices insert approval
  mem_valid_tag = (uint16_t) ~(VRTX_VALID_TAG);
  status = u_half_prec_to_string(mem_valid_tag, str_to_compare);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the vertex valid tag " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = u_uart_receiver(stream_status,
                           (void*) str_to_receive,
                           TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to receive data using UART. " \
               "Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = memcmp(str_to_compare, str_to_receive, TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Vertex approval tag is not valid. " \
               "Error code: %d\n", EIO);
    #endif
    *state = GPU_ERROR;
    return EIO;
  }

  // Configure the vertices burst

  free(str_to_send);
  str_to_send = (char *) malloc(vtx_burst_byte_size);
  vtx_address = object_id + TO_INIT_VERTEX_BLOCK_SIZE;

  // Set number of vertices, vertices initial address and vertex valid tag

  SRAM_entry = (uint16_t) num_vtx;
  status = u_half_prec_to_string(SRAM_entry, str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the vertices " \
               "number to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[0],
          str_converted,
          sizeof(uint16_t));

  SRAM_address = (uint16_t) vtx_address;
  status = u_half_prec_to_string(SRAM_address, str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the vertex " \
               "address to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  block_element++;
  SRAM_entry = (uint16_t) VRTX_VALID_TAG;
  status = u_half_prec_to_string(SRAM_entry, str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the vertices valid tag " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  // Set the vertices
  for (int vtx_counter = 0; vtx_counter < num_vtx; vtx_counter++){

    block_element++;
    status = u_float_to_half_prec(vertex[vtx_counter].x,
                                  &SRAM_entry,
                                  str_converted);
    if (status){
      #ifdef DEBUGLOG
        fprintf (stderr, "ERROR: Unable to convert vertex X " \
                 "to string. Error code: %d\n", status);
      #endif
      *state = GPU_ERROR;
      return status;
    }
    strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
            str_converted,
            sizeof(uint16_t));

    block_element++;
    status = u_float_to_half_prec(vertex[vtx_counter].y,
                                  &SRAM_entry,
                                  str_converted);
    if (status){
      #ifdef DEBUGLOG
        fprintf (stderr, "ERROR: Unable to convert vertex Y " \
                 "to string. Error code: %d\n", status);
      #endif
      *state = GPU_ERROR;
      return status;
    }
    strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
            str_converted,
            sizeof(uint16_t));

    block_element++;
    status = u_float_to_half_prec(vertex[vtx_counter].z,
                                  &SRAM_entry,
                                  str_converted);
    if (status){
      #ifdef DEBUGLOG
        fprintf (stderr, "ERROR: Unable to convert vertex Z " \
                 "to string. Error code: %d\n", status);
      #endif
      *state = GPU_ERROR;
      return status;
    }
    strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
            str_converted,
            sizeof(uint16_t));

  }

  // Finish the object creation
  block_element++;
  SRAM_entry = FINAL_BLOCK_VALID_TAG;
  status = u_half_prec_to_string(SRAM_entry, str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the final tag " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  // Sending object burst to SRAM
  status = u_uart_transmitter(stream_status,
                              (void*) str_to_send,
                              vtx_burst_byte_size);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to transmit data using UART. " \
               "Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  // Waiting for papiGPU success answer
  mem_valid_tag = VRTX_VALID_TAG;
  status = u_half_prec_to_string(mem_valid_tag, str_to_compare);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the vertex valid tag " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = u_uart_receiver(stream_status,
                           (void*) str_to_receive,
                           TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to receive data using UART. " \
               "Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = memcmp(str_to_compare, str_to_receive, TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to create vertices of the papiGPU. " \
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
 * Close the object
 */
int i_papiGPU_close_object(gpu_object_id        object_id,
                           enum papiGPU_states *state)
{
  int status = 0;
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
  if (!((1 << *state) & OBJECT_CLOSE_PS)){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to close object. Check object " \
               "is created. Error code: %d\n", EPERM);
    #endif
    // No change the state
    return EPERM;
  }

  // Request the papiGPU close object
  mem_valid_tag = CLS_OBJ_VALID_TAG;
  status = u_half_prec_to_string(mem_valid_tag, str_to_send);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert close object request valid " \
               "tag to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = u_uart_transmitter(stream_status,
                              (void*) str_to_send,
                              TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to transmit data using UART. " \
               "Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  // Waiting for papiGPU close object approval
  mem_valid_tag = (uint16_t) ~(CLS_OBJ_VALID_TAG);
  status = u_half_prec_to_string(mem_valid_tag, str_to_compare);
  if (status){
   #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the close object tag " \
               "to string. Error code: %d\n", status);
   #endif
   *state = GPU_ERROR;
   return status;
  }

  status = u_uart_receiver(stream_status,
                           (void*) str_to_receive,
                           TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to receive data using UART. " \
               "Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = memcmp(str_to_compare, str_to_receive, TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: close object approval tag is not valid. " \
               "Error code: %d\n", EIO);
    #endif
    *state = GPU_ERROR;
    return EIO;
  }

  // Configure the close object burst
  free(str_to_send);
  str_to_send = (char *) malloc(CLS_OBJ_BURST_BYTE_SIZE);

  SRAM_address = (uint16_t) (object_id + 1);
  status = u_half_prec_to_string(SRAM_address, str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the object " \
               "address to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[0],
          str_converted,
          sizeof(uint16_t));

  SRAM_address = (uint16_t) (next_object_address);
  status = u_half_prec_to_string(SRAM_address, str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the next object " \
               "address to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  // Finish the object creation
  block_element++;
  SRAM_entry = FINAL_BLOCK_VALID_TAG;
  status = u_half_prec_to_string(SRAM_entry, str_converted);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the final tag " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }
  strncpy(&str_to_send[SRAM_ADDRESS_BYTE_SIZE + (block_element * SRAM_ENTRY_BYTE_SIZE)],
          str_converted,
          sizeof(uint16_t));

  // Sending close object burst to SRAM
  status = u_uart_transmitter(stream_status,
                              (void*) str_to_send,
                              CLS_OBJ_BURST_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to transmit data using UART. " \
               "Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  // Waiting for papiGPU success answer
  mem_valid_tag = CLS_OBJ_VALID_TAG;
  status = u_half_prec_to_string(mem_valid_tag, str_to_compare);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the object valid tag " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = u_uart_receiver(stream_status,
                           (void*) str_to_receive,
                           TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to receive data using UART. " \
               "Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = memcmp(str_to_compare, str_to_receive, TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to close a object of the papiGPU. " \
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


/*

{
  int status = 0;
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
  if (!((1 << *state) & %%%%%_PS)){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to %%%%%. Check papiGPU " \
               "is already initialized. Error code: %d\n", EPERM);
    #endif
    // No change the state
    return EPERM;
  }

  // Request the papiGPU %%%%%
  mem_valid_tag = %%%%%_TAG;
  status = u_half_prec_to_string(mem_valid_tag, str_to_send);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert %%%%% request valid " \
               "tag to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = u_uart_transmitter(stream_status,
                              (void*) str_to_send,
                              TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to transmit data using UART. " \
               "Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  // Waiting for papiGPU camera create approval
  mem_valid_tag = (uint16_t) ~(%%%%%_TAG);
  status = u_half_prec_to_string(mem_valid_tag, str_to_compare);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to convert the %%%%% tag " \
               "to string. Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = u_uart_receiver(stream_status,
                           (void*) str_to_receive,
                           TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Unable to receive data using UART. " \
               "Error code: %d\n", status);
    #endif
    *state = GPU_ERROR;
    return status;
  }

  status = memcmp(str_to_compare, str_to_receive, TAG_BYTE_SIZE);
  if (status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: %%%%%% approval tag is not valid. " \
               "Error code: %d\n", EIO);
    #endif
    *state = GPU_ERROR;
    return EIO;
  }

  // Configure the %%%%% burst

  // --------------------------------------------


  // Release Memory
  free(str_converted);
  free(str_to_send);
  free(str_to_receive);
  free(str_to_compare);

  return status;
}

*/
