all: trombone

INCLUDES := -I/root/Bela/include -I/usr/xenomai/include
LDFLAGS := -L/root/Bela/lib
LDLIBS := /root/Bela/build/core/math_runfast.o -lbelaextra -lsndfile -lbela -lasound /root/Bela/lib/libNE10.a $(shell /usr/xenomai/bin/xeno-config --skin=native --ldflags)

debug: trombone.cpp
	clang++ trombone.cpp -std=c++11 -march=armv7-a -mtune=cortex-a8 -mfloat-abi=hard -mfpu=neon -ftree-vectorize -c -g $(INCLUDES)

%.o: %.cpp 
	clang++ -o "$@" "$<" -std=c++11 -O3 -march=armv7-a -mtune=cortex-a8 -mfloat-abi=hard -mfpu=neon -ftree-vectorize -c $(INCLUDES)

trombone: trombone.o default_main.o
	clang++ $(LDFLAGS) trombone.o default_main.o -o trombone $(LDLIBS)

