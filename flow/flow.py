from openlane.flows import Flow
from pathlib import Path


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
    config={
        "DESIGN_NAME": "lm_chip_top",
        "VERILOG_FILES": sv_files,
        "CLOCK_PORT": "clk",
        "CLOCK_PERIOD": 10.0,
    },
    pdk="sky130A",
    pdk_root="/home/vedaant/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af",
    design_dir=".",
)

final_state, steps = flow.start()
