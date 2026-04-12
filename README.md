# Project LM

## Setup
Run `make venv` to setup the virtual environment

## Running Testbenches
(WIP!) Run `make test` to run all testbenches simutaneously.

To run one test at a time, activate the python virtual environment (`source long_man_venv/bin/activate` if on sh/bash/zsh or `source long_man_venv/bin/activate.fish` if on fish), then run the following command inside the `test/` directory
```bash
# This command will run one specific test
make (testbench dir name)

# If you are using questa, you can instead run this for one specific test
make SIM=questa (testbench dir name)

# This command will run all testbenches
make run-all
```

To view the output waveform, run:
```bash
gtkwave (testbench dir name)/(testbench_name).vcd
```