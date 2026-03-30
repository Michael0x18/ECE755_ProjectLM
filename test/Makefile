
PDK_ROOT := $(PWD)/../sky130pdk

TESTBENCHES := $(shell find . -maxdepth 1 -type d ! -name '.')

.PHONY: all run-all $(TESTBENCHES)

all:

run-all: $(TESTBENCHES)

run-all-gates: $(TESTBENCHES:%=%-gates)

$(TESTBENCHES):
	$(MAKE) -C $@

%-gates:
	PDK_ROOT=$(PDK_ROOT) $(MAKE) -C $* GATES=yes

%-waves:
	$(MAKE) -C $* waves