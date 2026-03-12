# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from cocotb.triggers import RisingEdge
from cocotb.triggers import Timer

######### IO of lm_phy_tx #############
#clk
#rst_n
#tx_in[63:0]
#tx_load
#out: tx_done
#out: [3:0] TX
#in: TX_ACK (IMPORTANT, VARY THESE TIMINGS TO SEE HOW IT ACTS)

#method to give some random timings to the TX_ACK signal
async def rand_ack(dut):
    dut.TX_ACK.value=0
    pulse_width=random.randint(4,20)
    cool_off=random.randint(5,50)
    dut.TX_ACK.value=1
    await Timer(pulse_width,unit="ps")
    dut.TX_ACK.value=0
    await Timer(cool_off,unit="ps")
    pass
@cocotb.test()
async def test_1(dut):
    cocotb.log.info("start test 1")
    #create the driving synchronous clock
    clock=Clock(dut.clk,4,unit="ps")
    start_clock=cocotb.start_soon(clock.start())
    dut.TX_ACK.value=0
    dut.rst_n.value=1
    dut.tx_in.value=18934712980471211
    dut.tx_load.value=1

#reset sequence
    await ClockCycles(dut.clk,1)

    dut.rst_n.value=0

    await ClockCycles(dut.clk,1)

    dut.rst_n.value=1

    await ClockCycles(dut.clk,1)

    #load sequence
    dut.tx_load.value=0
    await ClockCycles(dut.clk,10)
    for _ in range(40):
       await rand_ack(dut)
    cocotb.log.info("end test 1")
    pass


