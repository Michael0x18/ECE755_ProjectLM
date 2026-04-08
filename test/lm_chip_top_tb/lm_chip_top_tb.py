# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from cocotb.triggers import FallingEdge, RisingEdge


WIDTH = 16

async def send_data(dut, data):
    
    dut.MOSI.value = 1
    
    for i in range(WIDTH):
        await FallingEdge(dut.SCLK)
        dut.MOSI.value = (data >> i) & 0x1
    
    await FallingEdge(dut.SCLK)
    
    dut.MOSI.value = 0
    
async def recieve_data(dut):

    val_arr = []
    
    for i in range(WIDTH):
        await FallingEdge(dut.SCLK)
        val_arr.append(int(dut.MISO.value))
    
    val_arr.reverse()
    
    val = 0
    
    for b in val_arr:
        val = (val << 1) | b
        
    await FallingEdge(dut.SCLK)
    return val


async def pulse(clk, signal):
    await RisingEdge(clk)
    signal.value = 1
    await RisingEdge(clk)
    signal.value = 0


# async def run_test(dut, data):

@cocotb.test()
async def test_1(dut):

    DATA = 0xBEEF

    cocotb.log.info("Starting Test 1... Sending 0x%04X", DATA)


    # Start a 1GHz driving sync clock. This is still stupidly fast compared to what we're actually going to use
    clock = Clock(dut.clk, 1,unit="ns")
    cocotb.start_soon(clock.start())

    dut.rst_n.value = 0
    dut.MOSI.value = 0
    dut.SCLK.value = 0
    dut.CAPTURE.value = 0
    
    dut.RDY.value = 0
    dut.LOAD.value = 0

    await ClockCycles(dut.clk, 2)
    
    dut.rst_n.value = 1
    
    await ClockCycles(dut.clk, 2)
    
    
    sclk = Clock(dut.SCLK, 20, unit='ns')
    cocotb.start_soon(sclk.start())
    
    # 1. Send data over SPI
    await send_data(dut, 0xBEEF)

    # 2. Pulse LOAD
    cocotb.log.info("BEFORE pulse LOAD")
    await pulse(dut.clk, dut.LOAD)

    # 3. Wait for RX to assert VLD
    cocotb.log.info("BEFORE wait VLD")
    await RisingEdge(dut.VLD)

    # 4. Pulse CAPTURE
    cocotb.log.info("BEFORE pulse CAPTURE")
    await pulse(dut.clk, dut.CAPTURE)

    # 5. Pulse RDY
    await pulse(dut.clk, dut.RDY)

    # 6. Wait for TX to assert DONE
    await RisingEdge(dut.DONE)

    # 7. Output recieved data over SPI
    recieved_data = await recieve_data(dut)
    cocotb.log.info("Recieved: 0x%04X", recieved_data)