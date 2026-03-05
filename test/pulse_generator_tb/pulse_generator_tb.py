# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

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


