# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

############# TX shift reg behavior ####################
# tx shift reg transmits values
#works across clock domains: user-side digital clock domain dictates 
#how/when values are loaded into the 64 bit register(?)
#note how the always block is on reg_clk, which in turn is the **or** of 
#the load_clk_gated and shift_clk

######## IO notes #############
#load_clk: clock signal of the synchronous circuit "feeding" data into the transmitter side
#rst_n: active low synchronous reset signal
#load_en: enable loading of the 64 bit value into the tx register
#load_data: 64 bit wide data to load
#shift_clk: signal that simply tells the shift register to shift right lol
#shift_data: 2 LSB (shifted out, LSB first?)
#


import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from cocotb.triggers import RisingEdge


async def run_shift_reg(dut,a,b):
    cocotb.log.info("start test_1")
    #deifne a clock for the synchronous digital side
    load_clock=Clock(dut.load_clk,a,unit="ps")
    load_task=cocotb.start_soon(load_clock.start())
    #deifne a clock for the asynchronous transmit side; NOTE: normally defined by the state machine, here just for testing
    shift_clock=Clock(dut.shift_clk,b,unit="ps")
    #initially set the driving values to the DUT
    dut.rst_n.value=0
    dut.load_en.value=1 
    dut.load_data.value=0
    dut.shift_clk.value=0
    await ClockCycles(dut.load_clk, 2)
    dut.rst_n.value=1
    expected=random.randint(0,(1<<4)-1)
    dut.load_data.value=expected
    await ClockCycles(dut.load_clk, 1)
    dut.load_en.value=0
    shift_task=cocotb.start_soon(shift_clock.start())
    bit_list=[]
    for i in range(32):
        bit_list.append(0)
    for i in range(32):
        await RisingEdge(dut.shift_clk)
        bit_list.insert(0,(dut.shift_data.value.integer))
    recieved=0
    for i,bits in enumerate(bit_list):
        recieved|=(bits<<(i*2))
    assert recieved==expected

    #after 32 clock cycles of this, should yield the "correct" val?

    #kill the previous 2 clocks?
    shift_task.kill()
    load_task.kill()
    #start the clock, wait for a few clock cycles
    cocotb.log.info("end test_1")

@cocotb.test()
async def test_2(dut):
    for _ in range(100):
        a=random.randint(1,25)*2
        b=random.randint(1,25)*2
        cocotb.log.info(f"esting a={a}ps,b={b}ps")
        await run_shift_reg(dut, a, b)





