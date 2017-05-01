#include <stdio.h>
#include <api/cpu_driver.h>
#include <errno.h>

static void test_papiGPU_initialize(){
  printf ("\n\x1B[35m" "TESTING papiGPU Initialize " "\x1B[0m" ":\n");

  int status;
  gpu_portname empty_portname[] = "";
  gpu_portname incorrect_portname[] = "/dev/ttyUSB9";
  gpu_portname correct_portname[] = PORTNAME;
  enum papiGPU_states *state;
  enum papiGPU_states *state_null = NULL;

  // Send empty portname
  printf ("\x1B[36m" "---Send a empty portname---\n");
  status = papiGPU_initialize(empty_portname, state);

  if (status == EINVAL && (GPU_ERROR == *state)){
    printf("[\x1B[32m" "PASSED" "\x1B[0m" "] papiGPU initialization failed " \
           "due to empty portname \n");
  } else {
    printf("[\x1B[31m" "FAILED" "\x1B[0m" "] papiGPU initialization passed " \
           "with empty portname \n");
  }

  // Send an incorrect portname
  printf ("\x1B[36m" "---Send an incorrect portname---\n");
  status = papiGPU_initialize(incorrect_portname, state);

  if (status == ENODEV && (GPU_ERROR == *state)){
    printf("[\x1B[32m" "PASSED" "\x1B[0m" "] papiGPU initialization failed " \
           "due to incorrect portname \n");
  } else {
    printf("[\x1B[31m" "FAILED" "\x1B[0m" "] papiGPU initialization passed " \
           "with incorrect portname \n");
  }

  // Send a NULL state pointer with correct portname
  printf ("\x1B[36m" "---Send a NULL state pointer---\n");
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
  printf ("\x1B[36m" "---Send correct portname---\n");
  status = papiGPU_initialize(correct_portname, state);

  if ((0 == status) && (GPU_INITIALIZED == *state)){
    printf("[\x1B[32m" "PASSED" "\x1B[0m" "] papiGPU initialization " \
           "successfully completed\n");
  } else {
    printf("[\x1B[31m" "FAILED" "\x1B[0m" "] papiGPU initialization failed. " \
           "Check papiGPU conection.\n");
  }

}

int main(){
  printf("\n..........................INITIALIZING API TESTING FOR papiGPU" \
         "..........................\n");

  test_papiGPU_initialize();

  return 0;
}
