.ONESHELL:
.SILENT:
SHELL = bash
MAKEFLAGS += -j$(shell nproc)

PDK_ROOT := $(PWD)/../sky130pdk

TESTBENCHES := $(shell find . -maxdepth 1 -type d ! -name '.')

VENV_DIR ?= long_man_venv

.PHONY: all run-all $(TESTBENCHES)

all:

run-all: $(TESTBENCHES)

run-all-gates: $(TESTBENCHES:%=%-gates)

$(TESTBENCHES):
	. ../$(VENV_DIR)/bin/activate
	test -d ../test-out || mkdir ../test-out >/dev/null 2>&1
	$(MAKE) -C $@ 2>/dev/null >../test-out/$@.out && \
		printf "%s passed. Output located at ../test-out/%s.out\n" $@ $@ || \
		printf "%s testbench failed. Please look at ../test-out/%s.out\n" $@ $@
	printf "To view the waves, run \`make %s-waves\` inside the test directory\n\n" $@

%-gates:
	. ../$(VENV_DIR)/bin/activate
	PDK_ROOT=$(PDK_ROOT) $(MAKE) -C $* GATES=yes

%-waves:
	. ../$(VENV_DIR)/bin/activate
	$(MAKE) -C $* waves

clean:
	-rm -rf */__pycache__ */results.xml */*.vcd */sim_build
