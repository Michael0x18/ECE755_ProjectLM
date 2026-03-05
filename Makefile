VENV_DIR := long_man_venv
PYTHON := python3
PIP := $(VENV)/bin/pip

.PHONY: all test

all: test

$(VENV)/bin/activate: requirements.txt
	test -d $(VENV) || $(PYTHON) -m venv $(VENV_DIR)
	. $(VENV_DIR)/bin/activate && python3 -m pip install --upgrade pip 
	$(PIP) install -r requirements.txt
	touch $(VENV)/bin/activate

venv: $(VENV)/bin/activate

run: venv

clean:
	rm -rf $(VENV_DIR)
