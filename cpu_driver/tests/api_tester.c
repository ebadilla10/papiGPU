#include <stdio.h>
#include <api/cpu_driver.h>
#include <errno.h>

static void test_papiGPU_initialize(){
  printf ("\n\x1B[35m" "TESTING papiGPU Initialize " "\x1B[0m" ":\n");

  int status;
  gpu_portname empty_portname[] = "";
  //gpu_portname incorrect_portname[] = "/dev/ttyUSB9";
  //gpu_portname correct_portname[] = PORTNAME;
  enum papiGPU_states *state;

  // Send empty portname
  printf ("\x1B[36m" "---Send a empty portname---\n");
  status = papiGPU_initialize(empty_portname, state);

  if (status == EINVAL){
    printf("[\x1B[32m" "PASSED" "\x1B[0m" "] papiGPU initialization failed " \
           "due to empty portname \n");
  } else {
    printf("[\x1B[35m" "FAILED" "\x1B[0m" "] papiGPU initialization pass " \
           "with empty portname \n");
  }

}

int main(){
  printf("\n..........................INITIALIZING API TESTING FOR papiGPU" \
         "..........................\n");

  test_papiGPU_initialize();

  return 0;
}
