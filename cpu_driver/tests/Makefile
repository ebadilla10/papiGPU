CXX=gcc
RM=rm -rf
INCLUDE=-I ../include
API_TESTER=api_tester
FLAGS=-lm

API_SRCS=../src/api/cpu_driver.c ../src/api/driver/i_cpu_driver.c ../src/api/utils/u_ieee754.c ../src/api/utils/u_uart.c
OBJS=$(subst .c,.o,$(API_SRCS))

all:
	@echo "usage:\033[1;33m make <test_name>\033[0m [without .c]"

api_tester:
	$(CXX) $(INCLUDE) $(API_SRCS) $(API_TESTER).c -o $(API_TESTER) $(FLAGS)

clean:
	$(RM) $(OBJS) $(API_TESTER)
