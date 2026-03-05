# Project LM

## Setup
Run `make venv` to setup the virtual environment

## Running Testbenches
(WIP!) Run `make test` to run all testbenches simutaneously.

To run one test at a time, activate the python virtual environment (`source long_man_venv/bin/activate` if on sh/bash/zsh or `source long_man_venv/bin/activate.fish` if on fish), then run the following command inside the `test/` directory
```bash
# This command will run one specific test
make (testbench dir name)

# This command will run all testbenches
make run-all
```
