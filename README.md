# Project LM
> [!CAUTION]
> While this flow works on our own machines, errors are very common.\
> You are on your own if you encounter any errors while replicating.

> [!WARNING]
> This flow was executed on Linux/x86_64 and MacOS Sequoia.\
> We cannot guarantee this flow will work for Windows or other OSes.

## Dependencies
### Linux
- make
- gtkwave
- iverilog        (or other RTL simulator. See section 3 for more details)
- podman          (or other Container software. See section 2 for details)
- python3.13
- python3.13-dev  (on Ubuntu only(?))

ArchLinux:
```bash
yay -Syu make gtkwave iverilog podman python313
```

Ubuntu:
```bash
sudo apt install make gtkwave iverilog podman python3.13 python3.13-dev
```

### MacOS (via Brew)
- gmake           (aliasing make=gmake will only make your life easier)
- gtkwave
- iverilog        (or other RTL simulator. See section 3 for more details)
- klayout         (Python's KLayout doesn't work on MacOS)
- podman          (or other Container software. See section 2 for details)
- python          (latest - 3.9.X - seems to work fine)

```bash
brew install gmake iverilog podman python --cask gtkwave klayout
```

## Using the Makefile
By running `make` or `make help`, you will see a list and small description of the following runnable commands.

### Virtual Environment
Running `make venv` will intialize the Python virtual environment.\
This target is a prerequisite to all other targets, so it will be run regardless.

### Testing
Running `make test` will run all testbenches simultaneously and dump their outputs into `./test-out/`.\
Running `env DBG=1 make test` will output everything to stdout and stderr instead.\
More information on testbenches in the next section.

### Process Design Kit
Running `make pdk` will download the Skywater 130nm PDK from the *ciel* library into `./sky130pdk/`.\
This target is needed for gate level testing and is a prerequisite to the following targets.

### Tiny Tapeout's LibreLane Flow
> [!WARNING]
> You must have rootless Podman or rootless Docker to run this LibreLane flow.\
> For Podman, start podman.socket with SystemD or follow [Podman's official tutorial.](https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md)\
> For Docker, you must add yourself to the docker group with `groupadd docker; sudo usermod -aG docker $USER`. Read more from [Docker themself.](https://docs.docker.com/engine/security/rootless/)

Running `make librelane` will pull the Tiny Tapeout's local hardenning GitHub as a submodule.\
It will then run the LibreLane flow. This will take a while for the first run to download all prerequisites. Subsequent runs will be shorter, but still a couple minutes.\
This can cause many unexpected errors, thus is recommended to run at your own precation.

### KLayout GDS Viewing
Running `make klayout` will open the GDS file with the python version of KLayout only if `make librelane` was successful.

> [!WARNING]
> The Python version of KLayout doesn't seem to work on MacOS. Instead, you must install KLayout locally and then
> open the file ./runs/wokwi/final/klayout_gds/*.gds inside KLayout. Note that MacOS thinks it's an insecure app
> by default, so you must allow opening in the privacy and security settings. The same for GTKWave.

## More on Testbenches
For more controlled testing, CD into the `./test` directory (`cd test`). Note that you **do not** need to source the Python virtual environment before doing so. The internal Makefile will handle that for you.\
You now have access to the following commands.
```bash
# Run a single test bench and output to ../test-out/(testbench directory name).out
make (testbench directory name)

# To output to stdout and stderr, set the DBG environment to anything
env DBG=1 make (testbench directory name)

# If you are using another RTL simulator, set the SIM environment variable
# e.g., to run with QuestaSim
env SIM=questa make (testbench dir name)

# Run all testbenches at once (max parallel by default)
make run-all

# If you plan on setting DBG with run-all, it is highly recommended to disable parallel
env DBG=1 make -j1 run-all

# (WIP) Run a gate level simulation instead of RTL simulation
make (testbench directory name)-gates
# or
env GATES=yes PDK_ROOT=../sky130pdk make (testbench directory name)

# Currently, gate level simulation only works on lm_chip_top_tb once
# the LibreLane flow is successful.
```

To view the output waveform for any testbench, run:
```bash
make (testbench directory name)-waves
# or
gtkwave (testbench directory name)/(testbench_name).vcd
```

## Cleaning
As per usual, `make clean` will clean the directory completely.\
Note that this will remove **everything**, so the next LibreLane run will take a long time again.
