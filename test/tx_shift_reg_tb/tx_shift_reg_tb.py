# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

############# TX shift reg behavior ####################
# tx shift reg transmits values
#works across clock domains: user-side digital clock domain dictates 
#how/when values are loaded into the 64 bit register(?)
#note how the always block is on reg_clk, which in turn is the **or** of 
#the load_clk_gated_gated and shift_clk

######## IO notes #############
#load_clk_gated: clock signal of the synchronous circuit "feeding" data into the transmitter side
#rst_n: active low synchronous reset signal
#load_en: enable loading of the 64 bit value into the tx register
#load_data: 64 bit wide data to load
#shift_clk: signal that simply tells the shift register to shift right lol
#shift_data: 2 LSB (shifted out, LSB first?)
#


import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge

@cocotb.test()
async def test_1(dut):
    clock = Clock(dut.clk, 2, unit='ps')
    cocotb.start_soon(clock.start())

    dut.rst_n.value = 0
    dut.load_data.value = 0
    dut.load_clk_gated.value = 0
    dut.load_en.value = 0
    dut.shift_clk.value = 0

    await ClockCycles(dut.clk, 4)

    dut.rst_n.value = 1

    await ClockCycles(dut.clk, 4)

    random_data = random.getrandbits(64)
    dut.load_data.value = random_data

    await ClockCycles(dut.clk, 2)

    load_clk_gated = Clock(dut.load_clk_gated, 2, unit='ps')
    cocotb.start_soon(load_clk_gated.start())
    dut.load_en.value = 1

    await ClockCycles(dut.clk, 1)

    load_clk_gated.stop()
    dut.load_en.value = 0
    dut.load_clk_gated.value = 0

    await ClockCycles(dut.clk, 4)

    shift_clk = Clock(dut.shift_clk, 6, unit='ps', period_high=2)
    cocotb.start_soon(shift_clk.start())

    for i in range(32):
        await RisingEdge(dut.shift_clk)
        dut._log.info(f"Actual value: {(random_data & (0b11 << (2*i))) >> ((2*i))}; Expected value: {int(dut.shift_data.value)}") 
        assert(dut.shift_data.value == int((random_data & (0b11 << (2*i))) >> ((2*i))))

    





