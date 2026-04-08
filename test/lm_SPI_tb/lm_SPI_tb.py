# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from cocotb.triggers import FallingEdge

######### IO of lm_SPI #############
#   // clock and active low reset
#   input wire clk,
#   input wire rst_n,
#   // Standard SPI signals
#   input wire MOSI_async,
#   output reg MISO,
#   input wire SCLK_async,
#   // TX related signals
#   output reg [WIDTH-1:0] tx_data,   // Holds tx_data to be sent to lm_TOP
#   // RX related signals
#   input wire send_rx,               // Asserted by lm_TOP to initiate MISO line
#   input wire [WIDTH-1:0] rx_data    // Holds rx_data to be sent out of board

WIDTH = 16

async def send_data(dut, data):
    
    dut.MOSI_async.value = 1
    
    for i in range(WIDTH):
        await FallingEdge(dut.SCLK_async)
        dut.MOSI_async.value = (data >> i) & 0x1
    
    await FallingEdge(dut.SCLK_async)
    
    dut.MOSI_async.value = 0
    
async def recieve_data(dut, data):
    dut.rx_data.value = data
    dut.send_rx.value = 1
    
    await ClockCycles(dut.clk, 1)
    
    val_arr = []
    
    for i in range(WIDTH):
        await FallingEdge(dut.SCLK_async)
        val_arr.append(int(dut.MISO.value))
    
    val_arr.reverse()
    
    val = 0
    
    for b in val_arr:
        val = (val << 1) | b
        
    await FallingEdge(dut.SCLK_async)
    return val

@cocotb.test()
async def test_1(dut):
    cocotb.log.info("start test 1: send data to PHY only")
    #create the driving synchronous clock
    # Start a 1GHz clock. This is still stupidly fast compared to what we're actually going to use
    clock = Clock(dut.clk, 1,unit="ns")
    cocotb.start_soon(clock.start())

    dut.rst_n.value = 0
    
    dut.MOSI_async.value = 0
    dut.SCLK_async.value = 0
    
    dut.send_rx.value = 0
    dut.rx_data.value = 0
    
    await ClockCycles(dut.clk, 2)
    
    dut.rst_n.value = 1
    
    await ClockCycles(dut.clk, 2)
    
    
    sclk = Clock(dut.SCLK_async, 20, unit='ns')
    cocotb.start_soon(sclk.start())
    
    await send_data(dut, 0xBEEF)
    
    await ClockCycles(dut.clk, 100)
    
@cocotb.test()
async def test_2(dut):
    cocotb.log.info("start test 2: recieve data from PHY only")
    #create the driving synchronous clock
    # Start a 1GHz clock. This is still stupidly fast compared to what we're actually going to use
    clock = Clock(dut.clk, 1,unit="ns")
    cocotb.start_soon(clock.start())

    dut.rst_n.value = 0
    
    dut.MOSI_async.value = 0
    dut.SCLK_async.value = 0
    
    dut.send_rx.value = 0
    dut.rx_data.value = 0
    
    await ClockCycles(dut.clk, 2)
    
    dut.rst_n.value = 1
    
    await ClockCycles(dut.clk, 2)
    
    sclk = Clock(dut.SCLK_async, 20, unit='ns')
    cocotb.start_soon(sclk.start())
    
    ret = await recieve_data(dut, 0xBEEF)
    
    await ClockCycles(dut.clk, 100)
    
    cocotb.log.info("Recieved: 0x%04X", ret)