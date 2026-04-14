# Project LM

## Setup
1. Make sure you have at least **Python3.13** installed and the following dependencies: 
    ```bash
    sudo apt install python3.13-dev
    sudo apt install podman
    ```
2. Pull in submodules: `git submodule update --init --recursive`.
3. Run `make venv` to setup the virtual environment.
4. Source the venv: `source long_man_venv/bin/activate`

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


## Synthesizing
```bash
make librelane
make klayout # Open the layout if librelane passes
```