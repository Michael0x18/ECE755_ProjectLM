# Project LM

## Running Testbenches
Run these commands in the `rtl/` directory to see the waveform from pulse_generator_tb:
```bash
vsim -voptargs=+acc work.tb_pulse_generator

# Run these in the QuestaSim terminal
vlib work
vlog -work work *.sv

add wave *
run -all
wave zoom full
```