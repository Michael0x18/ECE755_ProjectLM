import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer


async def reset_dut(dut):
    dut.rst_n.value = 0
    dut.rdy.value = 0
    dut.rx_pulse.value = 0
    await Timer(20, unit="ps")
    dut.rst_n.value = 1
    await Timer(10, unit="ps")


async def send_rx_pulses(dut, n, period_ps=20):
    for _ in range(n):
        dut.rx_pulse.value = 1
        await Timer(5, unit="ps")
        dut.rx_pulse.value = 0
        await Timer(period_ps, unit="ps")


@cocotb.test()
async def test_1(dut):

    clock = Clock(dut.clk, 2, unit="ps")
    cocotb.start_soon(clock.start())

    await reset_dut(dut)
    assert dut.vld.value == 0, "vld should be 0 after reset"

    # send 15 pulses, vld should NOT assert yet
    await send_rx_pulses(dut, 15)
    assert dut.vld.value == 0, f"vld asserted too early after 15 pulses"

    # 16th pulse — vld should assert
    await send_rx_pulses(dut, 1)
    await Timer(5, unit="ps")  # small settle time
    dut.rdy.value=1
    await Timer(5,unit='ps')
    dut.rdy.value=0
    await send_rx_pulses(dut, 15)
   # assert dut.vld.value == 0, f"vld asserted too early after 15 pulses"

    # 16th pulse — vld should assert
    await send_rx_pulses(dut, 1)
   # assert dut.vld.value == 1, "vld should be asserted after 16 pulses"

