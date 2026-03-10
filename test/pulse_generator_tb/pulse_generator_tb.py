import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_1(dut):
    # Set the clock period to 10 ps (100 GHz)
    clock = Clock(dut.clk, 2, unit="ps")
    cocotb.start_soon(clock.start())

    dut.rx.value = 0
    await ClockCycles(dut.clk, 10)

    dut.rx.value = 1
    await ClockCycles(dut.clk, 10)

    dut.rx.value = 0
    await ClockCycles(dut.clk, 10)

    dut.rx.value = 1
    await ClockCycles(dut.clk, 10)


