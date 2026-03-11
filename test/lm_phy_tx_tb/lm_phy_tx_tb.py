# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from cocotb.triggers import RisingEdge
from cocotb.triggers import FallingEdge
from cocotb.triggers import Timer
from cocotb.triggers import First

######### IO of lm_phy_tx #############
#clk
#rst_n
#tx_in[63:0]
#tx_load
#out: tx_done
#out: [3:0] TX

async def rand_ack(dut):
    # TX ack is NOT just a random clock that toggles pulses.
    dut.TX_ACK.value = 0
    i = 0
    while True:
        await First(RisingEdge(dut.TX0),RisingEdge(dut.TX1),RisingEdge(dut.TX2),RisingEdge(dut.TX3),FallingEdge(dut.TX0),FallingEdge(dut.TX1),FallingEdge(dut.TX2),FallingEdge(dut.TX3))
        await Timer(random.randint(12,48), units="ns")
        i = i ^ 1;
        dut.TX_ACK.value = i

@cocotb.test()
async def test_1(dut):
    cocotb.log.info("start test 1")
    #create the driving synchronous clock
    # Start a 1GHz clock. This is still stupidly fast compared to what we're actually going to use
    clock=Clock(dut.clk, 1,unit="ns")
    start_clock=cocotb.start_soon(clock.start())

    # At time t=0, hold chip in reset. Do not assert any other signals.
    dut.tx_in.value=18934712980471211
    dut.tx_load.value=0
    dut.rst_n.value=0

    # Hold reset for 5 cycles. Then release
    await ClockCycles(dut.clk,5)
    dut.rst_n.value=1
    # Wait five cycles so we don't send immediately. Because that is unrealistic.
    await ClockCycles(dut.clk,5)
    cocotb.start_soon(rand_ack(dut))
    await ClockCycles(dut.clk,5)

    dut.tx_load.value=1
    await ClockCycles(dut.clk,1)
    dut.tx_load.value=0

    await RisingEdge(dut.tx_done)
    await ClockCycles(dut.clk, 50)

    cocotb.log.info("end test 1")
    pass


