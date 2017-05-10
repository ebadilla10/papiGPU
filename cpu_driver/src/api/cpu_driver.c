#include <stdio.h>
#include <stdbool.h>
#include <api/cpu_driver.h>
#include <errno.h>
#include <string.h>

/** Inlude the implementated functions */
#include <api/driver/i_cpu_driver.h>


/**
 * Initialize the papiGPU
 */
int papiGPU_initialize(gpu_portname         portname[],
                       enum papiGPU_states *state)
{
  int status = 0;

  // Check for valid arguments
  if (NULL == state){
    #ifdef DEBUGLOG
    printf ("\x1B[31m" "ERROR: " "\x1B[0m" "The state pointer is null. " \
            "Error code: %d\n", EINVAL);
    #endif
    return EINVAL;
  }

  *state = GPU_ERROR;

  status = strcmp(portname, "");
  if (!status){
    #ifdef DEBUGLOG
    printf ("\x1B[31m" "ERROR: " "\x1B[0m" "The GPU portname is empty. " \
            "Error code: %d\n", EINVAL);
    #endif
    *state = GPU_ERROR;
    return EINVAL;
  }

  status = i_papiGPU_initialize(portname, state);

  if (!status){
    #ifdef DEBUGLOG
    printf ("\x1B[32m" "INFO: " "\x1B[0m" "The GPU was initialized.\n");
    #endif
    *state = GPU_INITIALIZED;
  }

  return status;
}


/**
 * Create the camera
 */
int papiGPU_create_camera(struct papiGPU_vertex  cam_vertex,
                          gpu_focal_point        fp_distance,
                          enum papiGPU_states   *state)
{
  int status = 0;

  // Check for valid arguments
  if (NULL == state){
    #ifdef DEBUGLOG
    printf ("\x1B[31m" "ERROR: " "\x1B[0m" "The state pointer is null. " \
            "Error code: %d\n", EINVAL);
    #endif
    return EINVAL;
  }

  if (0 > fp_distance){
    #ifdef DEBUGLOG
    printf ("\x1B[31m" "ERROR: " "\x1B[0m" "The focal point distance of " \
            "camera can not be negative. Error code: %d\n", EINVAL);
    #endif
    *state = GPU_ERROR;
    return EINVAL;
  }

  status = i_papiGPU_create_camera(cam_vertex, fp_distance, state);

  if (!status){
    #ifdef DEBUGLOG
    printf ("\x1B[32m" "INFO: " "\x1B[0m" "The camera was created.\n");
    #endif
    *state = GPU_CAMERA_CREATED;
  }

  return status;
}

int papiGPU_create_object(bool                          enable,
                          struct papiGPU_rotate_angles  rota_angles,
                          struct papiGPU_scales         scales,
                          struct papiGPU_translation    translation,
                          gpu_object_id                *object_id,
                          enum papiGPU_states          *state)
{
  printf ("\x1B[31m" "ERROR: " "\x1B[0m" "Function not implemented\n");
  return EPERM;
}

/**
 * Insert an array of verteces in open object
 */
int papiGPU_insert_vertices(gpu_object_id          object_id,
                            struct papiGPU_vertex  vertex[],
                            enum papiGPU_states   *state)
{
  printf ("\x1B[31m" "ERROR: " "\x1B[0m" "Function not implemented\n");
  return EPERM;
}

/**
 * Close the object
 */
int papiGPU_close_object(gpu_object_id        object_id,
                         enum papiGPU_states *state)
{
 printf ("\x1B[31m" "ERROR: " "\x1B[0m" "Function not implemented\n");
 return EPERM;
}

/**
 * Change the transformation matrix of an object
 */
int papiGPU_change_transf_matrix(gpu_object_id                object_id,
                                 struct papiGPU_rotate_angles rota_angles,
                                 struct papiGPU_scales        scales,
                                 struct papiGPU_translation   translation,
                                 enum papiGPU_states         *state)
{
 printf ("\x1B[31m" "ERROR: " "\x1B[0m" "Function not implemented\n");
 return EPERM;
}

/**
 * Refresh the all parameter in papiGPU
 */
int papiGPU_refresh(enum papiGPU_states *state)
{
  printf ("\x1B[31m" "ERROR: " "\x1B[0m" "Function not implemented\n");
  return EPERM;
}
