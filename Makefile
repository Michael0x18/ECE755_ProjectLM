.ONESHELL:
SHELL = bash

VENV_DIR 	?= long_man_venv
PYTHON 		:= $(shell command -v python3.13 2>/dev/null || command -v python3)
PDK_ROOT 	?= sky130pdk
PDK 			?= sky130A

.PHONY: all help
all: help

help: SHELL=perl
help: .SHELLFLAGS=-e
help:
	@print <<~ 'EOF';
	Usage: make [command]
	
	Commands:
	  run, venv       Create the python virtual environment
	  pdk             (runs venv) Download the sky130 pdk
	  librelane       (runs venv) Run the LibreLane flow
	                  Run with 'env CONTAINER=...' to set container
	                  Defaults to rootless Podman
	EOF

$(VENV_DIR)/bin/activate: requirements.txt
	@test -d $(VENV_DIR) || $(PYTHON) -m venv $(VENV_DIR)
	@. $(VENV_DIR)/bin/activate
	@python3 -m pip install --upgrade pip 
	@pip install -r requirements.txt
	@touch $(VENV_DIR)/bin/activate

venv: $(VENV_DIR)/bin/activate

run: venv

$(PDK_ROOT)/$(PDK)/libs.ref/sky130_fd_sc_hd/verilog/primitives.v:
	@-mkdir $(PDK_ROOT)
	@PDK_ROOT=$(PDK_ROOT) $(PIP) install ciel
	@. $(VENV_DIR)/bin/activate 
	@ciel ls-remote --pdk-family=sky130 --pdk-root=$(PDK_ROOT) | \
		head -n1 | \
		xargs -I{} ciel enable --pdk-family=sky130 {} --pdk-root=$(PDK_ROOT)
	@touch $(PDK_ROOT)/$(PDK)/libs.ref/sky130_fd_sc_hd/verilog/primitives.v

pdk: venv $(PDK_ROOT)/$(PDK)/libs.ref/sky130_fd_sc_hd/verilog/primitives.v

.PHONY: clean
clean:
	@-rm -rf $(VENV_DIR) $(PDK_ROOT)

########################################
##                                    ##
##  Tiny Tapeout LibreLane Hardening  ##
##                                    ##
########################################

LIBRELANE_TAG := 3.0.0rc1
CONTAINER 		?= podman
TT_SKY_VENV		:= tt_venv

librelane: pdk tt_submodule tt_venv
	@echo 'This may take a while...'
	@. tt/$(TT_SKY_VENV)/bin/activate
	@./tt/tt_tool.py --create-user-config
	@env LIBRELANE_CONTAINER_ENGINE=$(CONTAINER) ./tt/tt_tool.py --harden

tt_submodule:
	@git submodule update --init --recursive

tt/$(TT_SKY_VENV)/bin/activate: tt/requirements.txt
	@cd tt
	@test -d $(TT_SKY_VENV) || $(PYTHON) -m venv $(TT_SKY_VENV)
	@. $(TT_SKY_VENV)/bin/activate
	@python3 -m pip install --upgrade pip
	@pip install -r requirements.txt
	@pip install librelane==$(LIBRELANE_TAG)
	@touch $(TT_SKY_VENV)/bin/activate

tt_venv: tt/$(TT_SKY_VENV)/bin/activate
