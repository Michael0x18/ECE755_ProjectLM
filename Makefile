.ONESHELL:
.SILENT:
SHELL = bash
MAKEFLAGS += -j4

VENV_DIR 	?= long_man_venv
PYTHON 		:= $(shell command -v python3.13 2>/dev/null || command -v python3)
PIP				?= $(VENV_DIR)/bin/pip
PDK_ROOT 	?= sky130pdk
PDK 			?= sky130A

.PHONY: all help
all: help

help: SHELL=perl
help: .SHELLFLAGS=-e
help:
	print <<~ 'EOF';
	Usage: make [command]
	
	Commands:
	  venv            Create the python virtual environment
	  pdk             (runs venv) Download the sky130 pdk
	  librelane       (runs venv) Run the LibreLane flow
	                  Run with 'env CONTAINER=...' to set container
	                  Defaults to rootless Podman
	  klayout         Open GDS in KLayout (only if librelane successful)
	EOF

venv: $(PIP)

$(PIP): requirements.txt
	echo "Initializing venv... this shouldn't take too long"
	{
		test -d $(VENV_DIR) || $(PYTHON) -m venv $(VENV_DIR)
		. $(VENV_DIR)/bin/activate
		python3 -m pip install --upgrade pip 
		pip install -r requirements.txt
	} >/dev/null 2>&1
	echo "Venv created successfully."

pdk: $(PDK_ROOT)/ciel/sky130/versions/*/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v

$(PDK_ROOT)/ciel/sky130/versions/*/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v: | $(PIP)
	echo "Installing pdk... this may take a while"
	{
		-mkdir $(PDK_ROOT)
		. $(VENV_DIR)/bin/activate 
		PDK_ROOT=$(PDK_ROOT) $(PIP) install ciel
		ciel ls-remote --pdk-family=sky130 --pdk-root=$(PDK_ROOT) | \
			head -n1 | \
			xargs -I{} ciel enable --pdk-family=sky130 {} --pdk-root=$(PDK_ROOT)
	} >/dev/null 2>&1
	echo "PDK installed successfully"

.PHONY: clean
clean:
	-rm -rf $(VENV_DIR) $(PDK_ROOT) runs .*.stamp ports.json
	git submodule deinit --all -f >/dev/null 2>&1
	$(MAKE) -C test $@ >/dev/null 2>&1

########################################
##                                    ##
##  Tiny Tapeout LibreLane Hardening  ##
##                                    ##
########################################

LIBRELANE_TAG := 3.0.0rc1
CONTAINER 		?= podman
TT_SKY_VENV		:= tt_venv
TT_SKY_PIP		:= tt/$(TT_SKY_VENV)/bin/pip

librelane: runs/wokwi/final/commit_id.json src/*/*.*v

librelane-force:
	touch runs/wokwi/final/commit_id.json
	$(MAKE) librelane

.PHONY: klayout
klayout: | librelane
	. tt/$(TT_SKY_VENV)/bin/activate
	env LIBRELANE_CONTAINER_ENGINE=$(CONTAINER) ./tt/tt_tool.py --open-in-klayout

runs/wokwi/final/commit_id.json: src/user_config.json | pdk
	. tt/$(TT_SKY_VENV)/bin/activate
	env LIBRELANE_CONTAINER_ENGINE=$(CONTAINER) ./tt/tt_tool.py --harden
	touch $@

src/user_config.json: info.yaml | $(TT_SKY_PIP)
	echo "Creating user config..."
	{
		. tt/$(TT_SKY_VENV)/bin/activate
		./tt/tt_tool.py --create-user-config
	} >/dev/null

$(TT_SKY_PIP): tt/requirements.txt 
	echo "Installing Tiny Tapeout venv... this may take a while"
	{
		cd tt
		test -d $(TT_SKY_VENV) || $(PYTHON) -m venv $(TT_SKY_VENV)
		. $(TT_SKY_VENV)/bin/activate
		python3 -m pip install --upgrade pip
		pip install -r requirements.txt
		pip install librelane==$(LIBRELANE_TAG)
	} >/dev/null || {
		echo "It seems the venv failed. Please use google to solve any problems."
	} && echo "Tiny Tapeout venv created successfully."

tt/requirements.txt:
	echo "Initializing Tiny Tapeout submodule..."
	git submodule update --init --recursive >/dev/null 2>&1
