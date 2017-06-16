#include <stdio.h>
#include <api/cpu_driver.h>
#include <errno.h>

static void test_papiGPU(){
  printf ("\n\x1B[35m" "TESTING papiGPU Initialize " "\x1B[0m" ":\n");

  int status;
  gpu_portname empty_portname[] = "";
  gpu_portname incorrect_portname[] = "/dev/ttyUSB9";
  gpu_portname correct_portname[] = PORTNAME;
  enum papiGPU_states initial_state = GPU_ERROR;
  enum papiGPU_states *state = &initial_state;
  enum papiGPU_states *state_null = NULL;

  struct papiGPU_vertex camera_vertex = {.x = 12.3, .y = 2.4, .z = 10.0};
  gpu_focal_point cam_focal_distance = 5.1;

  bool enable = true;
  int object_id = 0;
  struct papiGPU_rotate_angles rota_angles =
                               {.row = 1.01,
                                .pitch = 1.01,
                                .yaw = 0.0};
  struct papiGPU_scales scales = {.sx = 1.0, .sy = 1.0, .sz = 1.0};
  struct papiGPU_translation translation =
                             {.tx = 2.0,
                              .ty = 0.0,
                              .tz = 0.0};

  struct papiGPU_vertex vertex[2] =
  {
    {.x = 1.0, .y = 1.0, .z = 1.0},
    {.x = 1.5, .y = 1.50, .z = 1.5}
  };

  // Send empty portname
  printf ("\x1B[36m" "---Send a empty portname---" "\x1B[0m" "\n");
  status = papiGPU_initialize(empty_portname, state);

  if (status == EINVAL && (GPU_ERROR == *state)){
    printf("[\x1B[32m" "PASSED" "\x1B[0m" "] papiGPU initialization failed " \
           "due to empty portname \n");
  } else {
    printf("[\x1B[31m" "FAILED" "\x1B[0m" "] papiGPU initialization passed " \
           "with empty portname \n");
  }

  // Send an incorrect portname
  printf ("\x1B[36m" "---Send an incorrect portname---" "\x1B[0m" "\n");
  status = papiGPU_initialize(incorrect_portname, state);

  if (status == -EPERM && (GPU_ERROR == *state)){
    printf("[\x1B[32m" "PASSED" "\x1B[0m" "] papiGPU initialization failed " \
           "due to incorrect portname \n");
  } else {
    printf("[\x1B[31m" "FAILED" "\x1B[0m" "] papiGPU initialization passed " \
           "with incorrect portname \n");
  }

  // Send a NULL state pointer with correct portname
  printf ("\x1B[36m" "---Send a NULL state pointer---" "\x1B[0m" "\n");
  state_null = NULL;
  status = papiGPU_initialize(correct_portname, state_null);

  if (status){
    printf("[\x1B[32m" "PASSED" "\x1B[0m" "] papiGPU initialization failed " \
           "due to NULL state pointer \n");
  } else {
    printf("[\x1B[31m" "FAILED" "\x1B[0m" "] papiGPU initialization passed " \
           "with NULL state pointer \n");
  }

  // Send correct portname
  printf ("\x1B[36m" "---Send correct portname---" "\x1B[0m" "\n");
  status = papiGPU_initialize(correct_portname, state);

  if ((0 == status) && (GPU_INITIALIZED == *state)){
    printf("[\x1B[32m" "PASSED" "\x1B[0m" "] papiGPU initialization " \
           "successfully completed\n");
  } else {
    printf("[\x1B[31m" "FAILED" "\x1B[0m" "] papiGPU initialization failed. " \
           "Check papiGPU conection.\n");
  }

  // Create GPU camera
  printf ("\x1B[36m" "---Create camera---" "\x1B[0m" "\n");
  status = papiGPU_create_camera(camera_vertex, cam_focal_distance, state);

  if ((0 == status) && (GPU_CAMERA_CREATED == *state)){
    printf("[\x1B[32m" "PASSED" "\x1B[0m" "] papiGPU camera creation " \
           "successfully completed\n");
  } else {
    printf("[\x1B[31m" "FAILED" "\x1B[0m" "] papiGPU camera creation failed. " \
           "\n");
  }

  // Create GPU objects
  printf ("\x1B[36m" "---Create object---" "\x1B[0m" "\n");
  status = papiGPU_create_object(enable,
                                 rota_angles,
                                 scales,
                                 translation,
                                 &object_id,
                                 state);

  if ((0 == status) && (GPU_OBJECT_CREATED == *state)){
    printf("[\x1B[32m" "PASSED" "\x1B[0m" "] papiGPU object creation " \
           "successfully completed\n");
  } else {
    printf("[\x1B[31m" "FAILED" "\x1B[0m" "] papiGPU object creation failed. " \
           "\n");
  }

  // Insert GPU vertices
  printf ("\x1B[36m" "---Insert vertices---" "\x1B[0m" "\n");

  status = papiGPU_insert_vertices(object_id,
                                   2,
                                   vertex,
                                   state);

  if ((0 == status) && (GPU_VERTEX_INSERTED == *state)){
    printf("[\x1B[32m" "PASSED" "\x1B[0m" "] papiGPU vertices insertion " \
           "successfully completed\n");
  } else {
    printf("[\x1B[31m" "FAILED" "\x1B[0m" "] papiGPU vertices insertion failed. " \
           "\n");
  }

}


int main(){
  printf("\n..........................INITIALIZING API TESTING FOR papiGPU" \
         "..........................\n");

  test_papiGPU();

  return 0;
}
