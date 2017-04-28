#include <stdio.h>
#include <inttypes.h>

// Types for GPU initialization
typedef char gpu_portname;

// Types for GPU objects and camara
typedef float gpu_vertex;
typedef float gpu_angle;
typedef float gpu_scale;
typedef float gpu_translation;
typedef float gpu_focal_point;

// Types for ID
  // gpu_object_id is the pointer to gpu_object_config
  typedef int      gpu_object_id;
  // gpu_obj_vertex_id is the SRAM address
  typedef uint16_t gpu_obj_vertex_id;

enum papiGPU_states{
  GPU_INITIALIZED,
  GPU_CAMARA_CREATED,
  GPU_OBJECT_CREATED,
  GPU_VERTEX_INSERTED,
  GPU_OBJECT_CLOSED,
  GPU_OBJ_TMATRIX_CHANGED,
  GPU_REFRESHED,
  GPU_OBJECT_REVOMED,
  GPU_UNINITIALIZED,
  GPU_MAX_STATE,
};
