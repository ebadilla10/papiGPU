#include <stdio.h>
#include <api/cpu_driver.h>
#include <api/types/papiGPU_types.h>
#include <api/driver/i_cpu_driver.h>
#include <errno.h>

int papiGPU_initialize(gpu_portname         portname[],
                       enum papiGPU_states *state)
{
  printf ("\x1B[31m" "ERROR: " "\x1B[0m" "Function not implemented\n");
  return EPERM;
}

int papiGPU_create_camara(struct papiGPU_vertex  cam_vertex,
                          gpu_focal_point        fp_distance,
                          enum papiGPU_states   *state)
{
  printf ("\x1B[31m" "ERROR: " "\x1B[0m" "Function not implemented\n");
  return EPERM;
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

int papiGPU_insert_vertex(gpu_object_id          object_id,
                          struct papiGPU_vertex  vertex
                          gpu_obj_vertex_id     *vertex_id,
                          enum papiGPU_states   *state)
{
  printf ("\x1B[31m" "ERROR: " "\x1B[0m" "Function not implemented\n");
  return EPERM;
}

int papiGPU_close_object(gpu_object_id        object_id,
                         enum papiGPU_states *state)
{
 printf ("\x1B[31m" "ERROR: " "\x1B[0m" "Function not implemented\n");
 return EPERM;
}

int papiGPU_change_transf_matrix(gpu_object_id                object_id,
                                 struct papiGPU_rotate_angles rota_angles,
                                 struct papiGPU_scales        scales,
                                 struct papiGPU_translation   translation,
                                 enum papiGPU_states         *state)
{
 printf ("\x1B[31m" "ERROR: " "\x1B[0m" "Function not implemented\n");
 return EPERM;
}

int papiGPU_refresh(enum papiGPU_states *state)
{
  printf ("\x1B[31m" "ERROR: " "\x1B[0m" "Function not implemented\n");
  return EPERM;
}
