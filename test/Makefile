

TESTBENCHES := $(shell find . -maxdepth 1 -type d ! -name '.')

.PHONY: all run-all $(TESTBENCHES)

all:

run-all: $(TESTBENCHES)

$(TESTBENCHES):
	$(MAKE) -C $@

