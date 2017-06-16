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
      fprintf (stderr, "ERROR: The state pointer is null. " \
               "Error code: %d\n", EINVAL);
    #endif
    return EINVAL;
  }

  *state = GPU_ERROR;

  status = strcmp(portname, "");
  if (!status){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: The GPU portname is empty. " \
               "Error code: %d\n", EINVAL);
    #endif
    *state = GPU_ERROR;
    return EINVAL;
  }

  status = i_papiGPU_initialize(portname, state);

  if (!status){
    #ifdef DEBUGLOG
      fprintf (stderr, "INFO: The GPU was initialized.\n");
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
      fprintf (stderr, "ERROR: The state pointer is null. " \
               "Error code: %d\n", EINVAL);
    #endif
    return EINVAL;
  }

  if (0 > fp_distance){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: The focal point distance of camera " \
               "can not be negative. Error code: %d\n", EINVAL);
    #endif
    *state = GPU_ERROR;
    return EINVAL;
  }

  status = i_papiGPU_create_camera(cam_vertex, fp_distance, state);

  if (!status){
    #ifdef DEBUGLOG
      fprintf (stderr, "INFO: The camera was created.\n");
    #endif
    *state = GPU_CAMERA_CREATED;
  }

  return status;
}

/**
 * Create an object and keep it open
 */
int papiGPU_create_object(bool                          enable,
                          struct papiGPU_rotate_angles  rota_angles,
                          struct papiGPU_scales         scales,
                          struct papiGPU_translation    translation,
                          gpu_object_id                *object_id,
                          enum papiGPU_states          *state)
{
  int status = 0;

  // Check for valid arguments
  if (NULL == state){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: The state pointer is null. " \
               "Error code: %d\n", EINVAL);
    #endif
    return EINVAL;
  }

  if (NULL == object_id){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: The object ID pointer is null. " \
               "Error code: %d\n", EINVAL);
    #endif
    return EINVAL;
  }

  status = i_papiGPU_create_object(enable,
                                 rota_angles,
                                 scales,
                                 translation,
                                 object_id,
                                 state);

  if (!status){
    #ifdef DEBUGLOG
      fprintf (stderr, "INFO: The object was created.\n");
    #endif
    *state = GPU_OBJECT_CREATED;
  }

  return status;
}

/**
 * Insert an array of verteces in open object
 */
int papiGPU_insert_vertices(gpu_object_id          object_id,
                            int                    num_vtx,
                            struct papiGPU_vertex  vertex[],
                            enum papiGPU_states   *state)
{
  int status = 0;

  // Check for valid arguments
  if (NULL == state){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: The state pointer is null. " \
               "Error code: %d\n", EINVAL);
    #endif
    return EINVAL;
  }

  if (0 > num_vtx){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: Number of vertices wouldn't be negative. " \
               "Error code: %d\n", EINVAL);
    #endif
    return EINVAL;
  }

  status = i_papiGPU_insert_vertices(object_id,
                                     num_vtx,
                                     vertex,
                                     state);

  if (!status){
    #ifdef DEBUGLOG
      fprintf (stderr, "INFO: The vertices were inserted.\n");
    #endif
    *state = GPU_VERTEX_INSERTED;
  }

  return status;
}

/**
 * Close the object
 */
int papiGPU_close_object(gpu_object_id        object_id,
                         enum papiGPU_states *state)
{
  int status = 0;

  // Check for valid arguments
  if (NULL == state){
    #ifdef DEBUGLOG
      fprintf (stderr, "ERROR: The state pointer is null. " \
               "Error code: %d\n", EINVAL);
    #endif
    return EINVAL;
  }

  status = i_papiGPU_close_object(object_id,
                                  state);

  if (!status){
    #ifdef DEBUGLOG
      fprintf (stderr, "INFO: The object was closed.\n");
    #endif
    *state = GPU_OBJECT_CLOSED;
  }

  return status;
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
  fprintf (stderr, "ERROR: Function not implemented\n");
  return EPERM;
}

/**
 * Refresh the all parameter in papiGPU
 */
int papiGPU_refresh(enum papiGPU_states *state)
{
  fprintf (stderr, "ERROR: Function not implemented\n");
  return EPERM;
}
