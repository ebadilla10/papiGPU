CXX=gcc
RM=rm -rf
INCLUDE=-I ../include
API_TESTER=api_tester

API_SRCS=../src/api/cpu_driver.c ../src/api/driver/i_cpu_driver.c ../src/api/utils/u_ieee754.c
OBJS=$(subst .c,.o,$(API_SRCS))

all:
	@echo "usage:\033[1;33m make <test_name>\033[0m [without .c]"

api_tester:
	$(CXX) $(INCLUDE) $(API_SRCS) -o $(API_TESTER)

clean:
	$(RM) $(OBJS)

dist-clean: clean
	$(RM) $(BINNAME)
