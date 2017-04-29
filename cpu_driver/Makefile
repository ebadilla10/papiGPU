CXX=gcc
RM=rm -rf
INCLUDE=-I ./include
BINNAME=papiGPU

API_SRCS=./src/api/cpu_driver.c ./src/api/driver/i_cpu_driver.c ./src/api/utils/u_ieee754.c
OBJS=$(subst .c,.o,$(API_SRCS))

all: papiGPU_driver

papiGPU_driver:
	$(CXX) $(INCLUDE) $(API_SRCS) -o $(BINNAME)

clean:
	$(RM) $(OBJS)

dist-clean: clean
	$(RM) $(BINNAME)
