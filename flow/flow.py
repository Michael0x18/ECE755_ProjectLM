from librelane.flows import Flow
from pathlib import Path
import json

with open("config.json") as f:
    config = json.load(f)

# convert 1's and 0's to Trues and Falses to work with librelane?
for key, value in config.items():
    if value == 1:
        config[key] = bool(1)
    if value == 0:
        config[key] = bool(0)

for key, value in config.items():
    print(key)
    print(value)

config["DESIGN_NAME"] = "tt_um_lm_chip_top"
config["VERILOG_FILES"] = ["dir::../src/lm_phy/*.sv", "dir::../src/chip_top/*.sv"]
config["DIE_AREA"] = None


def step_print(a, b):
    print(f"======{a}========")
    print(f"{b}")
    print(f"==========================\n")


src_dir = (Path(__file__).parent / "../src").resolve()
step_print("source dir", src_dir)
sv_files = [str(f) for f in src_dir.rglob("*.sv")]
print(sv_files)

Classic = Flow.factory.get("Classic")

flow = Classic(
    config=config,
    pdk="sky130A",
    pdk_root="/home/vedaant/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af",
    design_dir=".",
)

final_state, steps = flow.start()
