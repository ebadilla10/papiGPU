#include <stdio.h>
#include <api/cpu_driver.h>
#include <api/types/papiGPU_types.h>
#include <errno.h>

main(){
  printf("%sINITIALIZING API TESTING...\n");

  test_papiGPU_initialize();
}

static void test_papiGPU_initialize(){
  printf ("TESTING\x1B[35m" "papiGPU Initialize " "\x1B[0m" ":\n");

  int status;
  gpu_portname portname[];
  enum papiGPU_states *state;

  // Send empty portname
  portname[] = ""
  status = papiGPU_initialize(portname[], state);

  if (status == EINVAL){
    printf("[\x1B[32m" "PASSED" "\x1B[0m" "] papiGPU initialization failed due \
           to empty portname \n");
  } else {
    printf("[\x1B[35m" "FAILED" "\x1B[0m" "] papiGPU initialization pass with \
           empty portname \n");
  }

}
