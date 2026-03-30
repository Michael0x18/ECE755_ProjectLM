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

@cocotb.test()
async def test_1(dut):
    cocotb.log.info("start test 1")
    clock=Clock(dut.clk,1,unit="ns")
    start_clock=cocotb.start_soon(clock.start())
    dut.rst_n.value=0
    dut.tx_in.value=0xBEEF

    dut.rx_rdy.value = 0
    dut.tx_load.value = 0

    await ClockCycles(dut.clk,1000)

    dut.rst_n.value=1

    await ClockCycles(dut.clk,1)
    await ClockCycles(dut.clk,1)
    await ClockCycles(dut.clk,1)
    await ClockCycles(dut.clk,1)
    await ClockCycles(dut.clk,1)

    dut.tx_load.value = 1;
    await ClockCycles(dut.clk, 100)

    #load sequence
    dut.tx_load.value=0

    await ClockCycles(dut.clk, 5000);

    cocotb.log.info("end test 1")
    pass


