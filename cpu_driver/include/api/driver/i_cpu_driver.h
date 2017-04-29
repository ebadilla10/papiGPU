#include <stdio.h>
#include <api/cpu_driver.h>

static struct i_gpu_object_config{
  bool     enable;
  uint16_t SRAM_address;
  uint16_t vetex_counter;
};

int i_papiGPU_initialize(gpu_portname         portname[],
                         enum papiGPU_states *state);

int i_papiGPU_create_camara(struct papiGPU_vertex  cam_vertex,
                            gpu_focal_point        fp_distance,
                            enum papiGPU_states   *state);

int i_papiGPU_create_object(bool                          enable,
                            struct papiGPU_rotate_angles  rota_angles,
                            struct papiGPU_scales         scales,
                            struct papiGPU_translation    translation,
                            gpu_object_id                *object_id,
                            enum papiGPU_states          *state);

int i_papiGPU_insert_vertex(gpu_object_id          object_id,
                            struct papiGPU_vertex  vertex,
                            gpu_obj_vertex_id     *vertex_id,
                            enum papiGPU_states   *state);

int i_papiGPU_close_object(gpu_object_id        object_id,
                           enum papiGPU_states *state);

int i_papiGPU_change_transf_matrix(gpu_object_id                object_id,
                                   struct papiGPU_rotate_angles rota_angles,
                                   struct papiGPU_scales        scales,
                                   struct papiGPU_translation   translation,
                                   enum papiGPU_states         *state);

int i_papiGPU_refresh(enum papiGPU_states *state);
