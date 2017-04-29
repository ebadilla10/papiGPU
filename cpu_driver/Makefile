CXX=gcc
RM=rm -rf
INCLUDE=-I ./include
BINNAME=papiGPU

API_SRCS=./api/cpu_driver.c ./api/driver/i_cpu_driver.c ./api/utils/u_ieee754.c
OBJS=$(subst .cpp,.o,$(API_SRCS))

all: papiGPU_driver

papiGPU_driver:
  $(CXX) $(INCLUDE) $(API_SRCS) -o $(BINNAME)

clean:
	$(RM) $(OBJS)

dist-clean: clean
	$(RM) $(BINNAME)
