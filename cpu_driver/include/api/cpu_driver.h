#include <stdio.h>
#include <api/types/papiGPU_types.h>

#define PORTNAME "/dev/ttyUSB1"

struct papiGPU_rotate_angles{
  gpu_angle row;
  gpu_angle pitch;
  gpu_angle yaw;
};

struct papiGPU_scales{
  gpu_scale sx;
  gpu_scale sy;
  gpu_scale sz;
};

struct papiGPU_translation{
  gpu_translation tx;
  gpu_translation ty;
  gpu_translation tz;
};

struct papiGPU_vertex{
  gpu_vertex x;
  gpu_vertex y;
  gpu_vertex z;
};

int papiGPU_initialize(gpu_portname         portname[],
                       enum papiGPU_states *state);

// FIXME: The camara could need to set transformation parameters
int papiGPU_create_camara(struct papiGPU_vertex  cam_vertex,
                          gpu_focal_point        fp_distance,
                          enum papiGPU_states   *state);

int papiGPU_create_object(bool                          enable,
                          struct papiGPU_rotate_angles  rota_angles,
                          struct papiGPU_scales         scales,
                          struct papiGPU_translation    translation,
                          gpu_object_id                *object_id,
                          enum papiGPU_states          *state);

int papiGPU_insert_vertex(gpu_object_id          object_id,
                          struct papiGPU_vertex  vertex
                          gpu_obj_vertex_id     *vertex_id,
                          enum papiGPU_states   *state);

int papiGPU_close_object(gpu_object_id        object_id,
                         enum papiGPU_states *state);

int papiGPU_change_transf_matrix(gpu_object_id                object_id,
                                 struct papiGPU_rotate_angles rota_angles,
                                 struct papiGPU_scales        scales,
                                 struct papiGPU_translation   translation,
                                 enum papiGPU_states         *state);

int papiGPU_refresh(enum papiGPU_states *state);

/* TODO: Missing functions - For next versions
int papiGPU_remove_vertex();
int papiGPU_remove_object();
int papiGPU_uninitialize();
*/
