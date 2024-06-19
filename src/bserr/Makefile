CXX ?= g++
CXXFLAGS ?= -g0 -O3
LDFLAGS ?= -Wl,-O3

../../bin/bserr: bserr.cc
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -fopenmp -std=c++23 -o $@ $^
