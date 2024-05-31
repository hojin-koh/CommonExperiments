CXX ?= g++
CXXFLAGS ?= -g0 -O3
LDFLAGS ?= -Wl,-O3

../../bin/mmseg: main.cc
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -Immseg/ -std=c++23 -o $@ $^
