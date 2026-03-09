VENV_DIR := long_man_venv
PYTHON := python3
PIP := $(VENV_DIR)/bin/PIP
PDK_ROOT := sky130pdk

.PHONY: all test

all: test

$(VENV_DIR)/bin/activate: requirements.txt
	test -d $(VENV_DIR) || $(PYTHON) -m venv $(VENV_DIR)
	. $(VENV_DIR)/bin/activate && python3 -m pip install --upgrade pip 
	$(PIP) install -r requirements.txt
	touch $(VENV_DIR)/bin/activate

venv: $(VENV_DIR)/bin/activate

run: venv

$(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v:
	-mkdir $(PDK_ROOT)
	PDK_ROOT=$(PDK_ROOT) $(PIP) install ciel
	. $(VENV_DIR)/bin/activate && \
		ciel ls-remote --pdk-family=sky130 --pdk-root=$(PDK_ROOT) | \
		head -n1 | \
		xargs -I{} ciel enable --pdk-family=sky130 {} --pdk-root=$(PDK_ROOT)
	touch $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v

pdk: venv $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v

clean:
	rm -rf $(VENV_DIR) $(PDK_ROOT)
