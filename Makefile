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
	  klayout         Open GDS in KLayout (only if librelane successful)
	EOF

.venv.stamp: requirements.txt
	@test -d $(VENV_DIR) || $(PYTHON) -m venv $(VENV_DIR)
	@. $(VENV_DIR)/bin/activate
	@python3 -m pip install --upgrade pip 
	@pip install -r requirements.txt
	@touch $@

venv: .venv.stamp

run: venv

.pdk.stamp:
	@-mkdir $(PDK_ROOT)
	@PDK_ROOT=$(PDK_ROOT) $(PIP) install ciel
	@. $(VENV_DIR)/bin/activate 
	@ciel ls-remote --pdk-family=sky130 --pdk-root=$(PDK_ROOT) | \
		head -n1 | \
		xargs -I{} ciel enable --pdk-family=sky130 {} --pdk-root=$(PDK_ROOT)
	@touch $@

pdk: .venv.stamp .pdk.stamp

.PHONY: clean
clean:
	@-rm -rf $(VENV_DIR) $(PDK_ROOT) runs .*.stamp

########################################
##                                    ##
##  Tiny Tapeout LibreLane Hardening  ##
##                                    ##
########################################

LIBRELANE_TAG := 3.0.0rc1
CONTAINER 		?= podman
TT_SKY_VENV		:= tt_venv

librelane: .librelane.stamp

librelane-force:
	@-rm .librelane.stamp
	@$(MAKE) librelane

.PHONY: klayout
klayout: librelane
	@. tt/$(TT_SKY_VENV)/bin/activate
	@env LIBRELANE_CONTAINER_ENGINE=$(CONTAINER) ./tt/tt_tool.py --open-in-klayout

.librelane.stamp: .pdk.stamp .tt_venv.stamp
	@echo 'This may take a while...'
	@. tt/$(TT_SKY_VENV)/bin/activate
	@test -f src/user_config.json || ./tt/tt_tool.py --create-user-config
	@env LIBRELANE_CONTAINER_ENGINE=$(CONTAINER) ./tt/tt_tool.py --harden
	@touch $@

tt_submodule: .tt_submodule.stamp

.tt_submodule.stamp:
	@git submodule update --init --recursive
	@touch $@

.tt_venv.stamp: tt/requirements.txt
	@cd tt
	@test -d $(TT_SKY_VENV) || $(PYTHON) -m venv $(TT_SKY_VENV)
	@. $(TT_SKY_VENV)/bin/activate
	@python3 -m pip install --upgrade pip
	@pip install -r requirements.txt
	@pip install librelane==$(LIBRELANE_TAG)
	@touch $@

tt_venv: .tt_submodule.stamp .tt_venv.stamp
