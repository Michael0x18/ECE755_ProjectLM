VENV_DIR := long_man_venv
PYTHON := python3
PIP := $(VENV_DIR)/bin/pip

.PHONY: all test

all: test

$(VENV_DIR)/bin/activate: requirements.txt
	test -d $(VENV_DIR) || $(PYTHON) -m venv $(VENV_DIR)
	. $(VENV_DIR)/bin/activate && python3 -m pip install --upgrade pip 
	$(PIP) install -r requirements.txt
	touch $(VENV_DIR)/bin/activate

venv: $(VENV_DIR)/bin/activate

run: venv

clean:
	rm -rf $(VENV_DIR)
