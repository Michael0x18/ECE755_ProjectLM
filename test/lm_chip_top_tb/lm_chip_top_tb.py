# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from cocotb.triggers import FallingEdge, RisingEdge, Timer, Edge


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
        
    await RisingEdge(dut.SCLK)
    return val


async def pulse(clk, signal):
    await RisingEdge(clk)
    signal.value = 1
    await RisingEdge(clk)
    signal.value = 0



async def loopback_tx(dut, delay_ns=5):
    while True:
        await dut.TX.value_change   # Wait for ANY change

        val = dut.TX.value
        # Launch delayed update (don’t block loop)
        cocotb.start_soon(delayed_tx(dut, val, delay_ns))

        await Timer(0.1, unit="ns") # Brief wait so non-blocking


async def delayed_tx(dut, val, delay_ns):
    await Timer(delay_ns, unit="ns")
    dut.RX.value = val


async def loopback_ack(dut, delay_ns=5):
    while True:
        await dut.RX_ACK.value_change

        val = dut.RX_ACK.value
        # Launch delayed update (don’t block loop)
        cocotb.start_soon(delayed_ack(dut, val, delay_ns))

        await Timer(0.1, unit="ns") # Brief wait so non-blocking


async def delayed_ack(dut, val, delay_ns):
    await Timer(delay_ns, unit="ns")
    dut.TX_ACK.value = val


async def run_test(dut, data, delay_ns, reset=True):
    cocotb.log.info("Starting Test ... Sending 0x%04X", data)

    # Start a 1GHz driving sync clock. This is still stupidly fast compared to what we're actually going to use
    clock = Clock(dut.clk, 1,unit="ns")
    cocotb.start_soon(clock.start())

    # Start loopbacks
    cocotb.start_soon(loopback_tx(dut, delay_ns))
    cocotb.start_soon(loopback_ack(dut, delay_ns))


    if(reset):
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
    await send_data(dut, data)

    # 2. Pulse LOAD
    await pulse(dut.clk, dut.LOAD)

    # 3. Wait for RX to assert VLD
    await RisingEdge(dut.VLD)

    # 4. Pulse CAPTURE
    await pulse(dut.clk, dut.CAPTURE)

    # 5. Pulse RDY
    await pulse(dut.clk, dut.RDY)

    # 6. Wait for TX to assert DONE
    await RisingEdge(dut.DONE)

    # 7. Output recieved data over SPI
    recieved_data = await recieve_data(dut)

    assert recieved_data == data, f"Expected 0x{data:04X}, got 0x{recieved_data:04X}"
    cocotb.log.info("Recieved: 0x%04X", recieved_data)


# @cocotb.test()
# async def test_0(dut):

#     DATA = 0xB00F
#     DELAY_ns = 4

#     await run_test(dut, DATA, DELAY_ns, reset=False)


@cocotb.test()
async def test_1(dut):

    DATA = 0xBEEF
    DELAY_ns = 4

    await run_test(dut, DATA, DELAY_ns)




@cocotb.test()
async def test_2(dut):

    DATA = 0xB00F
    DELAY_ns = 2

    await run_test(dut, DATA, DELAY_ns, reset=False)

   
