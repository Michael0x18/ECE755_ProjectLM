# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from cocotb.triggers import RisingEdge
from cocotb.triggers import Edge
from cocotb.triggers import Timer

######### IO of lm_phy_top #############
# input wire clk,
# input wire rst_n,
# 
# // TX chip side interface
# input wire[WIDTH-1:0] tx_in,
# input wire tx_load,
# output wire tx_done,
# 
# // RX chip side interface
# output wire[WIDTH-1:0] rx_out,
# output wire rx_vld,
# input wire rx_rdy,
# 
# // TX off chip interface
# output wire[3:0] TX,
# input wire TX_ACK,
# 
# // TX off chip interface
# input wire[3:0] RX,
# output wire RX_ACK

async def reset(dut):
    dut.rst_n.value=0
    dut.tx_in.value=0x0

    dut.rx_rdy.value = 0
    dut.tx_load.value = 0

    await ClockCycles(dut.clk, 2)
    
    dut.rst_n.value=1
    
    await ClockCycles(dut.clk,1)
    
async def send_data(dut, data):
    dut.tx_in.value = data;
    await ClockCycles(dut.clk, 1)
    
    dut.tx_load.value = 1
    await ClockCycles(dut.clk, 100)

    #load sequence
    dut.tx_load.value=0
    
    for _ in range(7):
        await Edge(dut.TX_ACK)
        
    await ClockCycles(dut.clk, 100);
    
    dut.rx_rdy.value = 1

    await Edge(dut.TX_ACK)
    await ClockCycles(dut.clk, 5);
    
    dut.rx_rdy.value = 0

@cocotb.test()
async def test_1(dut):
    cocotb.log.info("start test 1: sending data only once after reset")
    clock=Clock(dut.clk,1,unit="ns")
    cocotb.start_soon(clock.start())

    await reset(dut)

    await send_data(dut, 0xBEEF)
    
    assert(dut.tx_done.value == 1);
    assert(dut.rx_out.value == dut.tx_in.value);

    cocotb.log.info("end test 1")


@cocotb.test()
async def test_2(dut):
    cocotb.log.info("start test 2: sending multiple data after reset")
    clock = Clock(dut.clk, 1, unit='ns')
    cocotb.start_soon(clock.start())
    
    await reset(dut)
    
    await send_data(dut, 0x9922)
    
    assert(dut.tx_done.value == 1);
    assert(dut.rx_out.value == dut.tx_in.value);
    
    await send_data(dut, 0x1234)
    
    assert(dut.tx_done.value == 1);
    assert(dut.rx_out.value == dut.tx_in.value);
    
    cocotb.log.info("end test 2")
    