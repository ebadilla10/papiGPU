#include <stdio.h>
#include <stdbool.h>
#include <api/types/papiGPU_types.h>

#ifndef DEBUGLOG
  #define DEBUGLOG
  /** To print all information from API execution */
#endif /** DEBUGLOG */

#ifndef PORTNAME
  #define PORTNAME "/dev/ttyUSB1"
  /** UART port name */
#endif /** PORTNAME */

/**
 * Rotate angles in radians
 */
struct papiGPU_rotate_angles{
  gpu_angle row;   /**< Rotation with respect to the X-axes */
  gpu_angle pitch; /**< Rotation with respect to the Y-axes */
  gpu_angle yaw;   /**< Rotation with respect to the Z-axes */
};

/**
 * 3-Dimensional scale constants
 */
struct papiGPU_scales{
  gpu_scale sx; /**< Object scaling in X-axes */
  gpu_scale sy; /**< Object scaling in Y-axes */
  gpu_scale sz; /**< Object scaling in Z-axes */
};

/**
 * 3-Dimensional translation constants
 */
struct papiGPU_translation{
  gpu_translation tx; /**< Object translation in X-axes */
  gpu_translation ty; /**< Object translation in Y-axes */
  gpu_translation tz; /**< Object translation in Z-axes */
};

/**
 * 3-Dimensional vertex values
 */
struct papiGPU_vertex{
  gpu_vertex x; /**< Single-precision X-axes point*/
  gpu_vertex y; /**< Single-precision Y-axes point*/
  gpu_vertex z; /**< Single-precision Z-axes point*/
};


/**
 * Initialize the papiGPU
 *
 * @param[in]   portname[] is a string with the portname
 * @param[out] *state      is the papiGPU general state
 * @return      0          if function was succesful
 *              errno      if function failed
 */
int papiGPU_initialize(gpu_portname         portname[],
                       enum papiGPU_states *state);


/** FIXME: The camera could need to set transformation parameters */
/**
 * Create the camera
 *
 * @param[in]   cam_vertex  are vertex values of camera
 * @param[in]   fp_distance is the distances of focal point
 * @param[out] *state       is the papiGPU general state
 * @return      0           if function was succesful
 *              errno       if function failed
 */
int papiGPU_create_camera(struct papiGPU_vertex  cam_vertex,
                          gpu_focal_point        fp_distance,
                          enum papiGPU_states   *state);


/**
 * Create an object and keep it open
 *
 * @param[in]   enable      is enable for object projection
 * @param[in]   rota_angles are the rotate angles
 * @param[in]   scales      are the scale constants
 * @param[in]   translation are the translation constants
 * @param[out] *object_id   is the object ID
 * @param[out] *state       is the papiGPU general state
 * @return      0           if function was succesful
 *              errno       if function failed
 */
int papiGPU_create_object(bool                          enable,
                          struct papiGPU_rotate_angles  rota_angles,
                          struct papiGPU_scales         scales,
                          struct papiGPU_translation    translation,
                          gpu_object_id                *object_id,
                          enum papiGPU_states          *state);


/**
 * Insert an array of verteces in open object
 *
 * @param[in]   object_id is the open object ID
 * @param[in]   vertex[]  are the vertex values
 * @param[out] *state     is the papiGPU general state
 * @return      0         if function was succesful
 *              errno     if function failed
 */
int papiGPU_insert_vertices(gpu_object_id          object_id,
                            struct papiGPU_vertex  vertex[],
                            enum papiGPU_states   *state);


/**
 * Close the object
 *
 * @param[in]   object_id is the open object ID
 * @param[out] *state     is the papiGPU general state
 * @return      0         if function was succesful
 *              errno     if function failed
 */
int papiGPU_close_object(gpu_object_id        object_id,
                         enum papiGPU_states *state);


/**
 * Change the transformation matrix of an object
 *
 * @param[in]   object_id   is the open object ID
 * @param[in]   rota_angles are the rotate angles
 * @param[in]   scales      are the scale constants
 * @param[in]   translation are the translation constants
 * @param[out] *state       is the papiGPU general state
 * @return      0           if function was succesful
 *              errno       if function failed
 */
int papiGPU_change_transf_matrix(gpu_object_id                object_id,
                                 struct papiGPU_rotate_angles rota_angles,
                                 struct papiGPU_scales        scales,
                                 struct papiGPU_translation   translation,
                                 enum papiGPU_states         *state);


/**
 * Refresh the all parameter in papiGPU
 *
 * @param[out] *state is the papiGPU general state
 * @return      0     if function was succesful
 *              errno if function failed
 */
int papiGPU_refresh(enum papiGPU_states *state);


/** TODO: Missing functions - For next versions
int papiGPU_color_vertex();
int papiGPU_remove_vertex();
int papiGPU_remove_object();
int papiGPU_uninitialize();
*/
